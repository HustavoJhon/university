/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 05_Consultas_OLAP_BI.sql
   Base    : dwh_AkilFlow
   Criterio: 5 - Consultas OLAP (ROLLUP / CUBE / Funciones de Ventana),
             vista BI para Power BI y seguridad Rol_Analista_BI
   -----------------------------------------------------------------------------
   Prerrequisito: script 04 ejecutado.
   Contenido:
     FASE 1. Vista desnormalizada vw_bi_encomiendas (fuente para Power BI)
     FASE 2. Consultas OLAP
             Q1 ROLLUP  - subtotales jerárquicos Región > Sucursal > Ruta
             Q2 CUBE    - matriz Categoría de vehículo x Trimestre
             Q3 VENTANA - crecimiento mensual (LAG), acumulado (SUM OVER), media móvil
             Q4 VENTANA - ranking de rentabilidad de rutas (RANK, % participación)
             Q5 VENTANA - ocupación de flota por vehículo (RANK + NTILE)
             Q6 VENTANA - Top 3 rutas por sucursal (ROW_NUMBER)
             Q7 DRILL-DOWN - Año > Trimestre > Mes de la ruta JAE-CIX
             Q8 SLICE   - solo la sucursal Jaén
             Q9 DICE    - JAE/BGR x campaña cafetalera x flota pesada
     FASE 3. Seguridad Rol_Analista_BI (GRANT vista/dims, DENY staging) + prueba
   ============================================================================= */
USE dwh_AkilFlow;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

/* =============================================================================
   FASE 1. VISTA BI DESNORMALIZADA (un solo objeto para Power BI / Excel)
   ============================================================================= */
CREATE OR ALTER VIEW dbo.vw_bi_encomiendas
AS
SELECT f.fact_id,
       f.codigo_rastreo,
       f.codigo_viaje,
       -- tiempo
       t.fecha, t.anio, t.trimestre, t.mes, t.nombre_mes, t.anio_mes, t.nombre_dia, t.temporada,
       -- sucursal de origen
       s.sucursal_codigo, s.sucursal_nombre, s.ciudad AS ciudad_origen, s.departamento, s.region,
       -- ruta
       r.codigo_ruta, r.descripcion_ruta, r.ciudad_destino, r.distancia_km, r.tipo_ruta,
       -- vehículo
       v.placa, v.marca, v.modelo, v.categoria AS categoria_vehiculo, v.capacidad_carga_kg,
       -- estado
       e.estado_codigo, e.estado_descripcion, e.es_estado_final,
       -- métricas
       f.cantidad_encomiendas, f.peso_kg, f.ingreso_envio, f.costo_asignado, f.margen,
       CAST(f.margen / NULLIF(f.ingreso_envio, 0) * 100 AS DECIMAL(7,2)) AS margen_pct
FROM dbo.fact_encomiendas      f
JOIN dbo.dim_tiempo            t ON t.tiempo_id   = f.tiempo_id
JOIN dbo.dim_sucursal          s ON s.sucursal_sk = f.sucursal_sk
JOIN dbo.dim_ruta              r ON r.ruta_sk     = f.ruta_sk
JOIN dbo.dim_vehiculo          v ON v.vehiculo_sk = f.vehiculo_sk
JOIN dbo.dim_estado_encomienda e ON e.estado_sk   = f.estado_sk;
GO
SELECT TOP (5) * FROM dbo.vw_bi_encomiendas ORDER BY fecha DESC;
GO
PRINT N'FASE 1 OK: vista dbo.vw_bi_encomiendas lista para Power BI.';
GO

/* =============================================================================
   FASE 2. CONSULTAS ANALÍTICAS OLAP
   ============================================================================= */

/* -----------------------------------------------------------------------------
   Q1. ROLLUP - Subtotales jerárquicos (año 2026)
   Pregunta de negocio: ¿cuánto aporta cada región, cada sucursal de origen
   y cada ruta? ROLLUP(a, b, c) genera los niveles (a,b,c) (a,b) (a) ().
   GROUPING() = 1 identifica la fila de subtotal.
   ----------------------------------------------------------------------------- */
