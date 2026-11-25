/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 03_Auditoria_ExtendedEvents_DRP.sql
   Bases   : master + AkilFlowOperaciones + AkilFlowOperaciones_DR
   Criterio: 4 - Auditoría, monitoreo (Extended Events) y Plan DRP de respaldos
   -----------------------------------------------------------------------------
   Prerrequisito: scripts 01 y 02 ejecutados.
   NOTAS WINDOWS:
   - Todas las rutas cuelgan de C:\AkilFlow\. El script crea las carpetas con
     xp_create_subdir usando la cuenta del servicio de SQL Server, por lo que
     NO hace falta crearlas a mano ni dar permisos NTFS adicionales.
   - Si su equipo no tiene unidad C:, reemplace "C:\AkilFlow\" (Ctrl + H).
   - El cifrado de backups (WITH ENCRYPTION) y COMPRESSION requieren
     Developer, Standard o Enterprise (no Express).
   Contenido:
     FASE 0. Preparación de carpetas
     FASE 1. SQL Server Audit (Server Audit + Server/Database Audit Specification)
     FASE 2. Pruebas DML auditadas (ANTES vs DESPUÉS) y lectura de bitácora
     FASE 3. Extended Events: consultas > 2 segundos
     FASE 4. Plan DRP: RECOVERY FULL + certificado de respaldo + backups cifrados
     FASE 5. Restauración secuencial en AkilFlowOperaciones_DR (NORECOVERY/RECOVERY)
     FASE 6. Validación post-desastre (registros, integridad y descifrado)
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

IF CAST(SERVERPROPERTY('EngineEdition') AS INT) = 4
    PRINT N'AVISO: SQL Server Express no soporta backups cifrados ni COMPRESSION. Use Developer (gratuito).';
GO

/* =============================================================================
   FASE 0. PREPARACIÓN DE CARPETAS (C:\AkilFlow\...)
   ============================================================================= */
EXEC master.dbo.xp_create_subdir N'C:\AkilFlow\Audit';
EXEC master.dbo.xp_create_subdir N'C:\AkilFlow\XEvents';
EXEC master.dbo.xp_create_subdir N'C:\AkilFlow\Backups';
EXEC master.dbo.xp_create_subdir N'C:\AkilFlow\Keys';
EXEC master.dbo.xp_create_subdir N'C:\AkilFlow\DR';
GO
PRINT N'FASE 0 OK: carpetas C:\AkilFlow\{Audit, XEvents, Backups, Keys, DR} listas.';
GO

/* =============================================================================
   FASE 1. SQL SERVER AUDIT
   Nivel 1 (instancia): SERVER AUDIT = destino físico (.sqlaudit)
   Nivel 2 (base)     : DATABASE AUDIT SPECIFICATION = qué acciones se registran
   ============================================================================= */

-- 1.1 Limpieza idempotente (permite re-ejecutar el script)
USE AkilFlowOperaciones;
GO
IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = N'DB_Audit_AkilFlow')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow WITH (STATE = OFF);
    DROP DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow;
END;
GO
USE master;
GO
IF EXISTS (SELECT 1 FROM sys.server_audit_specifications WHERE name = N'SAS_AkilFlow_Seguridad')
BEGIN
    ALTER SERVER AUDIT SPECIFICATION SAS_AkilFlow_Seguridad WITH (STATE = OFF);
    DROP SERVER AUDIT SPECIFICATION SAS_AkilFlow_Seguridad;
END;
IF EXISTS (SELECT 1 FROM sys.server_audits WHERE name = N'Audit_AkilFlow')
BEGIN
    ALTER SERVER AUDIT Audit_AkilFlow WITH (STATE = OFF);
    DROP SERVER AUDIT Audit_AkilFlow;
END;
GO

-- 1.2 Server Audit hacia archivo binario .sqlaudit
CREATE SERVER AUDIT Audit_AkilFlow
TO FILE (
    FILEPATH           = N'C:\AkilFlow\Audit\',
    MAXSIZE            = 50 MB,
    MAX_ROLLOVER_FILES = 10,
    RESERVE_DISK_SPACE = OFF
)
WITH (
    QUEUE_DELAY = 1000,          -- escribe a disco cada 1 s (asíncrono, bajo impacto)
    ON_FAILURE  = CONTINUE,      -- si el disco falla, la operación de negocio continúa
    AUDIT_GUID  = 'C09D6076-024F-4D02-AAE6-C8837EEF359B'   -- GUID fijo: la especificación de BD
                                 -- viaja dentro del .bak y se re-enlaza sola al restaurar
);
GO
ALTER SERVER AUDIT Audit_AkilFlow WITH (STATE = ON);
GO

