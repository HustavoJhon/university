/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 01_Demo_En_Clase.sql
   -----------------------------------------------------------------------------
   Prerrequisito: 00_Restaurar_Proyecto.sql ejecutado.
   Uso: seleccionar CADA BLOQUE (de un encabezado al siguiente) y ejecutarlo
   con F5. Se puede repetir cuantas veces se quiera.
     BLOQUE A  - Criterio 2 · Plan de ejecución antes / después   (Andre)
     BLOQUE B  - Criterio 3 · RBAC, GRANT / DENY / REVOKE, AES_256 (Amy)
     BLOQUE C  - Criterio 4 · SQL Server Audit                     (Jessica)
     BLOQUE D  - Criterio 4 · Extended Events > 2 s                (Jessica)
     BLOQUE E  - Criterio 4 · DRP: backups cifrados + restauración (Jessica)
     BLOQUE F  - Criterio 5 · ETL incremental + cuarentena         (Jhon)
     BLOQUE G  - Criterio 5 · Consultas OLAP y seguridad BI        (Jhon)
   ============================================================================= */


/* =============================================================================
   BLOQUE A - PLAN DE EJECUCIÓN (activar antes "Incluir plan real": Ctrl + M)
   Misma consulta dos veces: la primera obliga a usar el índice clúster
   (lo que pasaría SIN el índice no clúster), la segunda deja elegir al
   optimizador. Comparar la pestaña "Plan de ejecución" y "Mensajes".
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SET STATISTICS IO ON;
GO
-- ANTES: Clustered Index Scan (lee la tabla completa)
SELECT codigo_rastreo, fecha_registro, peso_kg, precio_envio, estado
FROM dbo.encomiendas WITH (INDEX (PK_encomiendas))
WHERE estado = 'en_transito' AND fecha_registro >= '2026-11-23';
GO
-- DESPUÉS: Index Seek sobre IX_encomiendas_estado_fecha (covering, sin Key Lookup)
SELECT codigo_rastreo, fecha_registro, peso_kg, precio_envio, estado
FROM dbo.encomiendas
WHERE estado = 'en_transito' AND fecha_registro >= '2026-11-23';
GO
SET STATISTICS IO OFF;
GO
-- Inventario de índices clúster / no clúster
SELECT t.name AS tabla, i.name AS indice, i.type_desc AS tipo, i.has_filter AS filtrado
FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.type > 0 ORDER BY t.name, i.type, i.name;
GO


/* =============================================================================
   BLOQUE B - SEGURIDAD RBAC EN 2 CAPAS Y CIFRADO AES_256
   ============================================================================= */
USE AkilFlowOperaciones;
GO
-- B.1 Capa 1 (login) -> capa 2 (user) -> rol
SELECT sp.name AS login_instancia, dp.name AS usuario_bd, r.name AS rol
FROM sys.database_principals dp
JOIN sys.server_principals sp ON sp.sid = dp.sid
JOIN sys.database_role_members rm ON rm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
ORDER BY r.name;
GO
-- B.2 Datos sensibles: así se ven SIN la llave (binario)
SELECT TOP (3) codigo_rastreo, remitente_cif, destinatario_cif FROM dbo.encomiendas ORDER BY encomienda_id;
-- ... y CON la llave simétrica AES_256 abierta
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
SELECT TOP (3) codigo_rastreo,
       CAST(DecryptByKey(remitente_cif)    AS NVARCHAR(120)) AS remitente,
       CAST(DecryptByKey(destinatario_cif) AS NVARCHAR(120)) AS destinatario
FROM dbo.encomiendas ORDER BY encomienda_id;
CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
GO
-- B.3 Operador: registra una encomienda (se cifra dentro del SP) -> PERMITIDO
DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK-DEMO-CLASE';
EXECUTE AS USER = N'usr_operador';
    EXEC dbo.usp_registrar_encomienda
         @codigo_rastreo = 'AK-DEMO-CLASE', @viaje_id = NULL, @usuario_registro_id = 9,
         @remitente = N'Cooperativa Agraria La Prosperidad', @documento_remitente = '20480001371',
         @destinatario = N'Marleny Guevara Tapia', @telefono_destinatario = '976112233',
         @descripcion = N'Sacos de café (demo en clase)', @peso_kg = 180.00, @precio_envio = 104.00;
    EXEC dbo.usp_consultar_encomienda @codigo_rastreo = 'AK-DEMO-CLASE';
