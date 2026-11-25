/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 00_Restaurar_Docker.sql  (versión Linux/Docker de 00_Restaurar_Proyecto.sql)
   -----------------------------------------------------------------------------
   Restaura el proyecto completo a partir de los dos respaldos entregados:
       AkilFlowOperaciones.bak  (OLTP: 7 tablas 3FN, RBAC, AES_256, auditoría)
       dwh_AkilFlow.bak         (Data Warehouse: staging, estrella, ETL, OLAP)
   y reconstruye lo que NO viaja dentro de un .bak porque vive en la
   instancia (master / msdb): logins, auditoría de servidor, sesión de
   Extended Events, certificado de respaldos y Job del ETL.

   REQUISITOS
   - SQL Server 2022 (Developer, Standard o Enterprise) + SSMS, conectado
     como sysadmin (autenticación de Windows sirve).
   - Copiar los dos .bak en  /bak/  (si usa otra carpeta,
     cambie SOLO la línea marcada en el PASO 0).
     Si aparece "Operating system error 5 (Access is denied)", copie los .bak
     en la carpeta Backup de la instancia, por ejemplo:
     C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\
   - Para iniciar sesión con los logins SQL del proyecto, la instancia debe
     estar en modo de autenticación MIXTO (no es necesario para la demo,
     que usa EXECUTE AS USER).

   PASOS
     0. Configuración y comprobación de archivos
     1. Carpetas de trabajo /var/opt/mssql/akil/...
     2. Logins de instancia con SID fijo (capa 1 de seguridad)
     3. Auditoría de servidor con GUID fijo (antes de restaurar)
     4. RESTORE de AkilFlowOperaciones y dwh_AkilFlow
     5. Enlace de usuarios con sus logins (sin usuarios huérfanos)
     6. Re-vinculación de la Database Master Key (cifrado AES_256)
     7. Sesión de Extended Events (consultas > 2 s)
     8. Certificado de respaldos cifrados (para la demo DRP)
     9. Job del ETL en SQL Server Agent (si existe)
    10. Verificación final
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =============================================================================
   PASO 0. CONFIGURACIÓN
   ============================================================================= */
IF OBJECT_ID(N'tempdb..#cfg') IS NOT NULL DROP TABLE #cfg;
CREATE TABLE #cfg (carpeta NVARCHAR(260) NOT NULL);
INSERT INTO #cfg VALUES (N'/bak/');   -- <<< CARPETA DE LOS .bak (terminar en /)
GO

DECLARE @c NVARCHAR(260) = (SELECT carpeta FROM #cfg),
        @f NVARCHAR(400), @existe INT;

IF CAST(SERVERPROPERTY('ProductMajorVersion') AS INT) < 16
BEGIN
    PRINT N'ERROR: estos respaldos se generaron en SQL Server 2022 (versión 16) y solo se restauran en 2022 o superior.';
    PRINT CONCAT(N'Versión de esta instancia: ', CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(30)));
    SET NOEXEC ON;           -- detiene el resto del script de forma segura
END;

SET @f = @c + N'AkilFlowOperaciones.bak';
EXEC master.dbo.xp_fileexist @f, @existe OUTPUT;
IF @existe = 0
BEGIN
    PRINT CONCAT(N'ERROR: no se encuentra ', @f, N'. Copie los .bak a esa carpeta o corrija el PASO 0.');
    SET NOEXEC ON;
END;
SET @f = @c + N'dwh_AkilFlow.bak';
EXEC master.dbo.xp_fileexist @f, @existe OUTPUT;
IF @existe = 0
BEGIN
    PRINT CONCAT(N'ERROR: no se encuentra ', @f, N'. Copie los .bak a esa carpeta o corrija el PASO 0.');
    SET NOEXEC ON;
END;
GO
PRINT N'PASO 0 OK: SQL Server 2022 y respaldos encontrados.';
GO

/* =============================================================================
   PASO 1. CARPETAS DE TRABAJO (las crea la cuenta del servicio de SQL Server)
   ============================================================================= */
EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/akil/Audit';
EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/akil/XEvents';
EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/akil/Backups';
EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/akil/Keys';
EXEC master.dbo.xp_create_subdir N'/var/opt/mssql/akil/DR';
GO
PRINT N'PASO 1 OK: carpetas /var/opt/mssql/akil/{Audit, XEvents, Backups, Keys, DR}.';
GO

/* =============================================================================
   PASO 2. LOGINS DE INSTANCIA (no viajan en el .bak: viven en master)
   Se crean con el MISMO SID que tenían en el servidor de origen; así cada
   USER restaurado queda enlazado a su LOGIN automáticamente.
   ============================================================================= */
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_operador')
    CREATE LOGIN login_operador    WITH PASSWORD = N'Akil#Operador2026',   SID = 0xA152CA08318D744289C8C8A8DED9E548,
                                        CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_auditor')
    CREATE LOGIN login_auditor     WITH PASSWORD = N'Akil#Auditor2026',    SID = 0x0C7DB05EAF684840AA45F60B17B02B69,
                                        CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_supervisor')
    CREATE LOGIN login_supervisor  WITH PASSWORD = N'Akil#Supervisor2026', SID = 0x76B8A285BA6E8D4989C41C86F821B286,
                                        CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_contador')
    CREATE LOGIN login_contador    WITH PASSWORD = N'Akil#Contador2026',   SID = 0x4E5B1DA7C4154446B5911694E336724C,
                                        CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_analista_bi')
    CREATE LOGIN login_analista_bi WITH PASSWORD = N'Akil#AnalistaBI2026', SID = 0x1D87A11C44BB334D8F1E7EE4726495B7,
                                        CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO
PRINT N'PASO 2 OK: 5 logins de instancia disponibles.';
GO

/* =============================================================================
   PASO 3. AUDITORÍA DE SERVIDOR (antes del RESTORE)
   La DATABASE AUDIT SPECIFICATION viaja dentro de AkilFlowOperaciones.bak y
   apunta al Server Audit por su GUID. Creando el Server Audit con el mismo
   AUDIT_GUID, la especificación queda enlazada en cuanto la base se restaura.
   ============================================================================= */
IF DB_ID(N'AkilFlowOperaciones') IS NOT NULL
    EXEC (N'USE AkilFlowOperaciones;
            IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = N''DB_Audit_AkilFlow'')
            BEGIN
                ALTER DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow WITH (STATE = OFF);
                DROP DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow;
            END;');
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
CREATE SERVER AUDIT Audit_AkilFlow
TO FILE (FILEPATH = N'/var/opt/mssql/akil/Audit/', MAXSIZE = 50 MB, MAX_ROLLOVER_FILES = 10, RESERVE_DISK_SPACE = OFF)
WITH (QUEUE_DELAY = 1000, ON_FAILURE = CONTINUE, AUDIT_GUID = 'C09D6076-024F-4D02-AAE6-C8837EEF359B');
GO
ALTER SERVER AUDIT Audit_AkilFlow WITH (STATE = ON);
GO
CREATE SERVER AUDIT SPECIFICATION SAS_AkilFlow_Seguridad
FOR SERVER AUDIT Audit_AkilFlow
    ADD (FAILED_LOGIN_GROUP),
    ADD (SERVER_ROLE_MEMBER_CHANGE_GROUP),
    ADD (SERVER_PRINCIPAL_CHANGE_GROUP)
WITH (STATE = ON);
GO
PRINT N'PASO 3 OK: Server Audit Audit_AkilFlow (GUID fijo) activo.';
GO

/* =============================================================================
   PASO 4. RESTAURACIÓN DE LAS DOS BASES
   Los archivos .mdf/.ldf se ubican en las carpetas por defecto de la instancia.
   ============================================================================= */
