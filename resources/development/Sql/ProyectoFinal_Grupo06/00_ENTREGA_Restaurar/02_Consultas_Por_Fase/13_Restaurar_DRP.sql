/* =============================================================================
   FASE 13 · DRP: SIMULACRO DE DESASTRE - RESTAURAR FULL + DIFF + LOG
   Ejecutar DESPUÉS de 12_Backups_FULL_DIFF_LOG.sql. En SSMS (sysadmin): abrir y F5.
   Restaura en una base nueva, AkilFlowOperaciones_DR, sin tocar la original.
   Archivos .mdf/.ldf de la contingencia: C:\AkilFlow\DR\
   RECOMENDADO en SSMS: Ctrl + T (Resultados en texto) para ver en orden los
   títulos, las tablas y los mensajes de error. Ctrl + D vuelve a cuadrícula.
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 13.1 Contenido de cada respaldo (RESTORE HEADERONLY) ===';
RESTORE HEADERONLY FROM DISK = N'C:\AkilFlow\Backups\Demo_FULL.bak';
RESTORE HEADERONLY FROM DISK = N'C:\AkilFlow\Backups\Demo_DIFF.bak';
RESTORE HEADERONLY FROM DISK = N'C:\AkilFlow\Backups\Demo_LOG.trn';
GO
IF DB_ID(N'AkilFlowOperaciones_DR') IS NOT NULL
BEGIN
    ALTER DATABASE AkilFlowOperaciones_DR SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AkilFlowOperaciones_DR;
END;
GO
PRINT N'=== 13.2 [1/3] RESTORE FULL con NORECOVERY (la base queda en RESTORING) ===';
RESTORE DATABASE AkilFlowOperaciones_DR FROM DISK = N'C:\AkilFlow\Backups\Demo_FULL.bak'
    WITH MOVE N'AkilFlowOperaciones'     TO N'C:\AkilFlow\DR\AkilFlowOperaciones_DR.mdf',
         MOVE N'AkilFlowOperaciones_log' TO N'C:\AkilFlow\DR\AkilFlowOperaciones_DR_log.ldf',
         NORECOVERY;
SELECT name, state_desc AS estado FROM sys.databases WHERE name = N'AkilFlowOperaciones_DR';
GO
PRINT N'=== 13.3 [2/3] RESTORE DIFERENCIAL con NORECOVERY ===';
RESTORE DATABASE AkilFlowOperaciones_DR FROM DISK = N'C:\AkilFlow\Backups\Demo_DIFF.bak' WITH NORECOVERY;
GO
PRINT N'=== 13.4 [3/3] RESTORE LOG con RECOVERY (la base queda ONLINE) ===';
RESTORE LOG AkilFlowOperaciones_DR FROM DISK = N'C:\AkilFlow\Backups\Demo_LOG.trn' WITH RECOVERY;
SELECT name, state_desc AS estado FROM sys.databases WHERE name = N'AkilFlowOperaciones_DR';
GO
PRINT N'=== 13.5 Validación: ambas transacciones sobrevivieron y se descifran ===';
USE AkilFlowOperaciones_DR;
GO
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
SELECT codigo_rastreo, descripcion, CAST(DecryptByKey(remitente_cif) AS NVARCHAR(120)) AS remitente
FROM dbo.encomiendas WHERE codigo_rastreo IN ('AK-DRP-POSTFULL', 'AK-DRP-POSTDIFF');
CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
GO
PRINT N'=== 13.6 Original vs contingencia: mismas filas ===';
SELECT N'AkilFlowOperaciones'    AS base, COUNT(*) AS encomiendas FROM AkilFlowOperaciones.dbo.encomiendas
UNION ALL
SELECT N'AkilFlowOperaciones_DR',          COUNT(*)                 FROM AkilFlowOperaciones_DR.dbo.encomiendas;
GO
PRINT N'=== 13.7 Archivos de datos de la base restaurada ===';
SELECT name AS archivo_logico, physical_name AS ruta, CAST(size * 8 / 1024.0 AS DECIMAL(10,1)) AS mb
FROM sys.database_files;
GO
USE master;
GO
PRINT N'>>> FASE 13 OK: cadena FULL -> DIFF -> LOG restaurada sin pérdida de datos.';
GO
