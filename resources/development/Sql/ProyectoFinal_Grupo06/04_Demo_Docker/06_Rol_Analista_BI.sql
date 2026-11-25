/* =============================================================================
   FASE 6 · ROL ANALISTA BI (Data Warehouse)
   Ejecutar CONECTADO COMO:  login_analista_bi / Akil#AnalistaBI2026  (base dwh_AkilFlow)
                             ./demo.sh 06
   ============================================================================= */
SET NOCOUNT ON;
GO
PRINT N'=== ¿Quién soy? ===';
SELECT SUSER_NAME() AS login_conectado, USER_NAME() AS usuario_bd, DB_NAME() AS base,
       IS_ROLEMEMBER(N'Rol_Analista_BI') AS es_rol_analista_bi;
GO
PRINT N'';
PRINT N'(OK 1) Vista BI: ingresos y margen por año y región -> PERMITIDO';
SELECT anio, region, SUM(cantidad_encomiendas) AS encomiendas,
       SUM(ingreso_envio) AS ingresos, SUM(margen) AS margen
FROM dbo.vw_bi_encomiendas
GROUP BY anio, region ORDER BY anio, ingresos DESC;
GO
PRINT N'(OK 2) Dimensiones y tabla de hechos -> PERMITIDO';
SELECT sucursal_codigo, sucursal_nombre, region FROM dbo.dim_sucursal;
SELECT COUNT(*) AS filas_fact, SUM(ingreso_envio) AS ingresos_totales FROM dbo.fact_encomiendas;
GO

PRINT N'';
PRINT N'(DENEGADO 3) Zona staging (datos crudos) -> ESPERADO: Msg 229';
SELECT TOP (1) * FROM dbo.staging_encomiendas;
GO
PRINT N'(DENEGADO 4) Bitácora del ETL -> ESPERADO: Msg 229';
SELECT TOP (1) * FROM dbo.etl_log;
GO
PRINT N'(DENEGADO 5) Ejecutar el ETL -> ESPERADO: Msg 229';
EXEC dbo.usp_etl_akilflow;
GO
PRINT N'(DENEGADO 6) Modificar un hecho -> ESPERADO: Msg 229';
UPDATE dbo.fact_encomiendas SET margen = 0 WHERE fact_id = 1;
GO
PRINT N'(DENEGADO 7) Entrar a la base OLTP (no tiene usuario allí: capa 2) -> ESPERADO: Msg 916';
USE AkilFlowOperaciones;
GO
PRINT N'>>> FASE 6 OK: el analista consume la vista BI; staging, ETL y la base OLTP están cerradas.';
GO
