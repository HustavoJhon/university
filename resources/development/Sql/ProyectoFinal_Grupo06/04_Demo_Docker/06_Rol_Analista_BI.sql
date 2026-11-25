/* =============================================================================
   FASE 6 · ROL ANALISTA BI (Data Warehouse)
   Consume la vista BI, las dimensiones y los hechos. Staging, bitácora del ETL y la base OLTP están cerradas.
   -----------------------------------------------------------------------------
   FUNCIONA DE LAS DOS FORMAS (abrir el archivo y pulsar F5):

   A) INGRESANDO COMO EL ROL (lo que pide el profesor):
        SSMS > Conectar > Motor de base de datos
          Nombre del servidor : el de su instancia (ej. localhost o .\SQLEXPRESS)
          Autenticación       : Autenticación de SQL Server
          Inicio de sesión    : login_analista_bi
          Contraseña          : Akil#AnalistaBI2026
          [x] Certificado de servidor de confianza  (Trust server certificate)
        Requiere modo de autenticación MIXTO: ver 00_Preparar_Logins_Modo_Mixto.sql

   B) DESDE SU CONEXIÓN DE ADMINISTRADOR (sysadmin / Windows):
        el script se convierte solo en login_analista_bi (EXECUTE AS LOGIN)
        y al terminar vuelve a su usuario (REVERT).

   RESULTADO: cada prueba se ejecuta protegida (TRY/CATCH), así que NO salen
   errores en rojo. La ÚLTIMA tabla resume todo: esperado vs obtenido y
   "✔ CORRECTO" en cada fila. Las tablas intermedias (columna "prueba")
   son los datos que el rol SÍ puede ver.
   ============================================================================= */
USE dwh_AkilFlow;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
SET ANSI_NULLS ON;
GO
IF ORIGINAL_LOGIN() <> SUSER_SNAME() REVERT;   -- limpia una suplantación anterior, si la hubiera
GO
DECLARE @login_rol SYSNAME = N'login_analista_bi', @suplantado BIT = 0;

-- 1. Entrar como el rol (si ya está conectado con ese login, no hace nada)
IF SUSER_SNAME() <> @login_rol
BEGIN
    IF IS_SRVROLEMEMBER(N'sysadmin') = 0
    BEGIN
        RAISERROR(N'Conéctese con el login login_analista_bi o con un usuario sysadmin.', 16, 1);
        RETURN;
    END;
    EXECUTE AS LOGIN = N'login_analista_bi';
    SET @suplantado = 1;
END;

-- 2. ¿Quién soy?
SELECT N'¿Quién soy?' AS prueba, SUSER_SNAME() AS login_conectado, USER_NAME() AS usuario_bd,
       DB_NAME() AS base, IS_ROLEMEMBER(N'Rol_Analista_BI') AS es_rol_analista_bi;

-- 3. Pruebas: qué PUEDE y qué NO PUEDE hacer
DECLARE @pruebas TABLE (n INT PRIMARY KEY, prueba NVARCHAR(150), esperado NVARCHAR(10), sentencia NVARCHAR(MAX));
INSERT INTO @pruebas (n, prueba, esperado, sentencia) VALUES
  (1, N'Vista BI: ingresos y margen por año y región', N'PERMITIDO',
   N'SELECT N''(1)'' AS prueba, anio, region, SUM(cantidad_encomiendas) AS encomiendas, SUM(ingreso_envio) AS ingresos, SUM(margen) AS margen FROM dbo.vw_bi_encomiendas GROUP BY anio, region ORDER BY anio, ingresos DESC;'),
  (2, N'Dimensión sucursal', N'PERMITIDO',
   N'SELECT N''(2)'' AS prueba, sucursal_codigo, sucursal_nombre, region FROM dbo.dim_sucursal;'),
  (3, N'Tabla de hechos', N'PERMITIDO',
   N'SELECT N''(3)'' AS prueba, COUNT(*) AS filas_fact, SUM(ingreso_envio) AS ingresos_totales FROM dbo.fact_encomiendas;'),
  (4, N'Zona staging (datos crudos)', N'DENEGADO',
   N'SELECT TOP (1) * FROM dbo.staging_encomiendas;'),
  (5, N'Bitácora del ETL', N'DENEGADO',
   N'SELECT TOP (1) * FROM dbo.etl_log;'),
  (6, N'Ejecutar el ETL', N'DENEGADO',
   N'EXEC dbo.usp_etl_akilflow;'),
  (7, N'Modificar un hecho (UPDATE)', N'DENEGADO',
   N'UPDATE dbo.fact_encomiendas SET margen = margen WHERE fact_id = -1;'),
  (8, N'Leer la base OLTP AkilFlowOperaciones (no tiene usuario allí)', N'DENEGADO',
   N'SELECT TOP (1) * FROM AkilFlowOperaciones.dbo.sucursales;');

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
              N' pruebas correctas para login_analista_bi') AS conclusion,
       SUSER_SNAME() AS sesion_actual
FROM @resultados;
GO