SELECT CASE WHEN GROUPING(s.region)          = 1 THEN N'** TOTAL EMPRESA **' ELSE s.region END          AS region,
       CASE WHEN GROUPING(s.sucursal_nombre) = 1 AND GROUPING(s.region) = 0 THEN N'* Subtotal región *'
            ELSE s.sucursal_nombre END                                                                  AS sucursal_origen,
       CASE WHEN GROUPING(r.codigo_ruta)     = 1 AND GROUPING(s.sucursal_nombre) = 0 THEN N'Subtotal sucursal'
            ELSE r.codigo_ruta END                                                                      AS ruta,
       SUM(f.cantidad_encomiendas) AS encomiendas,
       SUM(f.ingreso_envio)        AS ingresos,
       SUM(f.costo_asignado)       AS costos,
       SUM(f.margen)               AS margen,
       CAST(SUM(f.margen) / NULLIF(SUM(f.ingreso_envio), 0) * 100 AS DECIMAL(6,2)) AS margen_pct
FROM dbo.fact_encomiendas f
JOIN dbo.dim_sucursal s ON s.sucursal_sk = f.sucursal_sk
JOIN dbo.dim_ruta     r ON r.ruta_sk     = f.ruta_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
WHERE t.anio = 2026
GROUP BY ROLLUP (s.region, s.sucursal_nombre, r.codigo_ruta)
ORDER BY GROUPING(s.region), s.region, GROUPING(s.sucursal_nombre), s.sucursal_nombre,
         GROUPING(r.codigo_ruta), r.codigo_ruta;
GO

/* -----------------------------------------------------------------------------
   Q2. CUBE - Matriz multidimensional Categoría de vehículo x Trimestre (2026)
   CUBE(a, b) genera TODAS las combinaciones: (a,b) (a) (b) ().
   GROUPING_ID devuelve el nivel de agregación en un solo número.
   ----------------------------------------------------------------------------- */
SELECT GROUPING_ID(v.categoria, t.trimestre)                          AS nivel,   -- 0 detalle, 1 x categoría, 2 x trimestre, 3 total
       CASE WHEN GROUPING(v.categoria) = 1 THEN N'TODAS' ELSE v.categoria END      AS categoria_vehiculo,
       CASE WHEN GROUPING(t.trimestre) = 1 THEN N'TODOS' ELSE CONCAT(N'T', t.trimestre) END AS trimestre,
       COUNT(DISTINCT f.codigo_viaje) AS viajes,
       SUM(f.peso_kg)                 AS toneladas_kg,
       SUM(f.ingreso_envio)           AS ingresos,
       SUM(f.margen)                  AS margen
FROM dbo.fact_encomiendas f
JOIN dbo.dim_vehiculo v ON v.vehiculo_sk = f.vehiculo_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
WHERE t.anio = 2026
GROUP BY CUBE (v.categoria, t.trimestre)
ORDER BY nivel, categoria_vehiculo, trimestre;
GO

/* -----------------------------------------------------------------------------
   Q3. FUNCIONES DE VENTANA - Evolución mensual
   LAG(...,1)  : ingreso del mes anterior -> % crecimiento mes a mes (MoM)
   LAG(...,12) : mismo mes del año anterior -> % crecimiento interanual (YoY)
   SUM() OVER (PARTITION BY anio ORDER BY mes) : acumulado del año (YTD)
   AVG() OVER (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) : media móvil 3 meses
   ----------------------------------------------------------------------------- */