-- 1.3 Especificación a nivel de servidor: accesos fallidos y cambios de seguridad
CREATE SERVER AUDIT SPECIFICATION SAS_AkilFlow_Seguridad
FOR SERVER AUDIT Audit_AkilFlow
    ADD (FAILED_LOGIN_GROUP),
    ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
    ADD (SERVER_PRINCIPAL_CHANGE_GROUP)
WITH (STATE = ON);
GO

-- 1.4 Especificación a nivel de base de datos sobre las tablas críticas
USE AkilFlowOperaciones;
GO
CREATE DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow
FOR SERVER AUDIT Audit_AkilFlow
    ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.encomiendas BY public),
    ADD (SELECT, UPDATE, DELETE         ON dbo.viajes      BY public),
    ADD (EXECUTE ON dbo.usp_consultar_encomienda          BY public),   -- quién vio datos descifrados
    ADD (DATABASE_ROLE_MEMBER_CHANGE_GROUP),                             -- altas/bajas en roles RBAC
    ADD (SCHEMA_OBJECT_PERMISSION_CHANGE_GROUP)                          -- GRANT / DENY / REVOKE
WITH (STATE = ON);
GO

SELECT a.name AS server_audit, a.is_state_enabled, f.log_file_path, a.queue_delay, a.on_failure_desc
FROM sys.server_audits a
JOIN sys.server_file_audits f ON f.audit_id = a.audit_id;

SELECT s.name AS especificacion, d.audit_action_name AS accion,
       OBJECT_NAME(d.major_id) AS objeto, USER_NAME(d.audited_principal_id) AS principal
FROM sys.database_audit_specifications s
JOIN sys.database_audit_specification_details d ON d.database_specification_id = s.database_specification_id;
GO
PRINT N'FASE 1 OK: Audit_AkilFlow (.sqlaudit) + especificaciones de servidor y base activas.';
GO

/* =============================================================================
   FASE 2. PRUEBAS DML AUDITADAS (ANTES vs DESPUÉS)
   Caso: el despachador asigna la encomienda pendiente AK20261125PEND01 al
   viaje en curso; el administrador elimina la encomienda de demostración;
   el operador intenta borrar (falla) y el auditor consulta.
   ============================================================================= */
DECLARE @viaje_en_curso INT = (SELECT TOP (1) viaje_id FROM dbo.viajes
                               WHERE estado = 'en_curso' ORDER BY fecha_salida);

PRINT N'--- [ANTES] ---';
SELECT codigo_rastreo, viaje_id, estado FROM dbo.encomiendas
WHERE codigo_rastreo IN ('AK20261125PEND01', 'AK20261125DEMO01');

UPDATE dbo.encomiendas
SET viaje_id = @viaje_en_curso, estado = 'en_transito'
WHERE codigo_rastreo = 'AK20261125PEND01';

DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK20261125DEMO01';

PRINT N'--- [DESPUÉS] ---';
SELECT codigo_rastreo, viaje_id, estado FROM dbo.encomiendas
WHERE codigo_rastreo IN ('AK20261125PEND01', 'AK20261125DEMO01');
GO

-- Acciones de los roles RBAC (quedan con su usuario de base de datos en la bitácora)
EXECUTE AS USER = N'usr_operador';
    SELECT COUNT(*) AS encomiendas_en_transito FROM dbo.encomiendas WHERE estado = 'en_transito';
    BEGIN TRY
        DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK20261125PEND02';
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Intento bloqueado y AUDITADO (succeeded = 0) -> Msg ', ERROR_NUMBER());
    END CATCH;
REVERT;
GO
EXECUTE AS USER = N'usr_auditor';
    SELECT TOP (3) codigo_viaje, estado, costo_estimado FROM dbo.viajes ORDER BY viaje_id DESC;
REVERT;
GO

-- 2.1 Lectura de la bitácora (.sqlaudit)
WAITFOR DELAY '00:00:01.500';   -- deja vaciar la cola (QUEUE_DELAY = 1000 ms)
GO
SELECT TOP (25)
       SWITCHOFFSET(CAST(event_time AS DATETIMEOFFSET), DATENAME(TZOFFSET, SYSDATETIMEOFFSET())) AS hora_local,
       action_id,                          -- SL=SELECT, IN=INSERT, UP=UPDATE, DL=DELETE, EX=EXECUTE
       succeeded,                          -- 1 = permitido, 0 = denegado
       session_server_principal_name AS login_sesion,
       database_principal_name       AS usuario_bd,
       database_name,
       object_name,
       LEFT(statement, 150)          AS sentencia