DECLARE @c    NVARCHAR(260) = (SELECT carpeta FROM #cfg),
        @data NVARCHAR(260) = CAST(SERVERPROPERTY('InstanceDefaultDataPath') AS NVARCHAR(260)),
        @log  NVARCHAR(260) = CAST(SERVERPROPERTY('InstanceDefaultLogPath')  AS NVARCHAR(260)),
        @bak  NVARCHAR(400), @mdf NVARCHAR(400), @ldf NVARCHAR(400);

-- 4.1 AkilFlowOperaciones
IF DB_ID(N'AkilFlowOperaciones') IS NOT NULL
    ALTER DATABASE AkilFlowOperaciones SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
SELECT @bak = @c + N'AkilFlowOperaciones.bak',
       @mdf = @data + N'AkilFlowOperaciones.mdf',
       @ldf = @log  + N'AkilFlowOperaciones_log.ldf';
RESTORE DATABASE AkilFlowOperaciones
    FROM DISK = @bak
    WITH MOVE N'AkilFlowOperaciones'     TO @mdf,
         MOVE N'AkilFlowOperaciones_log' TO @ldf,
         REPLACE, RECOVERY, CHECKSUM, STATS = 25;

-- 4.2 dwh_AkilFlow
IF DB_ID(N'dwh_AkilFlow') IS NOT NULL
    ALTER DATABASE dwh_AkilFlow SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
SELECT @bak = @c + N'dwh_AkilFlow.bak',
       @mdf = @data + N'dwh_AkilFlow.mdf',
       @ldf = @log  + N'dwh_AkilFlow_log.ldf';
RESTORE DATABASE dwh_AkilFlow
    FROM DISK = @bak
    WITH MOVE N'dwh_AkilFlow'     TO @mdf,
         MOVE N'dwh_AkilFlow_log' TO @ldf,
         REPLACE, RECOVERY, CHECKSUM, STATS = 25;
GO
ALTER DATABASE AkilFlowOperaciones SET MULTI_USER;
ALTER DATABASE dwh_AkilFlow        SET MULTI_USER;
GO
-- El propietario pasa a ser sa (no depende del usuario de Windows que restauró)
ALTER AUTHORIZATION ON DATABASE::AkilFlowOperaciones TO sa;
ALTER AUTHORIZATION ON DATABASE::dwh_AkilFlow        TO sa;
GO
PRINT N'PASO 4 OK: AkilFlowOperaciones y dwh_AkilFlow restauradas.';
GO

/* =============================================================================
   PASO 5. USUARIOS ENLAZADOS A SUS LOGINS (capa 2 de seguridad)
   Si algún login ya existía con otro SID, ALTER USER ... WITH LOGIN lo repara.
   ============================================================================= */
USE AkilFlowOperaciones;
GO
ALTER USER usr_operador   WITH LOGIN = login_operador;
ALTER USER usr_auditor    WITH LOGIN = login_auditor;
ALTER USER usr_supervisor WITH LOGIN = login_supervisor;
ALTER USER usr_contador   WITH LOGIN = login_contador;
GO
USE dwh_AkilFlow;
GO
ALTER USER usr_analista_bi WITH LOGIN = login_analista_bi;
GO
PRINT N'PASO 5 OK: 5 usuarios de base de datos enlazados a sus logins.';
GO

/* =============================================================================
   PASO 6. RE-VINCULAR LA DATABASE MASTER KEY
   La DMK restaurada estaba protegida por la Service Master Key del servidor
   de ORIGEN. Se abre con su contraseña y se protege con la SMK de ESTA
   instancia; desde ese momento el certificado y la llave AES_256 funcionan.
   ============================================================================= */
USE AkilFlowOperaciones;
GO
OPEN MASTER KEY DECRYPTION BY PASSWORD = N'Akil#DMK.Operaciones2026';
BEGIN TRY
    ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY;
END TRY
BEGIN CATCH
    PRINT N'La DMK ya estaba protegida por la Service Master Key de esta instancia.';
END CATCH;
CLOSE MASTER KEY;
GO
-- Si la DMK se abre sola (sin contraseña), el re-enlace funcionó
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
SELECT TOP (3) codigo_rastreo,
       CAST(DecryptByKey(remitente_cif)    AS NVARCHAR(120)) AS remitente_descifrado,
       CAST(DecryptByKey(destinatario_cif) AS NVARCHAR(120)) AS destinatario_descifrado
FROM dbo.encomiendas ORDER BY encomienda_id;
CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
GO
PRINT N'PASO 6 OK: DMK re-vinculada; cifrado AES_256 operativo en esta instancia.';
GO

-- La especificación de auditoría de la base viene en el .bak: se asegura su estado ON
IF EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = N'DB_Audit_AkilFlow')
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow WITH (STATE = OFF);
    ALTER DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow WITH (STATE = ON);