WITH mensual AS (
    SELECT t.anio, t.mes, t.anio_mes, t.temporada,
           SUM(f.cantidad_encomiendas) AS encomiendas,
           SUM(f.ingreso_envio)        AS ingresos,
           SUM(f.margen)               AS margen
    FROM dbo.fact_encomiendas f
    JOIN dbo.dim_tiempo t ON t.tiempo_id = f.tiempo_id
    GROUP BY t.anio, t.mes, t.anio_mes, t.temporada
)
SELECT anio_mes, temporada, encomiendas, ingresos, margen,
       LAG(ingresos, 1) OVER (ORDER BY anio, mes)                                       AS ingreso_mes_anterior,
       CAST((ingresos - LAG(ingresos, 1) OVER (ORDER BY anio, mes))
            / NULLIF(LAG(ingresos, 1) OVER (ORDER BY anio, mes), 0) * 100 AS DECIMAL(7,2)) AS crecimiento_mom_pct,
       CAST((ingresos - LAG(ingresos, 12) OVER (ORDER BY anio, mes))
            / NULLIF(LAG(ingresos, 12) OVER (ORDER BY anio, mes), 0) * 100 AS DECIMAL(7,2)) AS crecimiento_yoy_pct,
       SUM(ingresos) OVER (PARTITION BY anio ORDER BY mes
                           ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW)            AS ingreso_acumulado_anio,
       CAST(AVG(ingresos) OVER (ORDER BY anio, mes
                                ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS DECIMAL(12,2)) AS media_movil_3m
FROM mensual
ORDER BY anio, mes;
GO

/* -----------------------------------------------------------------------------
   Q4. FUNCIONES DE VENTANA - Ranking de rentabilidad de rutas por año
   RANK() reinicia en cada año (PARTITION BY) y deja huecos en empates.
   SUM() OVER (PARTITION BY anio) calcula el % de participación sin subconsultas.
   ----------------------------------------------------------------------------- */
WITH rutas AS (
    SELECT t.anio, r.codigo_ruta, r.descripcion_ruta, r.tipo_ruta,
           SUM(f.ingreso_envio) AS ingresos,
           SUM(f.margen)        AS margen
    FROM dbo.fact_encomiendas f
    JOIN dbo.dim_ruta   r ON r.ruta_sk   = f.ruta_sk
    JOIN dbo.dim_tiempo t ON t.tiempo_id = f.tiempo_id
    GROUP BY t.anio, r.codigo_ruta, r.descripcion_ruta, r.tipo_ruta
)
SELECT anio,
       RANK() OVER (PARTITION BY anio ORDER BY margen DESC)                          AS ranking_margen,
       codigo_ruta, descripcion_ruta, tipo_ruta, ingresos, margen,
       CAST(margen / NULLIF(ingresos, 0) * 100 AS DECIMAL(6,2))                      AS margen_pct,
       CAST(ingresos / SUM(ingresos) OVER (PARTITION BY anio) * 100 AS DECIMAL(6,2)) AS participacion_ingresos_pct,
       DENSE_RANK() OVER (PARTITION BY anio ORDER BY ingresos DESC)                  AS ranking_ingresos
FROM rutas
ORDER BY anio, ranking_margen;
GO

/* -----------------------------------------------------------------------------
   Q5. FUNCIONES DE VENTANA - Ocupación de flota (2026)
   Ocupación por viaje = peso transportado / capacidad del vehículo.
   NTILE(3) clasifica la flota en terciles: Alta / Media / Baja utilización.
   ----------------------------------------------------------------------------- */
WITH por_viaje AS (
    SELECT v.placa, v.marca, v.categoria, v.capacidad_carga_kg, f.codigo_viaje,
           SUM(f.peso_kg) AS peso_viaje
    FROM dbo.fact_encomiendas f
    JOIN dbo.dim_vehiculo v ON v.vehiculo_sk = f.vehiculo_sk
    JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
    WHERE t.anio = 2026
    GROUP BY v.placa, v.marca, v.categoria, v.capacidad_carga_kg, f.codigo_viaje
), por_vehiculo AS (
    SELECT placa, marca, categoria, capacidad_carga_kg,
           COUNT(*)                                                   AS viajes,
           CAST(AVG(peso_viaje / capacidad_carga_kg) * 100 AS DECIMAL(6,2)) AS ocupacion_promedio_pct
    FROM por_viaje
    GROUP BY placa, marca, categoria, capacidad_carga_kg
)
SELECT RANK() OVER (ORDER BY ocupacion_promedio_pct DESC) AS ranking,
       placa, marca, categoria, capacidad_carga_kg, viajes, ocupacion_promedio_pct,
       CHOOSE(NTILE(3) OVER (ORDER BY ocupacion_promedio_pct DESC), N'Alta', N'Media', N'Baja') AS nivel_utilizacion
FROM por_vehiculo
ORDER BY ranking;
GO

/* -----------------------------------------------------------------------------
   Q6. FUNCIONES DE VENTANA - Top 3 rutas por sucursal de origen (2026)
   ROW_NUMBER() + filtro en CTE: patrón "Top-N por grupo".
   ----------------------------------------------------------------------------- */
WITH rutas_sucursal AS (
    SELECT s.sucursal_nombre, r.codigo_ruta, r.descripcion_ruta,
           SUM(f.cantidad_encomiendas) AS encomiendas,
           SUM(f.ingreso_envio)        AS ingresos,
           SUM(f.margen)               AS margen
    FROM dbo.fact_encomiendas f
    JOIN dbo.dim_sucursal s ON s.sucursal_sk = f.sucursal_sk
    JOIN dbo.dim_ruta     r ON r.ruta_sk     = f.ruta_sk
    JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
    WHERE t.anio = 2026
    GROUP BY s.sucursal_nombre, r.codigo_ruta, r.descripcion_ruta
), ranking AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY sucursal_nombre ORDER BY ingresos DESC) AS posicion
    FROM rutas_sucursal
)
SELECT sucursal_nombre, posicion, codigo_ruta, descripcion_ruta, encomiendas, ingresos, margen
FROM ranking
WHERE posicion <= 3
ORDER BY sucursal_nombre, posicion;
GO
/* -----------------------------------------------------------------------------
   Q7. DRILL-DOWN (Laboratorio 14) - de lo general a lo detallado
   Año -> Trimestre -> Mes de la ruta estrella JAE-CIX. Cada nivel "baja" un
   escalón en la jerarquía de dim_tiempo (el inverso es ROLL-UP, ver Q1).
   ----------------------------------------------------------------------------- */