FROM sys.fn_get_audit_file(N'C:\AkilFlow\Audit\*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = N'AkilFlowOperaciones'
ORDER BY event_time DESC;

-- 2.2 Resumen ejecutivo de la bitácora
SELECT action_id, succeeded, database_principal_name AS usuario_bd, object_name, COUNT(*) AS eventos
FROM sys.fn_get_audit_file(N'C:\AkilFlow\Audit\*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = N'AkilFlowOperaciones' AND object_name <> ''
GROUP BY action_id, succeeded, database_principal_name, object_name
ORDER BY eventos DESC;
GO
PRINT N'FASE 2 OK: eventos DML registrados y consultados con sys.fn_get_audit_file.';
GO

/* =============================================================================
   FASE 3. EXTENDED EVENTS - CONSULTAS LENTAS (> 2 SEGUNDOS)
   - "duration" es un campo del evento sql_statement_completed expresado en
     MICROSEGUNDOS: 2 s = 2 000 000 µs.
   - El predicado se evalúa ANTES de enviar el evento al destino, por eso el
     costo es mínimo (a diferencia de SQL Profiler / Trace).
   ============================================================================= */
USE master;
GO
IF EXISTS (SELECT 1 FROM sys.server_event_sessions WHERE name = N'XE_ConsultasLentas_AkilFlow')
    DROP EVENT SESSION XE_ConsultasLentas_AkilFlow ON SERVER;
GO

CREATE EVENT SESSION XE_ConsultasLentas_AkilFlow ON SERVER
ADD EVENT sqlserver.sql_statement_completed (
    ACTION (sqlserver.sql_text, sqlserver.database_name, sqlserver.username,
            sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.session_id)
    WHERE ( [duration] > (2000000)
            AND [sqlserver].[database_name] = N'AkilFlowOperaciones' )
),
ADD EVENT sqlserver.rpc_completed (                       -- llamadas desde aplicaciones (SP)
    ACTION (sqlserver.sql_text, sqlserver.database_name, sqlserver.username,
            sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.session_id)
    WHERE ( [duration] > (2000000)
            AND [sqlserver].[database_name] = N'AkilFlowOperaciones' )
)
ADD TARGET package0.event_file (
    SET filename           = N'C:\AkilFlow\XEvents\XE_ConsultasLentas_AkilFlow.xel',
        max_file_size      = 50,     -- MB
        max_rollover_files = 5
)
WITH (
    MAX_DISPATCH_LATENCY  = 1 SECONDS,
    EVENT_RETENTION_MODE  = ALLOW_SINGLE_EVENT_LOSS,
    STARTUP_STATE         = ON       -- se reinicia sola con el servicio
);
GO
ALTER EVENT SESSION XE_ConsultasLentas_AkilFlow ON SERVER STATE = START;
GO

SELECT s.name, s.create_time, t.target_name
FROM sys.dm_xe_sessions s
JOIN sys.dm_xe_session_targets t ON t.event_session_address = s.address
WHERE s.name = N'XE_ConsultasLentas_AkilFlow';
GO

-- 3.1 Pruebas: una consulta rápida (NO se captura) y dos lentas (SÍ se capturan)
USE AkilFlowOperaciones;
GO
SELECT COUNT(*) AS consulta_rapida FROM dbo.viajes;                 -- milisegundos -> ignorada
GO
WAITFOR DELAY '00:00:03';                                           -- 3 s -> capturada
GO
-- Reporte "pesado" simulado: ranking de rutas + espera de 3 s
SELECT r.codigo_ruta, COUNT(*) AS encomiendas, SUM(e.precio_envio) AS ingresos
FROM dbo.encomiendas e
JOIN dbo.viajes v ON v.viaje_id = e.viaje_id
JOIN dbo.rutas  r ON r.ruta_id  = v.ruta_id
GROUP BY r.codigo_ruta
ORDER BY ingresos DESC;
WAITFOR DELAY '00:00:03';
GO
WAITFOR DELAY '00:00:01.500';                                       -- MAX_DISPATCH_LATENCY (< 2 s, no se captura)
GO

-- 3.2 Lectura del archivo .xel
SELECT x.value('(event/@timestamp)[1]', 'DATETIME2(0)')                                   AS hora_utc,
       x.value('(event/@name)[1]', 'VARCHAR(50)')                                         AS evento,
       CAST(x.value('(event/data[@name="duration"]/value)[1]', 'BIGINT') / 1000000.0
            AS DECIMAL(10,2))                                                             AS duracion_seg,
       x.value('(event/data[@name="logical_reads"]/value)[1]', 'BIGINT')                  AS lecturas_logicas,
       x.value('(event/action[@name="username"]/value)[1]', 'NVARCHAR(128)')              AS usuario,
       x.value('(event/action[@name="client_app_name"]/value)[1]', 'NVARCHAR(128)')       AS aplicacion,
       LEFT(x.value('(event/data[@name="statement"]/value)[1]', 'NVARCHAR(MAX)'), 120)    AS sentencia
FROM sys.fn_xe_file_target_read_file(N'C:\AkilFlow\XEvents\XE_ConsultasLentas_AkilFlow*.xel', NULL, NULL, NULL) f
CROSS APPLY (SELECT CAST(f.event_data AS XML)) AS t(x)
ORDER BY hora_utc DESC;
GO
PRINT N'FASE 3 OK: sesión XE_ConsultasLentas_AkilFlow capturando consultas > 2 s.';
GO

/* =============================================================================
   FASE 4. PLAN DRP - RECOVERY FULL Y CADENA DE BACKUPS CIFRADOS AES_256
   ============================================================================= */
USE master;
GO

-- 4.1 Modelo de recuperación FULL (habilita backups de LOG y restauración a un punto en el tiempo)
ALTER DATABASE AkilFlowOperaciones SET RECOVERY FULL;
SELECT name, recovery_model_desc, log_reuse_wait_desc
FROM sys.databases WHERE name = N'AkilFlowOperaciones';
GO

-- 4.2 Jerarquía de cifrado de respaldos en master
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'Akil#MasterKey.Instancia2026';
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = N'CertBackupServer_AkilFlow')
    CREATE CERTIFICATE CertBackupServer_AkilFlow
        WITH SUBJECT = N'Transportes Akil - Cifrado de respaldos DRP',
             EXPIRY_DATE = '2035-12-31';
GO

-- 4.3 Respaldo del certificado + llave privada (SIN él, los .bak son irrecuperables
--     en otro servidor). Esta copia debe guardarse FUERA del servidor (regla 3-2-1).
BEGIN TRY
    BACKUP CERTIFICATE CertBackupServer_AkilFlow
        TO FILE = N'C:\AkilFlow\Keys\CertBackupServer_AkilFlow.cer'
        WITH PRIVATE KEY (
            FILE = N'C:\AkilFlow\Keys\CertBackupServer_AkilFlow.pvk',
            ENCRYPTION BY PASSWORD = N'Akil#PvkBackup.2026'
        );
    PRINT N'Certificado de respaldo exportado a C:\AkilFlow\Keys\';
END TRY
BEGIN CATCH
    PRINT N'El certificado ya estaba exportado en C:\AkilFlow\Keys\ (se conserva la copia existente).';
END CATCH;
GO

-- 4.3b Respaldo de la DMK y del certificado de la BASE (Laboratorio 10, pregunta 3):
--      sin ellos, las columnas cifradas no se pueden descifrar en otro servidor.
USE AkilFlowOperaciones;
GO
BEGIN TRY
    BACKUP MASTER KEY TO FILE = N'C:\AkilFlow\Keys\AkilFlowOperaciones_DMK.key'
        ENCRYPTION BY PASSWORD = N'Akil#DmkExport.2026';
    BACKUP CERTIFICATE Cert_AkilFlow_Operaciones
        TO FILE = N'C:\AkilFlow\Keys\Cert_AkilFlow_Operaciones.cer'
        WITH PRIVATE KEY (FILE = N'C:\AkilFlow\Keys\Cert_AkilFlow_Operaciones.pvk',
                          ENCRYPTION BY PASSWORD = N'Akil#PvkDatos.2026');
    PRINT N'DMK y certificado de datos exportados a C:\AkilFlow\Keys\';
END TRY
BEGIN CATCH
    PRINT N'La DMK y el certificado de datos ya estaban exportados (se conserva la copia existente).';
END CATCH;
GO
USE master;
GO

-- 4.4 Limpieza de registros de simulacro anteriores (permite re-ejecutar el script)
DELETE FROM AkilFlowOperaciones.dbo.encomiendas
WHERE codigo_rastreo IN ('AK20261125DRP001', 'AK20261125DRP002');
GO

-- 4.5 BACKUP FULL cifrado (domingo 00:00 en producción)
BACKUP DATABASE AkilFlowOperaciones
    TO DISK = N'C:\AkilFlow\Backups\AkilFlow_FULL.bak'
    WITH FORMAT, INIT, CHECKSUM, COMPRESSION,
         NAME = N'AkilFlowOperaciones - FULL',
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow),
         STATS = 50;
