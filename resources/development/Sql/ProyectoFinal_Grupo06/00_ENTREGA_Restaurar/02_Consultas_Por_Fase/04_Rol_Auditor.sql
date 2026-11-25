/* =============================================================================
   FASE 4 · ROL AUDITOR (control interno)
   Lee todas las tablas, pero los datos personales solo en binario. No escribe nada ni puede descifrar.
   -----------------------------------------------------------------------------
   FUNCIONA DE LAS DOS FORMAS (abrir el archivo y pulsar F5):

   A) INGRESANDO COMO EL ROL (lo que pide el profesor):
        SSMS > Conectar > Motor de base de datos
          Nombre del servidor : el de su instancia (ej. localhost o .\SQLEXPRESS)
          Autenticación       : Autenticación de SQL Server
          Inicio de sesión    : login_auditor
          Contraseña          : Akil#Auditor2026
          [x] Certificado de servidor de confianza  (Trust server certificate)
        Requiere modo de autenticación MIXTO: ver 00_Preparar_Logins_Modo_Mixto.sql

   B) DESDE SU CONEXIÓN DE ADMINISTRADOR (sysadmin / Windows):
        el script se convierte solo en login_auditor (EXECUTE AS LOGIN)
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
DECLARE @login_rol SYSNAME = N'login_auditor', @suplantado BIT = 0;

-- 1. Entrar como el rol (si ya está conectado con ese login, no hace nada)
IF SUSER_SNAME() <> @login_rol
BEGIN
    IF IS_SRVROLEMEMBER(N'sysadmin') = 0
    BEGIN
        RAISERROR(N'Conéctese con el login login_auditor o con un usuario sysadmin.', 16, 1);
        RETURN;
    END;
    EXECUTE AS LOGIN = N'login_auditor';
    SET @suplantado = 1;
END;

-- 2. ¿Quién soy?
SELECT N'¿Quién soy?' AS prueba, SUSER_SNAME() AS login_conectado, USER_NAME() AS usuario_bd,
       DB_NAME() AS base, IS_ROLEMEMBER(N'Rol_Auditor') AS es_rol_auditor;

-- 3. Pruebas: qué PUEDE y qué NO PUEDE hacer
DECLARE @pruebas TABLE (n INT PRIMARY KEY, prueba NVARCHAR(150), esperado NVARCHAR(10), sentencia NVARCHAR(MAX));
INSERT INTO @pruebas (n, prueba, esperado, sentencia) VALUES
  (1, N'Leer todas las tablas (conteos)', N'PERMITIDO',
   N'SELECT N''(1)'' AS prueba, (SELECT COUNT(*) FROM dbo.viajes) AS viajes, (SELECT COUNT(*) FROM dbo.encomiendas) AS encomiendas, (SELECT COUNT(*) FROM dbo.usuarios_sistema) AS usuarios;'),
  (2, N'Leer el personal', N'PERMITIDO',
   N'SELECT TOP (3) N''(2)'' AS prueba, nombre_completo, cargo FROM dbo.usuarios_sistema;'),
  (3, N'Ver datos personales: solo BINARIO, DecryptByKey devuelve NULL', N'PERMITIDO',
   N'SELECT TOP (3) N''(3)'' AS prueba, codigo_rastreo, remitente_cif, CAST(DecryptByKey(remitente_cif) AS NVARCHAR(120)) AS intento_descifrar FROM dbo.encomiendas ORDER BY encomienda_id;'),
  (4, N'Ver la vista financiera', N'PERMITIDO',
   N'SELECT TOP (3) N''(4)'' AS prueba, codigo_viaje, ingresos, margen_bruto FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;'),
  (5, N'Abrir la llave AES_256', N'DENEGADO',
   N'OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;'),
  (6, N'Usar el SP que descifra', N'DENEGADO',
   N'EXEC dbo.usp_consultar_encomienda @codigo_rastreo = ''AK20261125PEND01'';'),
  (7, N'Modificar una encomienda (UPDATE)', N'DENEGADO',
   N'UPDATE dbo.encomiendas SET estado = estado WHERE encomienda_id = -1;'),
  (8, N'Insertar una sucursal (INSERT)', N'DENEGADO',
   N'INSERT INTO dbo.sucursales (empresa_id, codigo, nombre, ciudad, departamento) VALUES (1, ''XXX'', N''Falsa'', N''X'', N''X'');'),
  (9, N'Borrar un viaje (DELETE)', N'DENEGADO',
   N'DELETE FROM dbo.viajes WHERE viaje_id = -1;');

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
              N' pruebas correctas para login_auditor') AS conclusion,
       SUSER_SNAME() AS sesion_actual
FROM @resultados;
GO
