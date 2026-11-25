/* =============================================================================
   FASE 15 · CONSULTAS OLAP SOBRE EL DATA WAREHOUSE
   Ejecutar como: sa                      ./demo.sh 15
   (ROLLUP, CUBE, RANK, LAG, SLICE y DICE)
   ============================================================================= */
SET NOCOUNT ON;
GO
USE dwh_AkilFlow;
GO
PRINT N'=== 15.1 ROLLUP: Región > Sucursal > Ruta (2026) con subtotales ===';
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
PRINT N'=== 15.2 CUBE: categoría de vehículo x trimestre (2026) ===';
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
PRINT N'=== 15.3 Ventana: ranking de rentabilidad de rutas por año (RANK + % de participación) ===';
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
PRINT N'=== 15.4 Ventana: evolución mensual con LAG (MoM) y acumulado del año ===';
WITH m AS (
    SELECT t.anio, t.mes, t.anio_mes, SUM(f.ingreso_envio) AS ingresos
    FROM dbo.fact_encomiendas f JOIN dbo.dim_tiempo t ON t.tiempo_id = f.tiempo_id
    GROUP BY t.anio, t.mes, t.anio_mes)
SELECT anio_mes, ingresos,
       CAST((ingresos - LAG(ingresos) OVER (ORDER BY anio, mes)) / NULLIF(LAG(ingresos) OVER (ORDER BY anio, mes), 0) * 100 AS DECIMAL(7,2)) AS crecimiento_mom_pct,
       SUM(ingresos) OVER (PARTITION BY anio ORDER BY mes ROWS UNBOUNDED PRECEDING) AS acumulado_anio
FROM m ORDER BY anio, mes;
GO
PRINT N'=== 15.5 SLICE (solo Jaén) y DICE (JAE/BGR x campaña cafetalera x flota pesada) ===';
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
PRINT N'>>> FASE 15 OK: análisis multidimensional por región, sucursal, ruta, vehículo y tiempo.';
GO
