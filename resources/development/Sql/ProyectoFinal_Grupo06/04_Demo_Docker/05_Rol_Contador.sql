/* =============================================================================
   FASE 5 · ROL CONTADOR (finanzas)
   Ejecutar CONECTADO COMO:  login_contador / Akil#Contador2026
                             ./demo.sh 05
   ============================================================================= */
SET NOCOUNT ON;
GO
PRINT N'=== ¿Quién soy? ===';
SELECT SUSER_NAME() AS login_conectado, USER_NAME() AS usuario_bd, DB_NAME() AS base,
       IS_ROLEMEMBER(N'Rol_Contador') AS es_rol_contador;
GO
PRINT N'';
PRINT N'(OK 1) Vista financiera: ingresos, costos y margen por viaje -> PERMITIDO';
SELECT TOP (5) codigo_viaje, codigo_ruta, fecha, cantidad_encomiendas, ingresos, costo_estimado, margen_bruto
FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;
GO
PRINT N'(OK 2) Resumen por ruta -> PERMITIDO';
SELECT codigo_ruta, COUNT(*) AS viajes, SUM(ingresos) AS ingresos, SUM(margen_bruto) AS margen
FROM dbo.vw_resumen_financiero_viajes GROUP BY codigo_ruta ORDER BY margen DESC;
GO
PRINT N'(OK 3) Columnas NO sensibles de encomiendas -> PERMITIDO';
SELECT TOP (3) codigo_rastreo, peso_kg, precio_envio, estado FROM dbo.encomiendas ORDER BY encomienda_id;
GO

PRINT N'';
PRINT N'(DENEGADO 4) Columna con datos personales (remitente_cif) -> ESPERADO: Msg 230';
SELECT TOP (1) codigo_rastreo, remitente_cif FROM dbo.encomiendas;
GO
PRINT N'(DENEGADO 5) SELECT * (incluye columnas cifradas) -> ESPERADO: Msg 230';
SELECT TOP (1) * FROM dbo.encomiendas;
GO
PRINT N'(DENEGADO 6) Datos del personal -> ESPERADO: Msg 229';
SELECT TOP (1) correo FROM dbo.usuarios_sistema;
GO
PRINT N'(DENEGADO 7) Modificar el costo de un viaje -> ESPERADO: Msg 229';
UPDATE dbo.viajes SET costo_estimado = 0 WHERE viaje_id = 1;
GO
PRINT N'(DENEGADO 8) Ejecutar el SP de consulta -> ESPERADO: Msg 229';
EXEC dbo.usp_consultar_encomienda @codigo_rastreo = 'AK20261125PEND01';
GO
PRINT N'>>> FASE 5 OK: el contador ve montos y márgenes, nunca datos personales y no modifica nada.';
GO
