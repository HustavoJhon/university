/* =============================================================================
   FASE 2 · ROL OPERADOR (despachador de agencia)
   Ejecutar CONECTADO COMO:  login_operador / Akil#Operador2026
                             ./demo.sh 02
   Los mensajes Msg 229 / 230 / 15151 son ESPERADOS: prueban que el permiso
   está denegado.
   ============================================================================= */
SET NOCOUNT ON;
GO
PRINT N'=== ¿Quién soy? ===';
SELECT SUSER_NAME() AS login_conectado, USER_NAME() AS usuario_bd, DB_NAME() AS base,
       IS_ROLEMEMBER(N'Rol_Operador') AS es_rol_operador;
GO
PRINT N'';
PRINT N'(OK 1) SELECT sucursales y rutas -> ESPERADO: PERMITIDO';
SELECT codigo, nombre, ciudad FROM dbo.sucursales;
SELECT TOP (3) codigo_ruta, distancia_km FROM dbo.rutas;
GO
PRINT N'(OK 2) SELECT encomiendas -> PERMITIDO, pero los datos personales salen en binario';
SELECT TOP (3) codigo_rastreo, estado, precio_envio, remitente_cif
FROM dbo.encomiendas ORDER BY encomienda_id;
GO
PRINT N'(OK 3) Registrar encomienda con el SP (se cifra dentro), consultarla descifrada y cambiar su estado -> PERMITIDO';
DECLARE @codigo VARCHAR(20) = CONCAT('AK-OP-', FORMAT(SYSDATETIME(), 'MMddHHmmss'));
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo = @codigo, @viaje_id = NULL, @usuario_registro_id = 9,
     @remitente = N'Cooperativa Agraria La Prosperidad', @documento_remitente = '20480001371',
     @destinatario = N'Marleny Guevara Tapia', @telefono_destinatario = '976112233',
     @descripcion = N'Registrada por el operador', @peso_kg = 25.00, @precio_envio = 30.00;
EXEC dbo.usp_consultar_encomienda @codigo_rastreo = @codigo;
UPDATE dbo.encomiendas SET estado = 'entregada' WHERE codigo_rastreo = @codigo;
SELECT codigo_rastreo, estado AS estado_actualizado FROM dbo.encomiendas WHERE codigo_rastreo = @codigo;
GO

PRINT N'';
PRINT N'(DENEGADO 4) DELETE en encomiendas -> ESPERADO: Msg 229';
DELETE FROM dbo.encomiendas WHERE codigo_rastreo LIKE 'AK-OP-%';
GO
PRINT N'(DENEGADO 5) INSERT directo saltándose el cifrado -> ESPERADO: Msg 229';
INSERT INTO dbo.encomiendas (codigo_rastreo, usuario_registro_id, descripcion, peso_kg, precio_envio,
                             remitente_cif, documento_remitente_cif, destinatario_cif, telefono_destinatario_cif)
VALUES ('AK-HACK-01', 9, N'Sin cifrar', 1, 1, 0x00, 0x00, 0x00, 0x00);
GO
PRINT N'(DENEGADO 6) UPDATE del precio (columna no autorizada) -> ESPERADO: Msg 230';
UPDATE dbo.encomiendas SET precio_envio = 0 WHERE codigo_rastreo LIKE 'AK-OP-%';
GO
PRINT N'(DENEGADO 7) Leer correos del personal (usuarios_sistema) -> ESPERADO: Msg 229';
SELECT TOP (3) nombre_completo, correo FROM dbo.usuarios_sistema;
GO
PRINT N'(DENEGADO 8) Ver la vista financiera -> ESPERADO: Msg 229';
SELECT TOP (3) * FROM dbo.vw_resumen_financiero_viajes;
GO
PRINT N'(DENEGADO 9) Abrir la llave AES_256 directamente -> ESPERADO: Msg 15151';
OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
GO
PRINT N'(DENEGADO 10) Crear una tabla (DDL) -> ESPERADO: Msg 262';
CREATE TABLE dbo.tabla_intrusa (id INT);
GO

PRINT N'';
PRINT N'=== Mis permisos efectivos sobre dbo.encomiendas ===';
SELECT permission_name AS permiso, ISNULL(subentity_name, N'(toda la tabla)') AS columna
FROM fn_my_permissions(N'dbo.encomiendas', N'OBJECT')
ORDER BY permiso, columna;
GO
PRINT N'>>> FASE 2 OK: el operador registra y actualiza estados, pero no borra, no toca precios ni ve datos ajenos.';
GO
