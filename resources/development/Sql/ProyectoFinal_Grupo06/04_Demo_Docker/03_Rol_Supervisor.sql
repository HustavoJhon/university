/* =============================================================================
   FASE 3 · ROL SUPERVISOR (jefe de operaciones)
   Lee todo, ve datos personales descifrados y planifica viajes, flota y rutas. Nunca borra ni cambia la estructura.
   -----------------------------------------------------------------------------
   FUNCIONA DE LAS DOS FORMAS (abrir el archivo y pulsar F5):

   A) INGRESANDO COMO EL ROL (lo que pide el profesor):
        SSMS > Conectar > Motor de base de datos
          Nombre del servidor : el de su instancia (ej. localhost o .\SQLEXPRESS)
          Autenticación       : Autenticación de SQL Server
          Inicio de sesión    : login_supervisor
          Contraseña          : Akil#Supervisor2026
          [x] Certificado de servidor de confianza  (Trust server certificate)
        Requiere modo de autenticación MIXTO: ver 00_Preparar_Logins_Modo_Mixto.sql

   B) DESDE SU CONEXIÓN DE ADMINISTRADOR (sysadmin / Windows):
        el script se convierte solo en login_supervisor (EXECUTE AS LOGIN)
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
DECLARE @login_rol SYSNAME = N'login_supervisor', @suplantado BIT = 0;

-- 1. Entrar como el rol (si ya está conectado con ese login, no hace nada)
IF SUSER_SNAME() <> @login_rol
BEGIN
    IF IS_SRVROLEMEMBER(N'sysadmin') = 0
    BEGIN
        RAISERROR(N'Conéctese con el login login_supervisor o con un usuario sysadmin.', 16, 1);
        RETURN;
    END;
    EXECUTE AS LOGIN = N'login_supervisor';
    SET @suplantado = 1;
END;

-- 2. ¿Quién soy?
SELECT N'¿Quién soy?' AS prueba, SUSER_SNAME() AS login_conectado, USER_NAME() AS usuario_bd,
       DB_NAME() AS base, IS_ROLEMEMBER(N'Rol_Supervisor') AS es_rol_supervisor;

-- 3. Pruebas: qué PUEDE y qué NO PUEDE hacer
DECLARE @pruebas TABLE (n INT PRIMARY KEY, prueba NVARCHAR(150), esperado NVARCHAR(10), sentencia NVARCHAR(MAX));
INSERT INTO @pruebas (n, prueba, esperado, sentencia) VALUES
  (1, N'Leer viajes', N'PERMITIDO',
   N'SELECT N''(1)'' AS prueba, COUNT(*) AS total_viajes FROM dbo.viajes;'),
  (2, N'Leer el personal (usuarios_sistema)', N'PERMITIDO',
   N'SELECT TOP (3) N''(2)'' AS prueba, nombre_completo, cargo, correo FROM dbo.usuarios_sistema;'),
  (3, N'Consultar encomienda con datos personales descifrados (SP)', N'PERMITIDO',
   N'EXEC dbo.usp_consultar_encomienda @codigo_rastreo = ''AK20261125PEND01'';'),
  (4, N'Ver la vista financiera', N'PERMITIDO',
   N'SELECT TOP (3) N''(4)'' AS prueba, codigo_viaje, ingresos, costo_estimado, margen_bruto FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;'),
  (5, N'Actualizar un vehículo (flota)', N'PERMITIDO',
   N'UPDATE dbo.vehiculos SET estado = estado WHERE placa = ''M1C-302'';'),
  (6, N'Actualizar el costo de un viaje (planificación)', N'PERMITIDO',
   N'UPDATE dbo.viajes SET costo_estimado = costo_estimado WHERE viaje_id = 1;'),
  (7, N'Cambiar el estado de una encomienda', N'PERMITIDO',
   N'UPDATE dbo.encomiendas SET estado = estado WHERE codigo_rastreo = ''AK20261125PEND01'';'),
  (8, N'Borrar viajes (borrado físico)', N'DENEGADO',
   N'DELETE FROM dbo.viajes WHERE viaje_id = -1;'),
  (9, N'Borrar una encomienda', N'DENEGADO',
   N'DELETE FROM dbo.encomiendas WHERE encomienda_id = -1;'),
  (10, N'Cambiar el PRECIO de una encomienda', N'DENEGADO',
   N'UPDATE dbo.encomiendas SET precio_envio = precio_envio WHERE encomienda_id = -1;'),
  (11, N'Alterar la estructura de una tabla (ALTER TABLE)', N'DENEGADO',
   N'ALTER TABLE dbo.rutas ADD columna_intrusa INT NULL;'),
  (12, N'Crear una tabla (DDL)', N'DENEGADO',
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
              N' pruebas correctas para login_supervisor') AS conclusion,
       SUSER_SNAME() AS sesion_actual
FROM @resultados;
GO
