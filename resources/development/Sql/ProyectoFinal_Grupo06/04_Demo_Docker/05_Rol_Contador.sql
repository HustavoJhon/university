/* =============================================================================
   FASE 5 · ROL CONTADOR (finanzas)
   Ve montos, costos y márgenes. Nunca ve datos personales ni el personal, y no modifica nada.
   -----------------------------------------------------------------------------
   FUNCIONA DE LAS DOS FORMAS (abrir el archivo y pulsar F5):

   A) INGRESANDO COMO EL ROL (lo que pide el profesor):
        SSMS > Conectar > Motor de base de datos
          Nombre del servidor : el de su instancia (ej. localhost o .\SQLEXPRESS)
          Autenticación       : Autenticación de SQL Server
          Inicio de sesión    : login_contador
          Contraseña          : Akil#Contador2026
          [x] Certificado de servidor de confianza  (Trust server certificate)
        Requiere modo de autenticación MIXTO: ver 00_Preparar_Logins_Modo_Mixto.sql

   B) DESDE SU CONEXIÓN DE ADMINISTRADOR (sysadmin / Windows):
        el script se convierte solo en login_contador (EXECUTE AS LOGIN)
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
DECLARE @login_rol SYSNAME = N'login_contador', @suplantado BIT = 0;

-- 1. Entrar como el rol (si ya está conectado con ese login, no hace nada)
IF SUSER_SNAME() <> @login_rol
BEGIN
    IF IS_SRVROLEMEMBER(N'sysadmin') = 0
    BEGIN
        RAISERROR(N'Conéctese con el login login_contador o con un usuario sysadmin.', 16, 1);
        RETURN;
    END;
    EXECUTE AS LOGIN = N'login_contador';
    SET @suplantado = 1;
END;

-- 2. ¿Quién soy?
SELECT N'¿Quién soy?' AS prueba, SUSER_SNAME() AS login_conectado, USER_NAME() AS usuario_bd,
       DB_NAME() AS base, IS_ROLEMEMBER(N'Rol_Contador') AS es_rol_contador;

-- 3. Pruebas: qué PUEDE y qué NO PUEDE hacer
DECLARE @pruebas TABLE (n INT PRIMARY KEY, prueba NVARCHAR(150), esperado NVARCHAR(10), sentencia NVARCHAR(MAX));
INSERT INTO @pruebas (n, prueba, esperado, sentencia) VALUES
  (1, N'Vista financiera: ingresos, costos y margen por viaje', N'PERMITIDO',
   N'SELECT TOP (5) N''(1)'' AS prueba, codigo_viaje, codigo_ruta, fecha, cantidad_encomiendas, ingresos, costo_estimado, margen_bruto FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;'),
  (2, N'Resumen financiero por ruta', N'PERMITIDO',
   N'SELECT N''(2)'' AS prueba, codigo_ruta, COUNT(*) AS viajes, SUM(ingresos) AS ingresos, SUM(margen_bruto) AS margen FROM dbo.vw_resumen_financiero_viajes GROUP BY codigo_ruta ORDER BY margen DESC;'),
  (3, N'Columnas NO sensibles de encomiendas (precio, peso, estado)', N'PERMITIDO',
   N'SELECT TOP (3) N''(3)'' AS prueba, codigo_rastreo, peso_kg, precio_envio, estado FROM dbo.encomiendas ORDER BY encomienda_id;'),
  (4, N'Leer viajes y vehículos', N'PERMITIDO',
   N'SELECT TOP (3) N''(4)'' AS prueba, v.codigo_viaje, v.costo_estimado, ve.placa FROM dbo.viajes v JOIN dbo.vehiculos ve ON ve.vehiculo_id = v.vehiculo_id ORDER BY v.viaje_id DESC;'),
  (5, N'Columna con datos personales (remitente_cif)', N'DENEGADO',
   N'SELECT TOP (1) codigo_rastreo, remitente_cif FROM dbo.encomiendas;'),
  (6, N'SELECT * de encomiendas (incluye columnas cifradas)', N'DENEGADO',
   N'SELECT TOP (1) * FROM dbo.encomiendas;'),
  (7, N'Leer el personal (usuarios_sistema)', N'DENEGADO',
   N'SELECT TOP (1) correo FROM dbo.usuarios_sistema;'),
  (8, N'Modificar el costo de un viaje', N'DENEGADO',
   N'UPDATE dbo.viajes SET costo_estimado = costo_estimado WHERE viaje_id = -1;'),
  (9, N'Ejecutar el SP de consulta', N'DENEGADO',
   N'EXEC dbo.usp_consultar_encomienda @codigo_rastreo = ''AK20261125PEND01'';');

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
              N' pruebas correctas para login_contador') AS conclusion,
       SUSER_SNAME() AS sesion_actual
FROM @resultados;
GO