END;
GO

/* =============================================================================
   PASO 7. EXTENDED EVENTS - CONSULTAS LENTAS (> 2 s)
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
    WHERE ([duration] > (2000000) AND [sqlserver].[database_name] = N'AkilFlowOperaciones')
),
ADD EVENT sqlserver.rpc_completed (
    ACTION (sqlserver.sql_text, sqlserver.database_name, sqlserver.username,
            sqlserver.client_app_name, sqlserver.client_hostname, sqlserver.session_id)
    WHERE ([duration] > (2000000) AND [sqlserver].[database_name] = N'AkilFlowOperaciones')
)
ADD TARGET package0.event_file (
    SET filename = N'/var/opt/mssql/akil/XEvents/XE_ConsultasLentas_AkilFlow.xel',
        max_file_size = 50, max_rollover_files = 5
)
WITH (MAX_DISPATCH_LATENCY = 1 SECONDS, EVENT_RETENTION_MODE = ALLOW_SINGLE_EVENT_LOSS, STARTUP_STATE = ON);
GO
ALTER EVENT SESSION XE_ConsultasLentas_AkilFlow ON SERVER STATE = START;
GO
PRINT N'PASO 7 OK: sesión XE_ConsultasLentas_AkilFlow iniciada.';
GO

/* =============================================================================
   PASO 8. CERTIFICADO DE RESPALDOS CIFRADOS EN master (demo DRP)
   ============================================================================= */
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'Akil#MasterKey.Instancia2026';
GO
IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = N'CertBackupServer_AkilFlow')
    CREATE CERTIFICATE CertBackupServer_AkilFlow
        WITH SUBJECT = N'Transportes Akil - Cifrado de respaldos DRP', EXPIRY_DATE = '2035-12-31';
GO
PRINT N'PASO 8 OK: certificado CertBackupServer_AkilFlow disponible en master.';
GO

/* =============================================================================
   PASO 9. JOB DEL ETL (SQL Server Agent, diario 02:00) - opcional
   ============================================================================= */
IF CAST(SERVERPROPERTY('EngineEdition') AS INT) <> 4
   AND EXISTS (SELECT 1 FROM msdb.sys.objects WHERE name = N'sp_add_job')
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'ETL_AkilFlow_Diario')
            EXEC msdb.dbo.sp_delete_job @job_name = N'ETL_AkilFlow_Diario';
        IF EXISTS (SELECT 1 FROM msdb.dbo.sysschedules WHERE name = N'Diario_0200')
            EXEC msdb.dbo.sp_delete_schedule @schedule_name = N'Diario_0200', @force_delete = 1;
        EXEC msdb.dbo.sp_add_job         @job_name = N'ETL_AkilFlow_Diario',
                                         @description = N'Carga incremental OLTP AkilFlowOperaciones -> dwh_AkilFlow';
        EXEC msdb.dbo.sp_add_jobstep     @job_name = N'ETL_AkilFlow_Diario', @step_name = N'Ejecutar ETL',
                                         @subsystem = N'TSQL', @database_name = N'dwh_AkilFlow',
                                         @command = N'EXEC dbo.usp_etl_akilflow;', @retry_attempts = 2, @retry_interval = 5;
        EXEC msdb.dbo.sp_add_schedule    @schedule_name = N'Diario_0200', @freq_type = 4, @freq_interval = 1,
                                         @active_start_time = 020000;
        EXEC msdb.dbo.sp_attach_schedule @job_name = N'ETL_AkilFlow_Diario', @schedule_name = N'Diario_0200';
        EXEC msdb.dbo.sp_add_jobserver   @job_name = N'ETL_AkilFlow_Diario', @server_name = N'(local)';
        PRINT N'PASO 9 OK: Job ETL_AkilFlow_Diario programado (02:00).';
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'PASO 9: Job no creado (', ERROR_MESSAGE(), N'). El ETL puede ejecutarse a mano.');
    END CATCH;
