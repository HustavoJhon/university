/* =============================================================================
   FASE 3 · ROL SUPERVISOR (jefe de operaciones)
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5.
   El script se convierte en login_supervisor con EXECUTE AS LOGIN (prueba las 2 capas:
   login de instancia + usuario de base) y al final vuelve a su sesión con REVERT.
   Si ejecuta por partes, ejecute SIEMPRE el bloque EXECUTE AS del inicio y el REVERT del final.
   Alternativa: conectarse con autenticación SQL (login_supervisor / Akil#Supervisor2026) en modo mixto
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
EXECUTE AS LOGIN = N'login_supervisor';   -- desde aquí todo se ejecuta como login_supervisor
GO
PRINT N'=== ¿Quién soy? ===';
SELECT SUSER_NAME() AS login_conectado, USER_NAME() AS usuario_bd, DB_NAME() AS base,
       IS_ROLEMEMBER(N'Rol_Supervisor') AS es_rol_supervisor;
GO
PRINT N'';
PRINT N'(OK 1) Leer cualquier tabla, incluido el personal -> PERMITIDO';
SELECT COUNT(*) AS total_viajes FROM dbo.viajes;
SELECT TOP (3) nombre_completo, cargo, correo FROM dbo.usuarios_sistema;
GO
PRINT N'(OK 2) Consultar una encomienda con datos personales descifrados (SP) -> PERMITIDO';
EXEC dbo.usp_consultar_encomienda @codigo_rastreo = 'AK20261125PEND01';
GO
PRINT N'(OK 3) Mandar un vehículo a mantenimiento y devolverlo a su estado -> PERMITIDO';
DECLARE @antes VARCHAR(20) = (SELECT estado FROM dbo.vehiculos WHERE placa = 'M1C-302');
UPDATE dbo.vehiculos SET estado = 'mantenimiento' WHERE placa = 'M1C-302';
SELECT placa, @antes AS estado_antes, estado AS estado_ahora FROM dbo.vehiculos WHERE placa = 'M1C-302';
UPDATE dbo.vehiculos SET estado = @antes WHERE placa = 'M1C-302';
GO
PRINT N'(OK 4) Ver la vista financiera -> PERMITIDO (tiene SELECT sobre todo el esquema)';
SELECT TOP (3) codigo_viaje, ingresos, costo_estimado, margen_bruto
FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;
GO

PRINT N'';
PRINT N'(DENEGADO 5) Borrar viajes cancelados (borrado físico) -> ESPERADO: Msg 229';
DELETE FROM dbo.viajes WHERE estado = 'cancelado';
GO
PRINT N'(DENEGADO 6) Borrar una encomienda -> ESPERADO: Msg 229';
DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK20261125PEND01';
GO
PRINT N'(DENEGADO 7) Alterar la estructura de una tabla (DDL) -> ESPERADO: Msg 1088';
ALTER TABLE dbo.rutas ADD columna_intrusa INT NULL;
GO
PRINT N'(DENEGADO 8) Modificar el precio de una encomienda -> ESPERADO: Msg 230';
UPDATE dbo.encomiendas SET precio_envio = 1 WHERE codigo_rastreo = 'AK20261125PEND01';
GO
PRINT N'>>> FASE 3 OK: el supervisor planifica viajes y flota, ve PII, pero nunca borra ni cambia la estructura.';
GO
REVERT;   -- vuelve a la sesión original
GO
SELECT SUSER_NAME() AS sesion_restaurada;
GO