SELECT t.anio,
       CASE WHEN GROUPING(t.trimestre) = 1 THEN N'Total año' ELSE CONCAT(N'T', t.trimestre) END AS trimestre,
       CASE WHEN GROUPING(t.trimestre)  = 1 THEN N'(todos)'
            WHEN GROUPING(t.nombre_mes) = 1 THEN N'Total trimestre'
            ELSE t.nombre_mes END                                                            AS mes,
       SUM(f.cantidad_encomiendas) AS encomiendas,
       SUM(f.ingreso_envio)        AS ingresos,
       SUM(f.margen)               AS margen
FROM dbo.fact_encomiendas f
JOIN dbo.dim_tiempo t ON t.tiempo_id = f.tiempo_id
JOIN dbo.dim_ruta   r ON r.ruta_sk   = f.ruta_sk
WHERE r.codigo_ruta = 'JAE-CIX'
GROUP BY t.anio, ROLLUP (t.trimestre, (t.mes, t.nombre_mes))
ORDER BY t.anio, GROUPING(t.trimestre), t.trimestre, GROUPING(t.mes), t.mes;
GO

/* -----------------------------------------------------------------------------
   Q8. SLICE (Laboratorio 14) - "rebanada" fijando UNA dimensión
   Solo la sucursal de origen Jaén (sucursal_codigo = 'JAE'), año 2026:
   ¿qué productos de negocio (rutas) y qué meses mueve la sede central?
   ----------------------------------------------------------------------------- */
SELECT t.anio_mes, r.codigo_ruta,
       SUM(f.cantidad_encomiendas) AS encomiendas,
       SUM(f.peso_kg)              AS peso_kg,
       SUM(f.ingreso_envio)        AS ingresos
FROM dbo.fact_encomiendas f
JOIN dbo.dim_sucursal s ON s.sucursal_sk = f.sucursal_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
JOIN dbo.dim_ruta     r ON r.ruta_sk     = f.ruta_sk
WHERE s.sucursal_codigo = 'JAE'            -- SLICE: una sola dimensión fijada
  AND t.anio = 2026
GROUP BY t.anio_mes, r.codigo_ruta
ORDER BY t.anio_mes, r.codigo_ruta;
GO

/* -----------------------------------------------------------------------------
   Q9. DICE (Laboratorio 14) - "sub-cubo" filtrando VARIAS dimensiones a la vez
   Sucursales JAE y BGR x Campaña cafetalera x vehículos Pesados:
   ¿la flota pesada rinde en la temporada del café en las agencias cafetaleras?
   ----------------------------------------------------------------------------- */
SELECT s.sucursal_nombre, t.anio, v.categoria,
       COUNT(DISTINCT f.codigo_viaje) AS viajes,
       SUM(f.peso_kg)                 AS peso_kg,
       SUM(f.ingreso_envio)           AS ingresos,
       SUM(f.margen)                  AS margen
