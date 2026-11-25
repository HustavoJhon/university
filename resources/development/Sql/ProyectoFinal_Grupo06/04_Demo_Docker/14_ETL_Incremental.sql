/* =============================================================================
   FASE 14 · ETL INCREMENTAL OLTP -> DATA WAREHOUSE (MERGE + CUARENTENA)
   Ejecutar como: sa                      ./demo.sh 14
   ============================================================================= */
USE dwh_AkilFlow;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 14.1 Estado ANTES: historial de ejecuciones del ETL ===';
SELECT ejecucion_id, CAST(inicio AS DATETIME2(0)) AS inicio, filas_staging, filas_rechazadas,
       hechos_insertados, hechos_actualizados, estado, mensaje
FROM dbo.etl_log ORDER BY ejecucion_id;
GO
PRINT N'=== 14.2 Cambio en la OLTP: una encomienda nueva en un viaje completado ===';
DECLARE @viaje INT = (SELECT TOP (1) viaje_id FROM AkilFlowOperaciones.dbo.viajes
                      WHERE estado = 'completado' ORDER BY fecha_salida DESC);
DECLARE @codigo VARCHAR(20) = CONCAT('AK-ETL-', FORMAT(SYSDATETIME(), 'MMddHHmmss'));
EXEC AkilFlowOperaciones.dbo.usp_registrar_encomienda
     @codigo_rastreo = @codigo, @viaje_id = @viaje, @usuario_registro_id = 9,
     @remitente = N'Molino San Ignacio E.I.R.L.', @documento_remitente = '20480009911',
     @destinatario = N'Carmen Vásquez Ruiz', @telefono_destinatario = '966778899',
     @descripcion = N'Carga de prueba ETL', @peso_kg = 300.00, @precio_envio = 180.00;
UPDATE AkilFlowOperaciones.dbo.encomiendas SET estado = 'entregada' WHERE codigo_rastreo = @codigo;
PRINT CONCAT(N'Encomienda ', @codigo, N' agregada al viaje ', @viaje);
GO
PRINT N'=== 14.3 Ejecutar el ETL (extrae -> staging -> valida -> MERGE en dimensiones y hechos) ===';
EXEC dbo.usp_etl_akilflow;
GO
PRINT N'=== 14.4 Estado DESPUÉS: la última ejecución inserta/actualiza solo lo nuevo ===';
SELECT TOP (2) ejecucion_id, CAST(inicio AS DATETIME2(0)) AS inicio, filas_staging, filas_rechazadas,
       hechos_insertados, hechos_actualizados, estado, mensaje
FROM dbo.etl_log ORDER BY ejecucion_id DESC;
GO
PRINT N'=== 14.5 La nueva encomienda ya está en la tabla de hechos ===';
SELECT TOP (3) codigo_rastreo, codigo_viaje, ingreso_envio, costo_asignado, margen, fecha_carga
FROM dbo.fact_encomiendas WHERE codigo_rastreo LIKE 'AK-ETL-%' ORDER BY fact_id DESC;
GO
PRINT N'=== 14.6 Conciliación staging vs fact y tabla de cuarentena ===';
SELECT 'Staging' AS origen, COUNT(*) AS filas, SUM(precio_envio) AS ingresos FROM dbo.staging_encomiendas
UNION ALL
SELECT 'Fact', SUM(cantidad_encomiendas), SUM(ingreso_envio) FROM dbo.fact_encomiendas;
SELECT * FROM dbo.etl_errores;
GO
PRINT N'>>> FASE 14 OK: carga incremental sin duplicados; los registros inválidos van a cuarentena.';
GO