REVERT;
GO
-- B.4 Operador intenta BORRAR -> Msg 229 (DENY explícito). Se verá el error en rojo.
EXECUTE AS USER = N'usr_operador';
DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK-DEMO-CLASE';
REVERT;
GO
-- B.5 Operador intenta cambiar el PRECIO -> Msg 230 (permiso por columna)
EXECUTE AS USER = N'usr_operador';
UPDATE dbo.encomiendas SET precio_envio = 0 WHERE codigo_rastreo = 'AK-DEMO-CLASE';
REVERT;
GO
-- B.6 Auditor: lee, pero NO puede descifrar (NULL) ni usar la llave (Msg 15151)
EXECUTE AS USER = N'usr_auditor';
SELECT TOP (3) codigo_rastreo, CAST(DecryptByKey(remitente_cif) AS NVARCHAR(120)) AS intento_descifrar
FROM dbo.encomiendas ORDER BY encomienda_id;
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
REVERT;
GO
-- B.7 Contador: ve montos, nunca datos personales -> Msg 230 en la columna cifrada
EXECUTE AS USER = N'usr_contador';
SELECT TOP (3) codigo_viaje, ingresos, costo_estimado, margen_bruto FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;
SELECT TOP (1) codigo_rastreo, remitente_cif FROM dbo.encomiendas;
REVERT;
GO
-- B.8 REVOKE vs DENY: se retira UPDATE(estado) en viajes y el operador pierde el acceso
REVOKE UPDATE (estado) ON dbo.viajes FROM Rol_Operador;
GO
EXECUTE AS USER = N'usr_operador';
UPDATE dbo.viajes SET estado = estado WHERE viaje_id = 1;      -- Msg 229 tras el REVOKE
REVERT;
GO
GRANT UPDATE (estado) ON dbo.viajes TO Rol_Operador;           -- se restituye
GO


/* =============================================================================
   BLOQUE C - SQL SERVER AUDIT (ANTES vs DESPUÉS + bitácora)
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SELECT codigo_rastreo, viaje_id, estado FROM dbo.encomiendas WHERE codigo_rastreo = 'AK-DEMO-CLASE';  -- ANTES
UPDATE dbo.encomiendas SET estado = 'devuelta' WHERE codigo_rastreo = 'AK-DEMO-CLASE';
SELECT codigo_rastreo, viaje_id, estado FROM dbo.encomiendas WHERE codigo_rastreo = 'AK-DEMO-CLASE';  -- DESPUÉS
GO
EXECUTE AS USER = N'usr_operador';
BEGIN TRY
    DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK-DEMO-CLASE';                  -- denegado y auditado
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Intento de borrado bloqueado y registrado -> Msg ', ERROR_NUMBER());
END CATCH;
REVERT;
GO
WAITFOR DELAY '00:00:01.500'; -- QUEUE_DELAY = 1 s (menos de 2 s: no lo captura el XE)
GO
SELECT TOP (15)
       SWITCHOFFSET(CAST(event_time AS DATETIMEOFFSET), DATENAME(TZOFFSET, SYSDATETIMEOFFSET())) AS hora_local,
       action_id, succeeded, database_principal_name AS usuario_bd, object_name, LEFT(statement, 120) AS sentencia
FROM sys.fn_get_audit_file(N'C:\AkilFlow\Audit\*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = N'AkilFlowOperaciones'
ORDER BY event_time DESC;
GO


/* =============================================================================
   BLOQUE D - EXTENDED EVENTS: solo se capturan sentencias de más de 2 s
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SELECT COUNT(*) AS consulta_rapida FROM dbo.viajes;     -- milisegundos: NO se captura
GO
WAITFOR DELAY '00:00:03';                               -- 3 s: SÍ se captura
GO
WAITFOR DELAY '00:00:01.500';
GO
SELECT x.value('(event/@timestamp)[1]', 'DATETIME2(0)')                                AS hora_utc,
       x.value('(event/@name)[1]', 'VARCHAR(50)')                                      AS evento,
       CAST(x.value('(event/data[@name="duration"]/value)[1]', 'BIGINT') / 1000000.0 AS DECIMAL(10,2)) AS segundos,
       x.value('(event/action[@name="username"]/value)[1]', 'NVARCHAR(128)')           AS usuario,
       LEFT(x.value('(event/data[@name="statement"]/value)[1]', 'NVARCHAR(MAX)'), 100) AS sentencia
FROM sys.fn_xe_file_target_read_file(N'C:\AkilFlow\XEvents\XE_ConsultasLentas_AkilFlow*.xel', NULL, NULL, NULL) f
CROSS APPLY (SELECT CAST(f.event_data AS XML)) t(x)
ORDER BY hora_utc DESC;
GO


/* =============================================================================
   BLOQUE E - PLAN DRP: FULL -> DIFF -> LOG cifrados y restauración secuencial
   ============================================================================= */
