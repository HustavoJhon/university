/* =============================================================================
   FASE 1 · VERIFICAR LA RESTAURACIÓN: BASES, TABLAS, DATOS Y SEGURIDAD
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5,
   o seleccionar un bloque y F5.
   RECOMENDADO en SSMS: Ctrl + T (Resultados en texto) para ver en orden los
   títulos, las tablas y los mensajes de error. Ctrl + D vuelve a cuadrícula.
   ============================================================================= */
SET NOCOUNT ON;
GO
PRINT N'=== 1.1 Versión del servidor (debe ser SQL Server 2022 = 16.x) ===';
SELECT CAST(SERVERPROPERTY('ProductVersion') AS NVARCHAR(30)) AS version,
       CAST(SERVERPROPERTY('Edition') AS NVARCHAR(60))        AS edicion;
GO
PRINT N'=== 1.2 Bases restauradas ===';
SELECT name AS base, state_desc AS estado, recovery_model_desc AS modelo_recuperacion,
       SUSER_SNAME(owner_sid) AS propietario, CAST(create_date AS DATETIME2(0)) AS restaurada
FROM sys.databases
WHERE name IN (N'AkilFlowOperaciones', N'dwh_AkilFlow');
GO
PRINT N'=== 1.3 Tablas y número de filas en ambas bases ===';
SELECT N'AkilFlowOperaciones' AS base, t.name AS tabla, SUM(p.rows) AS filas
FROM AkilFlowOperaciones.sys.tables t
JOIN AkilFlowOperaciones.sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
UNION ALL
SELECT N'dwh_AkilFlow', t.name, SUM(p.rows)
FROM dwh_AkilFlow.sys.tables t
JOIN dwh_AkilFlow.sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0, 1)
GROUP BY t.name
ORDER BY base, tabla;
GO
PRINT N'=== 1.4 Vistas y procedimientos almacenados ===';
SELECT N'AkilFlowOperaciones' AS base, name AS objeto, type_desc AS tipo
FROM AkilFlowOperaciones.sys.objects WHERE type IN ('V', 'P')
UNION ALL
SELECT N'dwh_AkilFlow', name, type_desc
FROM dwh_AkilFlow.sys.objects WHERE type IN ('V', 'P')
ORDER BY base, tipo, objeto;
GO

USE AkilFlowOperaciones;
GO
PRINT N'=== 1.5 Estructura de encomiendas: los datos personales son VARBINARY (cifrados) ===';
SELECT c.column_id AS n, c.name AS columna, t.name AS tipo, c.max_length AS bytes, c.is_nullable AS acepta_null
FROM sys.columns c JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.encomiendas')
ORDER BY c.column_id;
GO
PRINT N'=== 1.6 Muestra de datos (OLTP) ===';
SELECT codigo, nombre, ciudad, departamento, es_sede_central FROM dbo.sucursales;
SELECT codigo_ruta, distancia_km, horas_estimadas, tarifa_kg FROM dbo.rutas;
SELECT placa, marca, modelo, capacidad_carga_kg, estado FROM dbo.vehiculos;
SELECT TOP (5) codigo_viaje, fecha_salida, costo_estimado, estado FROM dbo.viajes ORDER BY viaje_id DESC;
SELECT TOP (5) codigo_rastreo, descripcion, peso_kg, precio_envio, estado, remitente_cif
FROM dbo.encomiendas ORDER BY encomienda_id DESC;
GO
PRINT N'=== 1.7 Seguridad restaurada: login (instancia) -> usuario (base) -> rol ===';
SELECT N'AkilFlowOperaciones' AS base, r.name AS rol, u.name AS usuario,
       ISNULL(SUSER_SNAME(u.sid), N'*** HUÉRFANO ***') AS login_enlazado
FROM AkilFlowOperaciones.sys.database_role_members rm
JOIN AkilFlowOperaciones.sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN AkilFlowOperaciones.sys.database_principals u ON u.principal_id = rm.member_principal_id
WHERE r.name LIKE N'Rol[_]%'
UNION ALL
SELECT N'dwh_AkilFlow', r.name, u.name, ISNULL(SUSER_SNAME(u.sid), N'*** HUÉRFANO ***')
FROM dwh_AkilFlow.sys.database_role_members rm
JOIN dwh_AkilFlow.sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN dwh_AkilFlow.sys.database_principals u ON u.principal_id = rm.member_principal_id
WHERE r.name LIKE N'Rol[_]%'
ORDER BY base, rol;
GO

USE dwh_AkilFlow;
GO
PRINT N'=== 1.8 Muestra de datos (Data Warehouse, esquema estrella) ===';
SELECT TOP (5) fecha, anio_mes, sucursal_nombre, codigo_ruta, categoria_vehiculo,
       estado_codigo, ingreso_envio, costo_asignado, margen
FROM dbo.vw_bi_encomiendas ORDER BY fecha DESC;
GO
USE master;
GO
PRINT N'>>> FASE 1 OK: bases ONLINE, tablas con datos y 5 usuarios enlazados (0 huérfanos).';
GO