END
ELSE
    PRINT N'PASO 9: sin SQL Server Agent (Express). El ETL se ejecuta a mano: EXEC dwh_AkilFlow.dbo.usp_etl_akilflow;';
GO

/* =============================================================================
   PASO 10. VERIFICACIÓN FINAL
   ============================================================================= */
-- 10.1 Bases restauradas
SELECT name AS base, state_desc AS estado, recovery_model_desc AS modelo_recuperacion,
       compatibility_level, SUSER_SNAME(owner_sid) AS propietario
FROM sys.databases
WHERE name IN (N'AkilFlowOperaciones', N'dwh_AkilFlow');

-- 10.2 Filas por tabla en ambas bases
SELECT N'AkilFlowOperaciones' AS base, t.name AS tabla, SUM(p.rows) AS filas
FROM AkilFlowOperaciones.sys.tables t
JOIN AkilFlowOperaciones.sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
UNION ALL
SELECT N'dwh_AkilFlow', t.name, SUM(p.rows)
FROM dwh_AkilFlow.sys.tables t
JOIN dwh_AkilFlow.sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY base, tabla;

-- 10.3 Seguridad: usuarios, roles y login enlazado (0 huérfanos)
SELECT N'AkilFlowOperaciones' AS base, r.name AS rol, u.name AS usuario,
       ISNULL(SUSER_SNAME(u.sid), N'*** HUÉRFANO ***') AS login_enlazado
FROM AkilFlowOperaciones.sys.database_role_members rm
JOIN AkilFlowOperaciones.sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN AkilFlowOperaciones.sys.database_principals u ON u.principal_id = rm.member_principal_id
WHERE r.name LIKE N'Rol[_]%'
UNION ALL
SELECT N'dwh_AkilFlow', r.name, u.name, ISNULL(SUSER_SNAME(u.sid), N'*** HUÉRFANO ***')
FROM dwh_AkilFlow.sys.database_role_members rm
JOIN dwh_AkilFlow.sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN dwh_AkilFlow.sys.database_principals u ON u.principal_id = rm.member_principal_id
WHERE r.name LIKE N'Rol[_]%'
ORDER BY base, rol;

-- 10.4 Auditoría y monitoreo activos
SELECT N'Server Audit' AS componente, name, CASE is_state_enabled WHEN 1 THEN N'ACTIVO' ELSE N'INACTIVO' END AS estado
FROM sys.server_audits WHERE name = N'Audit_AkilFlow'
UNION ALL
SELECT N'Database Audit Spec', name, CASE is_state_enabled WHEN 1 THEN N'ACTIVO' ELSE N'INACTIVO' END
FROM AkilFlowOperaciones.sys.database_audit_specifications
UNION ALL
SELECT N'Extended Events', name, N'ACTIVO'
FROM sys.dm_xe_sessions WHERE name = N'XE_ConsultasLentas_AkilFlow';

-- 10.5 Prueba integral: el operador consulta una encomienda descifrada vía SP seguro
USE AkilFlowOperaciones;
GO
EXECUTE AS USER = N'usr_operador';
    EXEC dbo.usp_consultar_encomienda @codigo_rastreo = 'AK20261125PEND01';
REVERT;
GO
USE master;
GO
PRINT N'=====================================================================';
PRINT N' RESTAURACIÓN COMPLETADA: AkilFlowOperaciones + dwh_AkilFlow listas.';
PRINT N' Siguiente paso: abrir 01_Demo_En_Clase.sql y ejecutar por bloques.';
PRINT N'=====================================================================';
GO