USE master;
GO
SELECT name, recovery_model_desc FROM sys.databases WHERE name = N'AkilFlowOperaciones';   -- FULL
GO
-- E.1 FULL cifrado AES_256
BACKUP DATABASE AkilFlowOperaciones TO DISK = N'C:\AkilFlow\Backups\Demo_FULL.bak'
    WITH FORMAT, INIT, CHECKSUM, COMPRESSION,
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow);
GO
-- transacción posterior al FULL
USE AkilFlowOperaciones;
GO
DELETE FROM dbo.encomiendas WHERE codigo_rastreo IN ('AK-DRP-POSTFULL', 'AK-DRP-POSTDIFF');
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo = 'AK-DRP-POSTFULL', @viaje_id = NULL, @usuario_registro_id = 10,
     @remitente = N'Ferretería El Constructor S.A.C.', @documento_remitente = '20480002742',
     @destinatario = N'Wilder Mego Bustamante', @telefono_destinatario = '944556677',
     @descripcion = N'Registrada después del FULL', @peso_kg = 95.00, @precio_envio = 57.25;
GO
-- E.2 DIFF cifrado
USE master;
GO
BACKUP DATABASE AkilFlowOperaciones TO DISK = N'C:\AkilFlow\Backups\Demo_DIFF.bak'
    WITH DIFFERENTIAL, FORMAT, INIT, CHECKSUM, COMPRESSION,
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow);
GO
-- transacción posterior al DIFF
USE AkilFlowOperaciones;
GO
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo = 'AK-DRP-POSTDIFF', @viaje_id = NULL, @usuario_registro_id = 12,
     @remitente = N'María Culqui Chávez', @documento_remitente = '43218765',
     @destinatario = N'Botica Santa Rosa S.A.C.', @telefono_destinatario = '955667788',
     @descripcion = N'Registrada después del DIFF', @peso_kg = 12.50, @precio_envio = 10.00;
GO
-- E.3 LOG cifrado
USE master;
GO
BACKUP LOG AkilFlowOperaciones TO DISK = N'C:\AkilFlow\Backups\Demo_LOG.trn'
    WITH FORMAT, INIT, CHECKSUM, COMPRESSION,
         ENCRYPTION (ALGORITHM = AES_256, SERVER CERTIFICATE = CertBackupServer_AkilFlow);
GO
-- E.4 Simulacro: restauración en la base de contingencia
IF DB_ID(N'AkilFlowOperaciones_DR') IS NOT NULL
BEGIN
    ALTER DATABASE AkilFlowOperaciones_DR SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AkilFlowOperaciones_DR;
END;
GO
RESTORE DATABASE AkilFlowOperaciones_DR FROM DISK = N'C:\AkilFlow\Backups\Demo_FULL.bak'
    WITH MOVE N'AkilFlowOperaciones'     TO N'C:\AkilFlow\DR\AkilFlowOperaciones_DR.mdf',
         MOVE N'AkilFlowOperaciones_log' TO N'C:\AkilFlow\DR\AkilFlowOperaciones_DR_log.ldf',
         NORECOVERY;
