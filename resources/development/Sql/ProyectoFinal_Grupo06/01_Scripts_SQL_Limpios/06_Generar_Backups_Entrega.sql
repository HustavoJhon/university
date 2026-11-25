/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 06_Generar_Backups_Entrega.sql
   Bases   : AkilFlowOperaciones + dwh_AkilFlow
   Objetivo: generar los DOS archivos .bak que se entregan al docente y que se
             restauran en el aula con 00_Restaurar_Proyecto.sql (sin volver a
             ejecutar los scripts 01 a 05 uno por uno).
   -----------------------------------------------------------------------------
   Prerrequisito: scripts 01 a 05 ejecutados en SQL Server 2022.
   Decisiones técnicas:
   - COPY_ONLY : copia independiente; NO rompe la cadena FULL -> DIFF -> LOG del
                 plan DRP (el siguiente DIFF sigue tomando como base el FULL del
                 script 03).
   - CHECKSUM  : valida cada página al escribir; RESTORE VERIFYONLY lo comprueba.
   - Sin WITH ENCRYPTION a propósito: un .bak cifrado SOLO se restaura en un
     servidor que tenga el certificado CertBackupServer_AkilFlow (esa es su
     protección). La PC del aula no lo tiene. Los datos personales siguen
     protegidos porque dentro del .bak viajan como VARBINARY cifrado con
     AES_256 y la DMK exige su contraseña para abrirse en otro servidor.
     El respaldo cifrado se demuestra en vivo con 01_Demo_En_Clase.sql.
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO

EXEC master.dbo.xp_create_subdir N'C:\AkilFlow\Entrega';
GO

-- La base de contingencia del simulacro DRP no forma parte de la entrega
IF DB_ID(N'AkilFlowOperaciones_DR') IS NOT NULL
BEGIN
    ALTER DATABASE AkilFlowOperaciones_DR SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AkilFlowOperaciones_DR;
END;
GO

-- 1. Respaldo de la base transaccional (OLTP)
BACKUP DATABASE AkilFlowOperaciones
    TO DISK = N'C:\AkilFlow\Entrega\AkilFlowOperaciones.bak'
    WITH COPY_ONLY, FORMAT, INIT, CHECKSUM, COMPRESSION,
         NAME = N'AkilFlowOperaciones - Entrega Grupo 6',
         DESCRIPTION = N'OLTP 3FN + RBAC + AES_256 + auditoría (BD2 NRC 39572)',
         STATS = 25;
GO

-- 2. Respaldo del Data Warehouse
BACKUP DATABASE dwh_AkilFlow
    TO DISK = N'C:\AkilFlow\Entrega\dwh_AkilFlow.bak'
    WITH COPY_ONLY, FORMAT, INIT, CHECKSUM, COMPRESSION,
         NAME = N'dwh_AkilFlow - Entrega Grupo 6',
         DESCRIPTION = N'Staging + esquema estrella + ETL MERGE + OLAP (BD2 NRC 39572)',
         STATS = 25;
GO

-- 3. Verificación de los medios
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Entrega\AkilFlowOperaciones.bak' WITH CHECKSUM;
RESTORE VERIFYONLY FROM DISK = N'C:\AkilFlow\Entrega\dwh_AkilFlow.bak'        WITH CHECKSUM;
GO

SELECT TOP (2) b.database_name, b.name, b.is_copy_only,
       CAST(b.backup_size / 1048576.0            AS DECIMAL(10,2)) AS mb_datos,
       CAST(b.compressed_backup_size / 1048576.0 AS DECIMAL(10,2)) AS mb_archivo,
       b.has_backup_checksums, m.physical_device_name
FROM msdb.dbo.backupset b
JOIN msdb.dbo.backupmediafamily m ON m.media_set_id = b.media_set_id
WHERE m.physical_device_name LIKE N'%Entrega%'
ORDER BY b.backup_finish_date DESC;
GO
PRINT N'=== SCRIPT 06 FINALIZADO: AkilFlowOperaciones.bak y dwh_AkilFlow.bak listos en C:\AkilFlow\Entrega\ ===';
GO
