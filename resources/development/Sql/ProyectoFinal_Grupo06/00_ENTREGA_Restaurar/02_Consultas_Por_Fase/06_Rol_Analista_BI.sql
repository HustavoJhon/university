/* =============================================================================
   FASE 6 · ROL ANALISTA BI (Data Warehouse)
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5.
   El script se convierte en login_analista_bi con EXECUTE AS LOGIN (prueba las 2 capas:
   login de instancia + usuario de base) y al final vuelve a su sesión con REVERT.
   Si ejecuta por partes, ejecute SIEMPRE el bloque EXECUTE AS del inicio y el REVERT del final.
   Alternativa: conectarse con autenticación SQL (login_analista_bi / Akil#AnalistaBI2026) en modo mixto
   y ejecutar desde la línea "¿Quién soy?" (sin EXECUTE AS ni REVERT).
   RECOMENDADO en SSMS: Ctrl + T (Resultados en texto) para ver en orden los
   títulos, las tablas y los mensajes de error. Ctrl + D vuelve a cuadrícula.
   ============================================================================= */
SET NOCOUNT ON;
GO
REVERT;   -- por seguridad: limpia una suplantación anterior (no falla si no hay ninguna)
GO
USE dwh_AkilFlow;
GO
EXECUTE AS LOGIN = N'login_analista_bi';   -- desde aquí todo se ejecuta como login_analista_bi
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
REVERT;   -- vuelve a la sesión original
GO
SELECT SUSER_NAME() AS sesion_restaurada;
GO
