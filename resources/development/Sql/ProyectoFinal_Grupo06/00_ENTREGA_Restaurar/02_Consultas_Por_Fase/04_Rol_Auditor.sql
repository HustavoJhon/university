/* =============================================================================
   FASE 4 · ROL AUDITOR (control interno)
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5.
   El script se convierte en login_auditor con EXECUTE AS LOGIN (prueba las 2 capas:
   login de instancia + usuario de base) y al final vuelve a su sesión con REVERT.
   Si ejecuta por partes, ejecute SIEMPRE el bloque EXECUTE AS del inicio y el REVERT del final.
   Alternativa: conectarse con autenticación SQL (login_auditor / Akil#Auditor2026) en modo mixto
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
EXECUTE AS LOGIN = N'login_auditor';   -- desde aquí todo se ejecuta como login_auditor
GO
PRINT N'=== ¿Quién soy? ===';
SELECT SUSER_NAME() AS login_conectado, USER_NAME() AS usuario_bd, DB_NAME() AS base,
       IS_ROLEMEMBER(N'Rol_Auditor') AS es_rol_auditor;
GO
PRINT N'';
PRINT N'(OK 1) Leer todas las tablas -> PERMITIDO';
SELECT (SELECT COUNT(*) FROM dbo.viajes)           AS viajes,
       (SELECT COUNT(*) FROM dbo.encomiendas)      AS encomiendas,
       (SELECT COUNT(*) FROM dbo.usuarios_sistema) AS usuarios;
GO
PRINT N'(OK 2) Ver datos personales -> solo BINARIO; DecryptByKey devuelve NULL (no tiene la llave)';
SELECT TOP (3) codigo_rastreo, remitente_cif,
       CAST(DecryptByKey(remitente_cif) AS NVARCHAR(120)) AS intento_descifrar
FROM dbo.encomiendas ORDER BY encomienda_id;
GO

PRINT N'';
PRINT N'(DENEGADO 3) Abrir la llave AES_256 -> ESPERADO: Msg 15151';
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
GO
PRINT N'(DENEGADO 4) Usar el SP que descifra -> ESPERADO: Msg 229';
EXEC dbo.usp_consultar_encomienda @codigo_rastreo = 'AK20261125PEND01';
GO
PRINT N'(DENEGADO 5) UPDATE -> ESPERADO: Msg 229';
UPDATE dbo.encomiendas SET estado = 'entregada' WHERE encomienda_id = 1;
GO
PRINT N'(DENEGADO 6) INSERT -> ESPERADO: Msg 229';
INSERT INTO dbo.sucursales (empresa_id, codigo, nombre, ciudad, departamento) VALUES (1, 'XXX', N'Falsa', N'X', N'X');
GO
PRINT N'(DENEGADO 7) DELETE -> ESPERADO: Msg 229';
DELETE FROM dbo.viajes WHERE viaje_id = 1;
GO
PRINT N'>>> FASE 4 OK: el auditor lo lee todo, no escribe nada y nunca ve datos personales en claro.';
GO
REVERT;   -- vuelve a la sesión original
GO
SELECT SUSER_NAME() AS sesion_restaurada;
GO