GO

-- Transacción de negocio posterior al FULL (debe sobrevivir gracias al DIFF)
USE AkilFlowOperaciones;
GO
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo = 'AK20261125DRP001', @viaje_id = NULL, @usuario_registro_id = 10,
     @remitente = N'Ferretería El Constructor S.A.C.', @documento_remitente = '20480002742',
     @destinatario = N'Wilder Mego Bustamante', @telefono_destinatario = '944556677',
     @descripcion = N'Materiales de ferretería (post-FULL)', @peso_kg = 95.00, @precio_envio = 57.25;
GO

-- 4.6 BACKUP DIFFERENTIAL cifrado (diario 23:00): solo extensiones cambiadas desde el FULL
USE master;
GO
BACKUP DATABASE AkilFlowOperaciones
    TO DISK = N'C:\AkilFlow\Backups\AkilFlow_DIFF.bak'
    WITH DIFFERENTIAL, FORMAT, INIT, CHECKSUM, COMPRESSION,
         NAME = N'AkilFlowOperaciones - DIFF',
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow),
         STATS = 50;
GO

-- Transacciones posteriores al DIFF (deben sobrevivir gracias al LOG)
USE AkilFlowOperaciones;
GO
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo = 'AK20261125DRP002', @viaje_id = NULL, @usuario_registro_id = 12,
     @remitente = N'María Culqui Chávez', @documento_remitente = '43218765',
     @destinatario = N'Botica Santa Rosa S.A.C.', @telefono_destinatario = '955667788',
     @descripcion = N'Medicamentos en caja térmica (post-DIFF)', @peso_kg = 12.50, @precio_envio = 10.00;
