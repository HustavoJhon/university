/* =============================================================================
   FASE 2 · ROL OPERADOR (despachador de agencia)
   Registra encomiendas (solo por el SP que cifra) y cambia estados. No borra, no toca precios, no ve personal ni finanzas.
   -----------------------------------------------------------------------------
   FUNCIONA DE LAS DOS FORMAS (abrir el archivo y pulsar F5):

   A) INGRESANDO COMO EL ROL (lo que pide el profesor):
        SSMS > Conectar > Motor de base de datos
          Nombre del servidor : el de su instancia (ej. localhost o .\SQLEXPRESS)
          Autenticación       : Autenticación de SQL Server
          Inicio de sesión    : login_operador
          Contraseña          : Akil#Operador2026
          [x] Certificado de servidor de confianza  (Trust server certificate)
        Requiere modo de autenticación MIXTO: ver 00_Preparar_Logins_Modo_Mixto.sql

   B) DESDE SU CONEXIÓN DE ADMINISTRADOR (sysadmin / Windows):
        el script se convierte solo en login_operador (EXECUTE AS LOGIN)
        y al terminar vuelve a su usuario (REVERT).

   RESULTADO: cada prueba se ejecuta protegida (TRY/CATCH), así que NO salen
   errores en rojo. La ÚLTIMA tabla resume todo: esperado vs obtenido y
   "✔ CORRECTO" en cada fila. Las tablas intermedias (columna "prueba")
   son los datos que el rol SÍ puede ver.
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
IF ORIGINAL_LOGIN() <> SUSER_SNAME() REVERT;   -- limpia una suplantación anterior, si la hubiera
GO
DECLARE @login_rol SYSNAME = N'login_operador', @suplantado BIT = 0;

-- 1. Entrar como el rol (si ya está conectado con ese login, no hace nada)
IF SUSER_SNAME() <> @login_rol
BEGIN
    IF IS_SRVROLEMEMBER(N'sysadmin') = 0
    BEGIN
        RAISERROR(N'Conéctese con el login login_operador o con un usuario sysadmin.', 16, 1);
        RETURN;
    END;
    EXECUTE AS LOGIN = N'login_operador';
    SET @suplantado = 1;
END;

-- 2. ¿Quién soy?
SELECT N'¿Quién soy?' AS prueba, SUSER_SNAME() AS login_conectado, USER_NAME() AS usuario_bd,
       DB_NAME() AS base, IS_ROLEMEMBER(N'Rol_Operador') AS es_rol_operador;

-- 3. Pruebas: qué PUEDE y qué NO PUEDE hacer
DECLARE @pruebas TABLE (n INT PRIMARY KEY, prueba NVARCHAR(150), esperado NVARCHAR(10), sentencia NVARCHAR(MAX));
INSERT INTO @pruebas (n, prueba, esperado, sentencia) VALUES
  (1, N'Leer sucursales', N'PERMITIDO',
   N'SELECT N''(1)'' AS prueba, codigo, nombre, ciudad FROM dbo.sucursales;'),
  (2, N'Leer encomiendas: los datos personales salen CIFRADOS (binario)', N'PERMITIDO',
   N'SELECT TOP (3) N''(2)'' AS prueba, codigo_rastreo, estado, precio_envio, remitente_cif FROM dbo.encomiendas ORDER BY encomienda_id;'),
  (3, N'Registrar una encomienda con el SP (se cifra dentro) y consultarla descifrada', N'PERMITIDO',
   N'DECLARE @c VARCHAR(20) = CONCAT(''AK-OP-'', FORMAT(SYSDATETIME(), ''MMddHHmmssff''));
EXEC dbo.usp_registrar_encomienda @codigo_rastreo = @c, @viaje_id = NULL, @usuario_registro_id = 9,
     @remitente = N''Cooperativa Agraria La Prosperidad'', @documento_remitente = ''20480001371'',
     @destinatario = N''Marleny Guevara Tapia'', @telefono_destinatario = ''976112233'',
     @descripcion = N''Registrada por el operador (prueba de rol)'', @peso_kg = 25.00, @precio_envio = 30.00;
EXEC dbo.usp_consultar_encomienda @codigo_rastreo = @c;'),
  (4, N'Consultar una encomienda existente descifrada (SP seguro)', N'PERMITIDO',
   N'EXEC dbo.usp_consultar_encomienda @codigo_rastreo = ''AK20261125PEND01'';'),
  (5, N'Cambiar el ESTADO de una encomienda (columna permitida)', N'PERMITIDO',
   N'UPDATE dbo.encomiendas SET estado = estado WHERE codigo_rastreo = ''AK20261125PEND01'';'),
  (6, N'Cambiar el ESTADO de un viaje', N'PERMITIDO',
   N'UPDATE dbo.viajes SET estado = estado WHERE viaje_id = 1;'),
  (7, N'Borrar una encomienda (DELETE)', N'DENEGADO',
   N'DELETE FROM dbo.encomiendas WHERE encomienda_id = -1;'),
  (8, N'Insertar directo en encomiendas saltándose el cifrado', N'DENEGADO',
   N'INSERT INTO dbo.encomiendas (codigo_rastreo, usuario_registro_id, descripcion, peso_kg, precio_envio, remitente_cif, documento_remitente_cif, destinatario_cif, telefono_destinatario_cif) VALUES (''AK-HACK-01'', 9, N''Sin cifrar'', 1, 1, 0x00, 0x00, 0x00, 0x00);'),
  (9, N'Cambiar el PRECIO de una encomienda (columna no autorizada)', N'DENEGADO',
   N'UPDATE dbo.encomiendas SET precio_envio = precio_envio WHERE encomienda_id = -1;'),
  (10, N'Leer los correos del personal (usuarios_sistema)', N'DENEGADO',
   N'SELECT TOP (3) nombre_completo, correo FROM dbo.usuarios_sistema;'),
  (11, N'Ver la vista financiera', N'DENEGADO',
   N'SELECT TOP (3) * FROM dbo.vw_resumen_financiero_viajes;'),
  (12, N'Abrir la llave AES_256 directamente', N'DENEGADO',
   N'OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;'),
  (13, N'Borrar un viaje', N'DENEGADO',
   N'DELETE FROM dbo.viajes WHERE viaje_id = -1;'),
  (14, N'Crear una tabla (DDL)', N'DENEGADO',
   N'CREATE TABLE dbo.tabla_intrusa (id INT);');

DECLARE @resultados TABLE (n INT, prueba NVARCHAR(150), esperado NVARCHAR(10), obtenido NVARCHAR(10), mensaje_sql_server NVARCHAR(500));
DECLARE @n INT, @prueba NVARCHAR(150), @esperado NVARCHAR(10), @sentencia NVARCHAR(MAX);
DECLARE c_pruebas CURSOR LOCAL FAST_FORWARD FOR SELECT n, prueba, esperado, sentencia FROM @pruebas ORDER BY n;
OPEN c_pruebas;
FETCH NEXT FROM c_pruebas INTO @n, @prueba, @esperado, @sentencia;
WHILE @@FETCH_STATUS = 0
BEGIN
    BEGIN TRY
        EXEC sys.sp_executesql @sentencia;
        INSERT INTO @resultados VALUES (@n, @prueba, @esperado, N'PERMITIDO', NULL);
    END TRY
    BEGIN CATCH
        INSERT INTO @resultados VALUES (@n, @prueba, @esperado, N'DENEGADO',
               CONCAT(N'Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE()));
    END CATCH;
    FETCH NEXT FROM c_pruebas INTO @n, @prueba, @esperado, @sentencia;
END;
CLOSE c_pruebas;
DEALLOCATE c_pruebas;

-- 4. Volver al usuario original (solo si se suplantó)
IF @suplantado = 1 REVERT;

-- 5. RESUMEN FINAL
SELECT n AS [#], prueba, esperado, obtenido,
       CASE WHEN esperado = obtenido THEN N'✔ CORRECTO' ELSE N'✘ REVISAR' END AS resultado,
       mensaje_sql_server
FROM @resultados ORDER BY n;

SELECT CONCAT(SUM(CASE WHEN esperado = obtenido THEN 1 ELSE 0 END), N' de ', COUNT(*),
              N' pruebas correctas para login_operador') AS conclusion,
       SUSER_SNAME() AS sesion_actual
FROM @resultados;
GO