SELECT name, state_desc FROM sys.databases WHERE name = N'AkilFlowOperaciones_DR';     -- RESTORING
RESTORE DATABASE AkilFlowOperaciones_DR FROM DISK = N'C:\AkilFlow\Backups\Demo_DIFF.bak' WITH NORECOVERY;
RESTORE LOG      AkilFlowOperaciones_DR FROM DISK = N'C:\AkilFlow\Backups\Demo_LOG.trn'  WITH RECOVERY;
SELECT name, state_desc FROM sys.databases WHERE name = N'AkilFlowOperaciones_DR';     -- ONLINE
GO
-- E.5 Validación: las dos encomiendas sobreviven y se descifran en la contingencia
USE AkilFlowOperaciones_DR;
GO
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
SELECT codigo_rastreo, descripcion, CAST(DecryptByKey(remitente_cif) AS NVARCHAR(120)) AS remitente
FROM dbo.encomiendas WHERE codigo_rastreo IN ('AK-DRP-POSTFULL', 'AK-DRP-POSTDIFF');
CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
GO
USE master;
GO


/* =============================================================================
   BLOQUE F - ETL INCREMENTAL (MERGE) + CUARENTENA DE ERRORES
   ============================================================================= */
USE dwh_AkilFlow;
GO
-- F.1 Un viaje en curso llega a destino en la OLTP
DECLARE @viaje INT = (SELECT TOP (1) viaje_id FROM AkilFlowOperaciones.dbo.viajes
                      WHERE estado = 'en_curso' ORDER BY fecha_salida);
IF @viaje IS NOT NULL
BEGIN
    UPDATE AkilFlowOperaciones.dbo.viajes
       SET estado = 'completado', fecha_llegada = DATEADD(HOUR, 6, fecha_salida) WHERE viaje_id = @viaje;
    UPDATE AkilFlowOperaciones.dbo.encomiendas SET estado = 'entregada' WHERE viaje_id = @viaje;
    PRINT CONCAT(N'Viaje ', @viaje, N' completado en la OLTP.');
END
ELSE PRINT N'No quedan viajes en curso: el ETL solo confirmará que no hay cambios.';
GO
-- F.2 ETL: solo ACTUALIZA los hechos de ese viaje (hechos_insertados = 0)
EXEC dbo.usp_etl_akilflow;
GO
-- F.3 Conciliación Staging vs Fact y tabla de cuarentena
SELECT 'Staging' AS origen, COUNT(*) AS filas, SUM(precio_envio) AS ingresos FROM dbo.staging_encomiendas
UNION ALL
SELECT 'Fact', SUM(cantidad_encomiendas), SUM(ingreso_envio) FROM dbo.fact_encomiendas;
SELECT * FROM dbo.etl_errores;
GO


/* =============================================================================
   BLOQUE G - CONSULTAS OLAP Y SEGURIDAD DEL DWH
   ============================================================================= */
USE dwh_AkilFlow;
GO
-- G.1 ROLLUP: Región > Sucursal > Ruta (2026) con subtotales
SELECT CASE WHEN GROUPING(s.region) = 1 THEN N'** TOTAL EMPRESA **' ELSE s.region END AS region,
       CASE WHEN GROUPING(s.sucursal_nombre) = 1 AND GROUPING(s.region) = 0 THEN N'* Subtotal región *'
            ELSE s.sucursal_nombre END AS sucursal,
       CASE WHEN GROUPING(r.codigo_ruta) = 1 AND GROUPING(s.sucursal_nombre) = 0 THEN N'Subtotal sucursal'
            ELSE r.codigo_ruta END AS ruta,
       SUM(f.ingreso_envio) AS ingresos, SUM(f.margen) AS margen
FROM dbo.fact_encomiendas f
JOIN dbo.dim_sucursal s ON s.sucursal_sk = f.sucursal_sk
JOIN dbo.dim_ruta     r ON r.ruta_sk     = f.ruta_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
WHERE t.anio = 2026
GROUP BY ROLLUP (s.region, s.sucursal_nombre, r.codigo_ruta)
ORDER BY GROUPING(s.region), s.region, GROUPING(s.sucursal_nombre), s.sucursal_nombre, GROUPING(r.codigo_ruta), r.codigo_ruta;
GO
-- G.2 CUBE: categoría de vehículo x trimestre (2026)
SELECT CASE WHEN GROUPING(v.categoria) = 1 THEN N'TODAS' ELSE v.categoria END AS categoria,
       CASE WHEN GROUPING(t.trimestre) = 1 THEN N'TODOS' ELSE CONCAT(N'T', t.trimestre) END AS trimestre,
       SUM(f.ingreso_envio) AS ingresos, SUM(f.margen) AS margen
