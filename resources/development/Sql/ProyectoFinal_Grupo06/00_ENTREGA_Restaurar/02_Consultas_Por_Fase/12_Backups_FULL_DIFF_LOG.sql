/* =============================================================================
   FASE 12 · DRP: GENERAR LOS 3 RESPALDOS CIFRADOS (FULL -> DIFF -> LOG)
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5,
   o seleccionar un bloque y F5.
   Carpeta: C:\AkilFlow\Backups\
       Demo_FULL.bak  · Demo_DIFF.bak  · Demo_LOG.trn
   Para verlos: abrir C:\AkilFlow\Backups en el Explorador de archivos
   (o ver el resultado de la consulta 12.5).
   RECOMENDADO en SSMS: Ctrl + T (Resultados en texto) para ver en orden los
   títulos, las tablas y los mensajes de error. Ctrl + D vuelve a cuadrícula.
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 12.1 Requisitos: modelo FULL y certificado de cifrado en master ===';
SELECT name AS base, recovery_model_desc AS modelo FROM sys.databases WHERE name = N'AkilFlowOperaciones';
SELECT name AS certificado, subject, CAST(expiry_date AS DATE) AS vence
FROM sys.certificates WHERE name = N'CertBackupServer_AkilFlow';
GO

PRINT N'=== 12.2 [1/3] BACKUP FULL cifrado AES_256 ===';
BACKUP DATABASE AkilFlowOperaciones TO DISK = N'C:\AkilFlow\Backups\Demo_FULL.bak'
    WITH FORMAT, INIT, CHECKSUM, COMPRESSION,
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow);
GO
PRINT N'--- Transacción posterior al FULL (solo estará en el DIFF) ---';
USE AkilFlowOperaciones;
GO
DELETE FROM dbo.encomiendas WHERE codigo_rastreo IN ('AK-DRP-POSTFULL', 'AK-DRP-POSTDIFF');
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo = 'AK-DRP-POSTFULL', @viaje_id = NULL, @usuario_registro_id = 10,
     @remitente = N'Ferretería El Constructor S.A.C.', @documento_remitente = '20480002742',
     @destinatario = N'Wilder Mego Bustamante', @telefono_destinatario = '944556677',
     @descripcion = N'Registrada después del FULL', @peso_kg = 95.00, @precio_envio = 57.25;
GO
USE master;
GO
PRINT N'=== 12.3 [2/3] BACKUP DIFERENCIAL cifrado ===';
BACKUP DATABASE AkilFlowOperaciones TO DISK = N'C:\AkilFlow\Backups\Demo_DIFF.bak'
    WITH DIFFERENTIAL, FORMAT, INIT, CHECKSUM, COMPRESSION,
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow);
GO
PRINT N'--- Transacción posterior al DIFF (solo estará en el LOG) ---';
USE AkilFlowOperaciones;
GO
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo = 'AK-DRP-POSTDIFF', @viaje_id = NULL, @usuario_registro_id = 12,
     @remitente = N'María Culqui Chávez', @documento_remitente = '43218765',
     @destinatario = N'Botica Santa Rosa S.A.C.', @telefono_destinatario = '955667788',
     @descripcion = N'Registrada después del DIFF', @peso_kg = 12.50, @precio_envio = 10.00;
GO
USE master;
GO
PRINT N'=== 12.4 [3/3] BACKUP DEL LOG DE TRANSACCIONES cifrado ===';
BACKUP LOG AkilFlowOperaciones TO DISK = N'C:\AkilFlow\Backups\Demo_LOG.trn'
    WITH FORMAT, INIT, CHECKSUM, COMPRESSION,
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow);
GO

PRINT N'';
PRINT N'=== 12.5 ARCHIVOS GENERADOS en C:\AkilFlow\Backups\ ===';
SELECT full_filesystem_path AS ruta_completa,
       CAST(size_in_bytes / 1024.0 AS DECIMAL(10,1)) AS tamano_kb,
       CAST(last_write_time AS DATETIME2(0)) AS creado
FROM sys.dm_os_enumerate_filesystem(N'C:\AkilFlow\Backups', N'*')
WHERE is_directory = 0
ORDER BY last_write_time;
GO
PRINT N'=== 12.6 Historial en msdb: tipo, tamaño, compresión, cifrado y checksum ===';
SELECT TOP (3)
       CASE b.type WHEN 'D' THEN N'FULL' WHEN 'I' THEN N'DIFERENCIAL' WHEN 'L' THEN N'LOG' END AS tipo,
       m.physical_device_name AS archivo,
       CAST(b.backup_size / 1048576.0 AS DECIMAL(10,2))            AS mb_original,
       CAST(b.compressed_backup_size / 1048576.0 AS DECIMAL(10,2)) AS mb_comprimido,
       b.encryptor_type AS cifrado_con, b.key_algorithm AS algoritmo,
       b.has_backup_checksums AS checksum, b.first_lsn, b.last_lsn,
       CAST(b.backup_finish_date AS DATETIME2(0)) AS terminado
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily m ON m.media_set_id = b.media_set_id
WHERE b.database_name = N'AkilFlowOperaciones'
ORDER BY b.backup_finish_date DESC;
GO
PRINT N'=== 12.7 Verificación de integridad de cada archivo (RESTORE VERIFYONLY) ===';
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Backups\Demo_FULL.bak' WITH CHECKSUM;
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Backups\Demo_DIFF.bak' WITH CHECKSUM;
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Backups\Demo_LOG.trn'  WITH CHECKSUM;
GO
PRINT N'>>> FASE 12 OK: 3 respaldos cifrados AES_256, comprimidos y verificados. Siguiente: 13_Restaurar_DRP.sql';
GO