UPDATE dbo.encomiendas SET estado = 'devuelta' WHERE codigo_rastreo = 'AK20261125PEND04';
GO

-- 4.7 BACKUP LOG cifrado (cada 15 minutos en producción)
USE master;
GO
BACKUP LOG AkilFlowOperaciones
    TO DISK = N'C:\AkilFlow\Backups\AkilFlow_LOG_01.trn'
    WITH FORMAT, INIT, CHECKSUM, COMPRESSION,
         NAME = N'AkilFlowOperaciones - LOG 01',
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow),
         STATS = 50;
GO

-- 4.8 Verificación de los medios y de la cadena LSN
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Backups\AkilFlow_FULL.bak'   WITH CHECKSUM;
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Backups\AkilFlow_DIFF.bak'   WITH CHECKSUM;
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Backups\AkilFlow_LOG_01.trn' WITH CHECKSUM;
GO
SELECT TOP (3)
       b.name, CASE b.type WHEN 'D' THEN 'FULL' WHEN 'I' THEN 'DIFFERENTIAL' WHEN 'L' THEN 'LOG' END AS tipo,
       b.backup_finish_date, CAST(b.compressed_backup_size / 1048576.0 AS DECIMAL(10,2)) AS mb_comprimido,
       b.key_algorithm, b.encryptor_type, b.first_lsn, b.last_lsn, b.database_backup_lsn AS lsn_base_full,
       m.physical_device_name
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily m ON m.media_set_id = b.media_set_id
WHERE b.database_name = N'AkilFlowOperaciones'
ORDER BY b.backup_finish_date DESC, b.backup_set_id DESC;
GO
PRINT N'FASE 4 OK: cadena FULL -> DIFF -> LOG cifrada con AES_256 y verificada.';
GO

/* =============================================================================
   FASE 5. SIMULACRO DE DESASTRE: RESTAURACIÓN SECUENCIAL EN AkilFlowOperaciones_DR
   FULL  WITH NORECOVERY -> la BD queda en "Restoring", sin rollback, esperando más
   DIFF  WITH NORECOVERY -> aplica los cambios desde el FULL
   LOG   WITH RECOVERY   -> rehace/deshace transacciones y abre la BD
   ============================================================================= */
IF DB_ID(N'AkilFlowOperaciones_DR') IS NOT NULL
BEGIN
    ALTER DATABASE AkilFlowOperaciones_DR SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AkilFlowOperaciones_DR;
