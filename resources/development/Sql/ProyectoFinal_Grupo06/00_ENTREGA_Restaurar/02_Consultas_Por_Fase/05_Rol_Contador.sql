/* =============================================================================
   FASE 5 · ROL CONTADOR (finanzas)
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5.
   El script se convierte en login_contador con EXECUTE AS LOGIN (prueba las 2 capas:
   login de instancia + usuario de base) y al final vuelve a su sesión con REVERT.
   Si ejecuta por partes, ejecute SIEMPRE el bloque EXECUTE AS del inicio y el REVERT del final.
   Alternativa: conectarse con autenticación SQL (login_contador / Akil#Contador2026) en modo mixto
   y ejecutar desde la línea "¿Quién soy?" (sin EXECUTE AS ni REVERT).
   RECOMENDADO en SSMS: Ctrl + T (Resultados en texto) para ver en orden los
   títulos, las tablas y los mensajes de error. Ctrl + D vuelve a cuadrícula.
   ============================================================================= */
SET NOCOUNT ON;
GO
REVERT;   -- por seguridad: limpia una suplantación anterior (no falla si no hay ninguna)
GO
USE AkilFlowOperaciones;
GO
EXECUTE AS LOGIN = N'login_contador';   -- desde aquí todo se ejecuta como login_contador
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
REVERT;   -- vuelve a la sesión original
GO
SELECT SUSER_NAME() AS sesion_restaurada;
GO