FROM dbo.fact_encomiendas f
JOIN dbo.dim_sucursal s ON s.sucursal_sk = f.sucursal_sk
JOIN dbo.dim_tiempo   t ON t.tiempo_id   = f.tiempo_id
JOIN dbo.dim_vehiculo v ON v.vehiculo_sk = f.vehiculo_sk
WHERE s.sucursal_codigo IN ('JAE', 'BGR')         -- dimensión 1
  AND t.temporada = N'Campaña cafetalera'          -- dimensión 2
  AND v.categoria = N'Pesado'                      -- dimensión 3
GROUP BY s.sucursal_nombre, t.anio, v.categoria
ORDER BY s.sucursal_nombre, t.anio;
GO
PRINT N'FASE 2 OK: ROLLUP, CUBE, funciones de ventana, DRILL-DOWN, SLICE y DICE ejecutadas.';
GO

/* =============================================================================
   FASE 3. SEGURIDAD DEL DWH - Rol_Analista_BI
   El analista consume la vista y las dimensiones, pero NO la zona Staging
   (datos crudos, sin limpiar ni conciliar) ni la bitácora del ETL.
   ============================================================================= */
USE master;
GO
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_analista_bi')
    CREATE LOGIN login_analista_bi WITH PASSWORD = N'Akil#AnalistaBI2026', SID = 0x1D87A11C44BB334D8F1E7EE4726495B7, DEFAULT_DATABASE = dwh_AkilFlow,
                                        CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO
USE dwh_AkilFlow;
GO
IF USER_ID(N'usr_analista_bi') IS NULL
    CREATE USER usr_analista_bi FOR LOGIN login_analista_bi WITH DEFAULT_SCHEMA = dbo;
IF DATABASE_PRINCIPAL_ID(N'Rol_Analista_BI') IS NULL
    CREATE ROLE Rol_Analista_BI AUTHORIZATION dbo;
GO
GRANT SELECT ON SCHEMA::dbo                TO Rol_Analista_BI;   -- vista, dimensiones y hechos
DENY  SELECT ON dbo.staging_encomiendas    TO Rol_Analista_BI;   -- zona cruda: bloqueada
DENY  SELECT ON dbo.etl_log                TO Rol_Analista_BI;
DENY  INSERT, UPDATE, DELETE ON SCHEMA::dbo TO Rol_Analista_BI;  -- DWH de solo lectura
DENY  EXECUTE ON dbo.usp_etl_akilflow      TO Rol_Analista_BI;
GO
IF IS_ROLEMEMBER(N'Rol_Analista_BI', N'usr_analista_bi') = 0
    ALTER ROLE Rol_Analista_BI ADD MEMBER usr_analista_bi;
GO

-- 3.1 Prueba de seguridad
EXECUTE AS USER = N'usr_analista_bi';
    SELECT anio, region, SUM(ingreso_envio) AS ingresos, SUM(margen) AS margen
    FROM dbo.vw_bi_encomiendas
    GROUP BY anio, region
    ORDER BY anio, ingresos DESC;
    PRINT N'Analista BI -> SELECT sobre vw_bi_encomiendas PERMITIDO';
    BEGIN TRY
        SELECT TOP (1) * FROM dbo.staging_encomiendas;
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Analista BI SELECT staging -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
    BEGIN TRY
        EXEC dbo.usp_etl_akilflow;
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Analista BI EXEC ETL -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
REVERT;
GO

-- 3.2 Permisos efectivos del rol
SELECT pr.name AS rol, pe.state_desc AS accion, pe.permission_name AS permiso, pe.class_desc AS ambito,
       COALESCE(OBJECT_NAME(pe.major_id), SCHEMA_NAME(pe.major_id)) AS objeto
FROM sys.database_permissions pe
JOIN sys.database_principals  pr ON pr.principal_id = pe.grantee_principal_id
WHERE pr.name = N'Rol_Analista_BI'
ORDER BY accion DESC, objeto;
GO

/* --- Conexión desde Power BI Desktop ---------------------------------------
   Obtener datos > SQL Server > Servidor: <su instancia> > Base: dwh_AkilFlow
   Modo: Importar > Autenticación "Base de datos": login_analista_bi
   Seleccionar solo dbo.vw_bi_encomiendas.
------------------------------------------------------------------------------ */
PRINT N'=== SCRIPT 05 FINALIZADO: OLAP + vista BI + Rol_Analista_BI operativos. ===';
GO