END;
GO

-- 5.1 Nombres lógicos contenidos en el backup
RESTORE FILELISTONLY FROM DISK = N'C:\AkilFlow\Backups\AkilFlow_FULL.bak';
GO

-- 5.2 FULL
RESTORE DATABASE AkilFlowOperaciones_DR
    FROM DISK = N'C:\AkilFlow\Backups\AkilFlow_FULL.bak'
    WITH MOVE N'AkilFlowOperaciones'     TO N'C:\AkilFlow\DR\AkilFlowOperaciones_DR.mdf',
         MOVE N'AkilFlowOperaciones_log' TO N'C:\AkilFlow\DR\AkilFlowOperaciones_DR_log.ldf',
         NORECOVERY, CHECKSUM, STATS = 50;
GO
SELECT name, state_desc FROM sys.databases WHERE name = N'AkilFlowOperaciones_DR';   -- RESTORING
GO

-- 5.3 DIFFERENTIAL
RESTORE DATABASE AkilFlowOperaciones_DR
    FROM DISK = N'C:\AkilFlow\Backups\AkilFlow_DIFF.bak'
    WITH NORECOVERY, CHECKSUM, STATS = 50;
GO

-- 5.4 LOG (último eslabón) -> RECOVERY
RESTORE LOG AkilFlowOperaciones_DR
    FROM DISK = N'C:\AkilFlow\Backups\AkilFlow_LOG_01.trn'
    WITH RECOVERY, CHECKSUM, STATS = 50;
GO
SELECT name, state_desc, recovery_model_desc FROM sys.databases WHERE name = N'AkilFlowOperaciones_DR';  -- ONLINE
GO
PRINT N'FASE 5 OK: AkilFlowOperaciones_DR restaurada y ONLINE.';
GO

/* =============================================================================
   FASE 6. VALIDACIÓN POST-DESASTRE
   ============================================================================= */
-- 6.1 Conciliación de registros Producción vs DR
SELECT 'encomiendas' AS tabla,
       (SELECT COUNT(*) FROM AkilFlowOperaciones.dbo.encomiendas)    AS produccion,
       (SELECT COUNT(*) FROM AkilFlowOperaciones_DR.dbo.encomiendas) AS contingencia
UNION ALL
SELECT 'viajes',
       (SELECT COUNT(*) FROM AkilFlowOperaciones.dbo.viajes),
       (SELECT COUNT(*) FROM AkilFlowOperaciones_DR.dbo.viajes);
GO

-- 6.2 Integridad física y lógica de la base restaurada
DBCC CHECKDB (N'AkilFlowOperaciones_DR') WITH NO_INFOMSGS;
PRINT N'DBCC CHECKDB sin errores en AkilFlowOperaciones_DR.';
GO

-- 6.3 Descifrado en la base de contingencia
-- La DMK restaurada está cifrada por la Service Master Key "de origen"; se abre
-- con su contraseña y se vuelve a vincular a la SMK de esta instancia.
USE AkilFlowOperaciones_DR;
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = N'Akil#DMK.Operaciones2026';
ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY;
CLOSE MASTER KEY;
GO
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
SELECT codigo_rastreo, estado,
       CAST(DecryptByKey(remitente_cif)    AS NVARCHAR(120)) AS remitente,
       CAST(DecryptByKey(destinatario_cif) AS NVARCHAR(120)) AS destinatario,
       CASE codigo_rastreo WHEN 'AK20261125DRP001' THEN 'Recuperada por el DIFF'
                           ELSE 'Recuperada por el LOG' END AS evidencia
FROM dbo.encomiendas
WHERE codigo_rastreo IN ('AK20261125DRP001', 'AK20261125DRP002', 'AK20261125PEND04');
CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
GO

/* --- Referencia 3-2-1 (copia off-site a la nube; requiere credencial de Azure) ---
CREATE CREDENTIAL [https://akilbackups.blob.core.windows.net/drp]
    WITH IDENTITY = 'SHARED ACCESS SIGNATURE', SECRET = '<token SAS>';
BACKUP DATABASE AkilFlowOperaciones
    TO URL = 'https://akilbackups.blob.core.windows.net/drp/AkilFlow_FULL.bak'
    WITH COMPRESSION, CHECKSUM,
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow);
------------------------------------------------------------------------------------ */

USE master;
GO
PRINT N'=== SCRIPT 03 FINALIZADO: auditoría, Extended Events y DRP validados. ===';
GO
