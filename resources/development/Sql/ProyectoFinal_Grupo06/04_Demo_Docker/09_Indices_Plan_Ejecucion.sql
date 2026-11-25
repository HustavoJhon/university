/* =============================================================================
   FASE 9 · ÍNDICES Y PLAN DE EJECUCIÓN (ANTES vs DESPUÉS)
   Ejecutar como: sa                      ./demo.sh 09
   En sqlcmd el plan se muestra como texto (SHOWPLAN_TEXT);
   en SSMS/Azure Data Studio se puede ver gráfico con Ctrl + M.
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 9.1 Índices clúster y no clúster del modelo ===';
SELECT t.name AS tabla, i.name AS indice, i.type_desc AS tipo, i.is_unique AS unico,
       i.has_filter AS filtrado, i.filter_definition AS filtro
FROM sys.indexes i JOIN sys.tables t ON t.object_id = i.object_id
WHERE i.type > 0 ORDER BY t.name, i.type, i.name;
GO

PRINT N'=== 9.2 PLAN ANTES: se fuerza el índice clúster -> Clustered Index Scan (lee toda la tabla) ===';
GO
SET SHOWPLAN_TEXT ON;
GO
SELECT codigo_rastreo, fecha_registro, peso_kg, precio_envio, estado
FROM dbo.encomiendas WITH (INDEX (PK_encomiendas))
WHERE estado = 'entregada' AND fecha_registro >= '2026-11-01';
GO
SET SHOWPLAN_TEXT OFF;
GO
PRINT N'=== 9.3 PLAN DESPUÉS: el optimizador usa IX_encomiendas_estado_fecha -> Index Seek ===';
GO
SET SHOWPLAN_TEXT ON;
GO
SELECT codigo_rastreo, fecha_registro, peso_kg, precio_envio, estado
FROM dbo.encomiendas
WHERE estado = 'entregada' AND fecha_registro >= '2026-11-01';
GO
SET SHOWPLAN_TEXT OFF;
GO

PRINT N'=== 9.4 Lecturas lógicas (mirar "logical reads" en los mensajes) ===';
SET STATISTICS IO ON;
GO
PRINT N'--- ANTES (scan) ---';
SELECT COUNT(*) AS filas FROM dbo.encomiendas WITH (INDEX (PK_encomiendas))
WHERE estado = 'entregada' AND fecha_registro >= '2026-11-01';
PRINT N'--- DESPUÉS (seek) ---';
SELECT COUNT(*) AS filas FROM dbo.encomiendas
WHERE estado = 'entregada' AND fecha_registro >= '2026-11-01';
GO
SET STATISTICS IO OFF;
GO
PRINT N'>>> FASE 9 OK: con el índice no clúster la consulta pasa de Scan a Seek y lee muchas menos páginas.';
GO