FROM dbo.fact_encomiendas f
JOIN dbo.dim_vehiculo v ON v.vehiculo_sk = f.vehiculo_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
WHERE t.anio = 2026
GROUP BY CUBE (v.categoria, t.trimestre)
ORDER BY GROUPING_ID(v.categoria, t.trimestre), categoria, trimestre;
GO
-- G.3 Ventana: ranking de rentabilidad de rutas por año (RANK + % de participación)
WITH rutas AS (
    SELECT t.anio, r.codigo_ruta, SUM(f.ingreso_envio) AS ingresos, SUM(f.margen) AS margen
    FROM dbo.fact_encomiendas f
    JOIN dbo.dim_ruta r ON r.ruta_sk = f.ruta_sk
    JOIN dbo.dim_tiempo t ON t.tiempo_id = f.tiempo_id
    GROUP BY t.anio, r.codigo_ruta)
SELECT anio, RANK() OVER (PARTITION BY anio ORDER BY margen DESC) AS ranking, codigo_ruta, ingresos, margen,
       CAST(ingresos / SUM(ingresos) OVER (PARTITION BY anio) * 100 AS DECIMAL(6,2)) AS participacion_pct
FROM rutas ORDER BY anio, ranking;
GO
-- G.4 Ventana: evolución mensual con LAG (MoM) y acumulado del año
WITH m AS (
    SELECT t.anio, t.mes, t.anio_mes, SUM(f.ingreso_envio) AS ingresos
    FROM dbo.fact_encomiendas f JOIN dbo.dim_tiempo t ON t.tiempo_id = f.tiempo_id
    GROUP BY t.anio, t.mes, t.anio_mes)
SELECT anio_mes, ingresos,
       CAST((ingresos - LAG(ingresos) OVER (ORDER BY anio, mes)) / NULLIF(LAG(ingresos) OVER (ORDER BY anio, mes), 0) * 100 AS DECIMAL(7,2)) AS crecimiento_mom_pct,
       SUM(ingresos) OVER (PARTITION BY anio ORDER BY mes ROWS UNBOUNDED PRECEDING) AS acumulado_anio
FROM m ORDER BY anio, mes;
GO
-- G.5 SLICE (solo Jaén) y DICE (JAE/BGR x campaña cafetalera x flota pesada)
SELECT t.anio, SUM(f.cantidad_encomiendas) AS encomiendas, SUM(f.ingreso_envio) AS ingresos
FROM dbo.fact_encomiendas f
JOIN dbo.dim_sucursal s ON s.sucursal_sk = f.sucursal_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
WHERE s.sucursal_codigo = 'JAE'
GROUP BY t.anio ORDER BY t.anio;
SELECT s.sucursal_nombre, t.anio, SUM(f.ingreso_envio) AS ingresos, SUM(f.margen) AS margen
FROM dbo.fact_encomiendas f
JOIN dbo.dim_sucursal s ON s.sucursal_sk = f.sucursal_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
JOIN dbo.dim_vehiculo v ON v.vehiculo_sk = f.vehiculo_sk
WHERE s.sucursal_codigo IN ('JAE', 'BGR') AND t.temporada = N'Campaña cafetalera' AND v.categoria = N'Pesado'
GROUP BY s.sucursal_nombre, t.anio ORDER BY s.sucursal_nombre, t.anio;
GO
-- G.6 Rol_Analista_BI: lee la vista BI, pero la zona Staging está denegada (Msg 229)
EXECUTE AS USER = N'usr_analista_bi';
SELECT TOP (5) anio_mes, region, codigo_ruta, ingreso_envio, margen FROM dbo.vw_bi_encomiendas ORDER BY fecha DESC;
SELECT TOP (1) * FROM dbo.staging_encomiendas;
REVERT;
GO
