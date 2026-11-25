/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 04_DWH_EsquemaEstrella_ETL.sql
   Base    : dwh_AkilFlow (entorno analítico) <- AkilFlowOperaciones (OLTP)
   Criterio: 5 - Arquitectura DWH (Staging + Esquema Estrella con SK) y ETL con MERGE
   -----------------------------------------------------------------------------
   Prerrequisito: scripts 01 a 03 ejecutados (mismo servidor/instancia).
   Grano de la tabla de hechos: 1 fila = 1 encomienda transportada.
   Contenido:
     FASE 1. Creación de dwh_AkilFlow
     FASE 2. Zona Staging (staging_encomiendas) y bitácora ETL
     FASE 3. 5 Dimensiones con claves subrogadas (SK) + miembro "Desconocido"
     FASE 4. Tabla de hechos fact_encomiendas + índices
     FASE 5. Procedimiento ETL (Extract -> Clean/Transform -> MERGE -> Load)
     FASE 6. Automatización (SQL Server Agent, diario 02:00)
     FASE 7. Primera carga + conciliación Staging vs Fact
     FASE 8. Carga incremental (simulación de un nuevo día de operación)
     FASE 9. Prueba del manejo de errores (tabla de cuarentena etl_errores)
   ============================================================================= */

/* =============================================================================
   FASE 1. CREACIÓN DE LA BASE ANALÍTICA
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO
IF DB_ID(N'dwh_AkilFlow') IS NOT NULL
BEGIN
    ALTER DATABASE dwh_AkilFlow SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE dwh_AkilFlow;
END;
GO
CREATE DATABASE dwh_AkilFlow;
GO
-- El DWH se reconstruye desde la OLTP: SIMPLE reduce el crecimiento del log en cargas masivas.
ALTER DATABASE dwh_AkilFlow SET RECOVERY SIMPLE;
GO
USE dwh_AkilFlow;
GO

/* =============================================================================
   FASE 2. ZONA STAGING (área de aterrizaje, se vacía en cada corrida)
   Sin PK/FK a propósito: debe aceptar los datos "tal cual" para limpiarlos.
   ============================================================================= */
CREATE TABLE dbo.staging_encomiendas (
    encomienda_id         INT            NOT NULL,
    codigo_rastreo        VARCHAR(20)    NULL,
    codigo_viaje          VARCHAR(20)    NULL,
    fecha_salida          DATE           NULL,
    origen_codigo         CHAR(3)        NULL,
    origen_nombre         NVARCHAR(120)  NULL,
    origen_ciudad         NVARCHAR(80)   NULL,
    origen_departamento   NVARCHAR(80)   NULL,
    destino_codigo        CHAR(3)        NULL,
    destino_nombre        NVARCHAR(120)  NULL,
    destino_ciudad        NVARCHAR(80)   NULL,
    destino_departamento  NVARCHAR(80)   NULL,
    codigo_ruta           CHAR(7)        NULL,
    distancia_km          DECIMAL(7,1)   NULL,
    horas_estimadas       DECIMAL(4,1)   NULL,
    placa                 VARCHAR(10)    NULL,
    marca                 NVARCHAR(60)   NULL,
    modelo                NVARCHAR(60)   NULL,
    anio_fabricacion      SMALLINT       NULL,
    capacidad_carga_kg    DECIMAL(10,2)  NULL,
    estado_encomienda     VARCHAR(12)    NULL,
    peso_kg               DECIMAL(10,2)  NULL,
    precio_envio          DECIMAL(10,2)  NULL,
    costo_viaje           DECIMAL(12,2)  NULL,
    peso_total_viaje      DECIMAL(12,2)  NULL,
    costo_asignado        DECIMAL(12,2)  NULL,      -- prorrateo por peso
    fecha_extraccion      DATETIME2(0)   NOT NULL CONSTRAINT DF_staging_fecha DEFAULT (SYSDATETIME())
);
GO

CREATE TABLE dbo.etl_log (
    ejecucion_id      INT IDENTITY(1,1) CONSTRAINT PK_etl_log PRIMARY KEY,
    inicio            DATETIME2(0)  NOT NULL,
    fin               DATETIME2(0)  NULL,
    filas_staging     INT           NULL,
    filas_rechazadas  INT           NULL,
    hechos_insertados INT           NULL,
    hechos_actualizados INT         NULL,
    dims_insertadas   INT           NULL,
    dims_actualizadas INT           NULL,
    estado            VARCHAR(10)   NOT NULL,
    mensaje           NVARCHAR(4000) NULL
);
GO

-- Tabla de errores / cuarentena (Semana 14 - "Manejo de errores en ETL"):
-- las filas que no superan las reglas de calidad NO llegan a la tabla de
-- hechos; se redirigen aquí con el motivo para su revisión.
CREATE TABLE dbo.etl_errores (
    error_id       INT IDENTITY(1,1) CONSTRAINT PK_etl_errores PRIMARY KEY,
    ejecucion_id   INT           NOT NULL,
    encomienda_id  INT           NULL,
    codigo_rastreo VARCHAR(20)   NULL,
    regla_fallida  NVARCHAR(200) NOT NULL,
    fecha          DATETIME2(0)  NOT NULL CONSTRAINT DF_etl_errores_fecha DEFAULT (SYSDATETIME())
);
GO

/* =============================================================================
   FASE 3. DIMENSIONES CON CLAVES SUBROGADAS (SK)
   - SK = INT IDENTITY propio del DWH, independiente de los IDs de la OLTP
     (aísla el DWH de cambios/reutilización de claves operacionales).
   - La clave de negocio (codigo/placa) se guarda como UNIQUE para el MERGE.
   - SK = -1 "Desconocido": evita perder hechos si falta una dimensión.
   ============================================================================= */

-- 3.1 DIM_TIEMPO (clave inteligente AAAAMMDD, generada para 2024-2027)
CREATE TABLE dbo.dim_tiempo (
    tiempo_id         INT          NOT NULL CONSTRAINT PK_dim_tiempo PRIMARY KEY,   -- 20260115
    fecha             DATE         NOT NULL CONSTRAINT UQ_dim_tiempo_fecha UNIQUE,
    anio              SMALLINT     NOT NULL,
    semestre          TINYINT      NOT NULL,
    trimestre         TINYINT      NOT NULL,
    mes               TINYINT      NOT NULL,
    nombre_mes        NVARCHAR(12) NOT NULL,
    anio_mes          CHAR(7)      NOT NULL,      -- 2026-01
    semana_anio       TINYINT      NOT NULL,
    dia               TINYINT      NOT NULL,
    dia_semana        TINYINT      NOT NULL,      -- 1 = lunes (independiente de @@DATEFIRST)
    nombre_dia        NVARCHAR(10) NOT NULL,
    es_fin_semana     BIT          NOT NULL,
    temporada         NVARCHAR(25) NOT NULL
);
GO
;WITH n AS (
    SELECT TOP (DATEDIFF(DAY, '2024-01-01', '2027-12-31') + 1)
           ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS i
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
), f AS (
    SELECT DATEADD(DAY, i, CAST('2024-01-01' AS DATE)) AS fecha FROM n
)
INSERT INTO dbo.dim_tiempo
SELECT CONVERT(INT, CONVERT(CHAR(8), fecha, 112)),
       fecha,
       YEAR(fecha),
       CASE WHEN MONTH(fecha) <= 6 THEN 1 ELSE 2 END,
       DATEPART(QUARTER, fecha),
       MONTH(fecha),
       CHOOSE(MONTH(fecha), N'Enero', N'Febrero', N'Marzo', N'Abril', N'Mayo', N'Junio', N'Julio',
                            N'Agosto', N'Septiembre', N'Octubre', N'Noviembre', N'Diciembre'),
       CONVERT(CHAR(7), fecha, 120),
       DATEPART(ISO_WEEK, fecha),
       DAY(fecha),
       ds.d,
       CHOOSE(ds.d, N'Lunes', N'Martes', N'Miércoles', N'Jueves', N'Viernes', N'Sábado', N'Domingo'),
       CASE WHEN ds.d >= 6 THEN 1 ELSE 0 END,
       CASE WHEN MONTH(fecha) BETWEEN 5 AND 8 THEN N'Campaña cafetalera'
            WHEN MONTH(fecha) = 12            THEN N'Campaña navideña'
            ELSE N'Temporada regular' END
FROM f
CROSS APPLY (SELECT DATEDIFF(DAY, '19000101', fecha) % 7 + 1 AS d) ds;   -- 01/01/1900 fue lunes
GO

-- 3.2 DIM_SUCURSAL
CREATE TABLE dbo.dim_sucursal (
    sucursal_sk        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_dim_sucursal PRIMARY KEY,
    sucursal_codigo    CHAR(3)       NOT NULL CONSTRAINT UQ_dim_sucursal_codigo UNIQUE,   -- clave de negocio
    sucursal_nombre    NVARCHAR(120) NOT NULL,
    ciudad             NVARCHAR(80)  NOT NULL,
    departamento       NVARCHAR(80)  NOT NULL,
    region             NVARCHAR(30)  NOT NULL,
    fecha_actualizacion DATETIME2(0) NOT NULL CONSTRAINT DF_dim_sucursal_fecha DEFAULT (SYSDATETIME())
);
-- 3.3 DIM_RUTA
CREATE TABLE dbo.dim_ruta (
    ruta_sk            INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_dim_ruta PRIMARY KEY,
    codigo_ruta        CHAR(7)       NOT NULL CONSTRAINT UQ_dim_ruta_codigo UNIQUE,
    ciudad_origen      NVARCHAR(80)  NOT NULL,
    ciudad_destino     NVARCHAR(80)  NOT NULL,
    descripcion_ruta   NVARCHAR(170) NOT NULL,
    distancia_km       DECIMAL(7,1)  NOT NULL,
    horas_estimadas    DECIMAL(4,1)  NOT NULL,
    tipo_ruta          NVARCHAR(10)  NOT NULL,      -- Corta / Media / Larga
    fecha_actualizacion DATETIME2(0) NOT NULL CONSTRAINT DF_dim_ruta_fecha DEFAULT (SYSDATETIME())
);
-- 3.4 DIM_VEHICULO
CREATE TABLE dbo.dim_vehiculo (
    vehiculo_sk        INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_dim_vehiculo PRIMARY KEY,
    placa              VARCHAR(10)   NOT NULL CONSTRAINT UQ_dim_vehiculo_placa UNIQUE,
    marca              NVARCHAR(60)  NOT NULL,
    modelo             NVARCHAR(60)  NOT NULL,
    anio_fabricacion   SMALLINT      NOT NULL,
    capacidad_carga_kg DECIMAL(10,2) NOT NULL,
    categoria          NVARCHAR(10)  NOT NULL,      -- Liviano / Mediano / Pesado
    fecha_actualizacion DATETIME2(0) NOT NULL CONSTRAINT DF_dim_vehiculo_fecha DEFAULT (SYSDATETIME())
);
-- 3.5 DIM_ESTADO_ENCOMIENDA
CREATE TABLE dbo.dim_estado_encomienda (
    estado_sk          INT IDENTITY(1,1) NOT NULL CONSTRAINT PK_dim_estado PRIMARY KEY,
    estado_codigo      VARCHAR(12)   NOT NULL CONSTRAINT UQ_dim_estado_codigo UNIQUE,
    estado_descripcion NVARCHAR(40)  NOT NULL,
    es_estado_final    BIT           NOT NULL,
    fecha_actualizacion DATETIME2(0) NOT NULL CONSTRAINT DF_dim_estado_fecha DEFAULT (SYSDATETIME())
);
GO

-- 3.6 Miembros "Desconocido" (SK = -1)
INSERT INTO dbo.dim_tiempo VALUES (-1, '1900-01-01', 1900, 1, 1, 1, N'N/D', '1900-01', 1, 1, 1, N'N/D', 0, N'N/D');
SET IDENTITY_INSERT dbo.dim_sucursal ON;
INSERT INTO dbo.dim_sucursal (sucursal_sk, sucursal_codigo, sucursal_nombre, ciudad, departamento, region)
VALUES (-1, 'N/D', N'Desconocida', N'N/D', N'N/D', N'N/D');
SET IDENTITY_INSERT dbo.dim_sucursal OFF;
SET IDENTITY_INSERT dbo.dim_ruta ON;
INSERT INTO dbo.dim_ruta (ruta_sk, codigo_ruta, ciudad_origen, ciudad_destino, descripcion_ruta, distancia_km, horas_estimadas, tipo_ruta)
VALUES (-1, 'N/D', N'N/D', N'N/D', N'Ruta desconocida', 0, 0, N'N/D');
SET IDENTITY_INSERT dbo.dim_ruta OFF;
SET IDENTITY_INSERT dbo.dim_vehiculo ON;
INSERT INTO dbo.dim_vehiculo (vehiculo_sk, placa, marca, modelo, anio_fabricacion, capacidad_carga_kg, categoria)
VALUES (-1, 'N/D', N'N/D', N'N/D', 0, 0, N'N/D');
SET IDENTITY_INSERT dbo.dim_vehiculo OFF;
SET IDENTITY_INSERT dbo.dim_estado_encomienda ON;
INSERT INTO dbo.dim_estado_encomienda (estado_sk, estado_codigo, estado_descripcion, es_estado_final)
VALUES (-1, 'N/D', N'Estado desconocido', 0);
SET IDENTITY_INSERT dbo.dim_estado_encomienda OFF;
GO
PRINT N'FASE 3 OK: 5 dimensiones creadas (dim_tiempo con 1 461 días).';
GO

/* =============================================================================
   FASE 4. TABLA DE HECHOS
   Métricas ADITIVAS (se pueden sumar por cualquier dimensión):
   cantidad_encomiendas, peso_kg, ingreso_envio, costo_asignado, margen.
   ============================================================================= */
CREATE TABLE dbo.fact_encomiendas (
    fact_id              BIGINT IDENTITY(1,1) NOT NULL CONSTRAINT PK_fact_encomiendas PRIMARY KEY,
    tiempo_id            INT           NOT NULL CONSTRAINT FK_fact_tiempo   REFERENCES dbo.dim_tiempo (tiempo_id),
    sucursal_sk          INT           NOT NULL CONSTRAINT FK_fact_sucursal REFERENCES dbo.dim_sucursal (sucursal_sk),
    ruta_sk              INT           NOT NULL CONSTRAINT FK_fact_ruta     REFERENCES dbo.dim_ruta (ruta_sk),
    vehiculo_sk          INT           NOT NULL CONSTRAINT FK_fact_vehiculo REFERENCES dbo.dim_vehiculo (vehiculo_sk),
    estado_sk            INT           NOT NULL CONSTRAINT FK_fact_estado   REFERENCES dbo.dim_estado_encomienda (estado_sk),
    -- dimensiones degeneradas (trazabilidad hacia la OLTP)
    encomienda_id_oltp   INT           NOT NULL CONSTRAINT UQ_fact_encomienda UNIQUE,
    codigo_rastreo       VARCHAR(20)   NOT NULL,
    codigo_viaje         VARCHAR(20)   NOT NULL,
    -- métricas
    cantidad_encomiendas INT           NOT NULL CONSTRAINT DF_fact_cantidad DEFAULT (1),
    peso_kg              DECIMAL(10,2) NOT NULL,
    ingreso_envio        DECIMAL(12,2) NOT NULL,
    costo_asignado       DECIMAL(12,2) NOT NULL,
    margen               DECIMAL(12,2) NOT NULL,
    fecha_carga          DATETIME2(0)  NOT NULL CONSTRAINT DF_fact_fecha DEFAULT (SYSDATETIME())
);
GO
CREATE NONCLUSTERED INDEX IX_fact_tiempo   ON dbo.fact_encomiendas (tiempo_id)   INCLUDE (ingreso_envio, costo_asignado, margen, peso_kg);
CREATE NONCLUSTERED INDEX IX_fact_sucursal ON dbo.fact_encomiendas (sucursal_sk) INCLUDE (ingreso_envio, margen);
CREATE NONCLUSTERED INDEX IX_fact_ruta     ON dbo.fact_encomiendas (ruta_sk)     INCLUDE (ingreso_envio, margen);
CREATE NONCLUSTERED INDEX IX_fact_vehiculo ON dbo.fact_encomiendas (vehiculo_sk) INCLUDE (peso_kg, ingreso_envio);
CREATE NONCLUSTERED INDEX IX_fact_estado   ON dbo.fact_encomiendas (estado_sk);
GO
PRINT N'FASE 4 OK: fact_encomiendas creada con 5 FK indexadas.';
GO

/* =============================================================================
   FASE 5. PROCEDIMIENTO ETL
   E: extrae de AkilFlowOperaciones (solo viajes completados / en curso; los
      cancelados no generan ingreso ni costo real).
   T: limpieza (LTRIM/RTRIM/UPPER), prorrateo del costo del viaje según el
      peso de cada encomienda: costo_asignado = costo_viaje * peso / peso_total.
   L: MERGE incremental de dimensiones (SCD Tipo 1) y de hechos.
   ============================================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_etl_akilflow
AS
BEGIN
    SET NOCOUNT ON;
    SET XACT_ABORT ON;

    DECLARE @log_id INT, @filas_stg INT,
            @dims_ins INT = 0, @dims_upd INT = 0;
    DECLARE @acciones TABLE (accion NVARCHAR(10));
    DECLARE @acciones_fact TABLE (accion NVARCHAR(10));

    INSERT INTO dbo.etl_log (inicio, estado) VALUES (SYSDATETIME(), 'EN CURSO');
    SET @log_id = SCOPE_IDENTITY();

    BEGIN TRY
        /* ---------- E + T : EXTRACCIÓN A STAGING CON LIMPIEZA ---------- */
        TRUNCATE TABLE dbo.staging_encomiendas;

        INSERT INTO dbo.staging_encomiendas (
            encomienda_id, codigo_rastreo, codigo_viaje, fecha_salida,
            origen_codigo, origen_nombre, origen_ciudad, origen_departamento,
            destino_codigo, destino_nombre, destino_ciudad, destino_departamento,
            codigo_ruta, distancia_km, horas_estimadas,
            placa, marca, modelo, anio_fabricacion, capacidad_carga_kg,
            estado_encomienda, peso_kg, precio_envio, costo_viaje, peso_total_viaje, costo_asignado)
        SELECT e.encomienda_id,
               UPPER(LTRIM(RTRIM(e.codigo_rastreo))),
               UPPER(LTRIM(RTRIM(v.codigo_viaje))),
               CAST(v.fecha_salida AS DATE),
               UPPER(LTRIM(RTRIM(so.codigo))), LTRIM(RTRIM(so.nombre)), LTRIM(RTRIM(so.ciudad)), LTRIM(RTRIM(so.departamento)),
               UPPER(LTRIM(RTRIM(sd.codigo))), LTRIM(RTRIM(sd.nombre)), LTRIM(RTRIM(sd.ciudad)), LTRIM(RTRIM(sd.departamento)),
               UPPER(LTRIM(RTRIM(r.codigo_ruta))), r.distancia_km, r.horas_estimadas,
               UPPER(LTRIM(RTRIM(ve.placa))), LTRIM(RTRIM(ve.marca)), LTRIM(RTRIM(ve.modelo)),
               ve.anio_fabricacion, ve.capacidad_carga_kg,
               LOWER(LTRIM(RTRIM(e.estado))),
               e.peso_kg,
               e.precio_envio,
               v.costo_estimado,
               SUM(e.peso_kg) OVER (PARTITION BY v.viaje_id),
               CAST(ROUND(v.costo_estimado * e.peso_kg / NULLIF(SUM(e.peso_kg) OVER (PARTITION BY v.viaje_id), 0), 2)
                    AS DECIMAL(12,2))
        FROM AkilFlowOperaciones.dbo.encomiendas e
        JOIN AkilFlowOperaciones.dbo.viajes      v  ON v.viaje_id     = e.viaje_id
        JOIN AkilFlowOperaciones.dbo.rutas       r  ON r.ruta_id      = v.ruta_id
        JOIN AkilFlowOperaciones.dbo.sucursales  so ON so.sucursal_id = r.sucursal_origen_id
        JOIN AkilFlowOperaciones.dbo.sucursales  sd ON sd.sucursal_id = r.sucursal_destino_id
        JOIN AkilFlowOperaciones.dbo.vehiculos   ve ON ve.vehiculo_id = v.vehiculo_id
        WHERE v.estado IN ('completado', 'en_curso');

        SET @filas_stg = @@ROWCOUNT;

        /* ---------- T : REGLAS DE CALIDAD -> CUARENTENA (etl_errores) ---------- */
        DELETE s
        OUTPUT @log_id, deleted.encomienda_id, deleted.codigo_rastreo,
               CASE WHEN deleted.peso_kg IS NULL OR deleted.peso_kg <= 0        THEN N'Peso nulo o no positivo'
                    WHEN deleted.precio_envio IS NULL OR deleted.precio_envio < 0 THEN N'Precio nulo o negativo'
                    WHEN deleted.fecha_salida IS NULL                           THEN N'Viaje sin fecha de salida'
                    WHEN deleted.costo_asignado IS NULL                         THEN N'No se pudo prorratear el costo'
                    ELSE N'Placa o ruta vacía' END
        INTO dbo.etl_errores (ejecucion_id, encomienda_id, codigo_rastreo, regla_fallida)
        FROM dbo.staging_encomiendas s
        WHERE s.peso_kg IS NULL OR s.peso_kg <= 0
           OR s.precio_envio IS NULL OR s.precio_envio < 0
           OR s.fecha_salida IS NULL
           OR s.costo_asignado IS NULL
           OR ISNULL(s.placa, '') = '' OR ISNULL(s.codigo_ruta, '') = '';

        UPDATE dbo.etl_log SET filas_rechazadas = @@ROWCOUNT WHERE ejecucion_id = @log_id;
        SET @filas_stg = @filas_stg - (SELECT filas_rechazadas FROM dbo.etl_log WHERE ejecucion_id = @log_id);

        BEGIN TRAN;

        /* ---------- L : MERGE DE DIMENSIONES (SCD Tipo 1) ---------- */
        -- dim_sucursal (origen y destino)
        MERGE dbo.dim_sucursal AS d
        USING (
            SELECT DISTINCT origen_codigo AS codigo, origen_nombre AS nombre, origen_ciudad AS ciudad, origen_departamento AS departamento
            FROM dbo.staging_encomiendas
            UNION
            SELECT DISTINCT destino_codigo, destino_nombre, destino_ciudad, destino_departamento
            FROM dbo.staging_encomiendas
        ) AS s ON d.sucursal_codigo = s.codigo
        WHEN MATCHED AND (d.sucursal_nombre <> s.nombre OR d.ciudad <> s.ciudad OR d.departamento <> s.departamento) THEN
            UPDATE SET sucursal_nombre = s.nombre, ciudad = s.ciudad, departamento = s.departamento,
                       fecha_actualizacion = SYSDATETIME()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (sucursal_codigo, sucursal_nombre, ciudad, departamento, region)
            VALUES (s.codigo, s.nombre, s.ciudad, s.departamento,
                    CASE s.departamento WHEN N'Lambayeque' THEN N'Costa Norte'
                                        WHEN N'Cajamarca'  THEN N'Sierra Norte'
                                        ELSE N'Nororiente Amazónico' END)
        OUTPUT $action INTO @acciones;

        -- dim_ruta
        MERGE dbo.dim_ruta AS d
        USING (
            SELECT DISTINCT codigo_ruta, origen_ciudad, destino_ciudad, distancia_km, horas_estimadas
            FROM dbo.staging_encomiendas
        ) AS s ON d.codigo_ruta = s.codigo_ruta
        WHEN MATCHED AND (d.distancia_km <> s.distancia_km OR d.horas_estimadas <> s.horas_estimadas) THEN
            UPDATE SET distancia_km = s.distancia_km, horas_estimadas = s.horas_estimadas,
                       tipo_ruta = CASE WHEN s.distancia_km < 150 THEN N'Corta' WHEN s.distancia_km < 400 THEN N'Media' ELSE N'Larga' END,
                       fecha_actualizacion = SYSDATETIME()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (codigo_ruta, ciudad_origen, ciudad_destino, descripcion_ruta, distancia_km, horas_estimadas, tipo_ruta)
            VALUES (s.codigo_ruta, s.origen_ciudad, s.destino_ciudad, CONCAT(s.origen_ciudad, N' - ', s.destino_ciudad),
                    s.distancia_km, s.horas_estimadas,
                    CASE WHEN s.distancia_km < 150 THEN N'Corta' WHEN s.distancia_km < 400 THEN N'Media' ELSE N'Larga' END)
        OUTPUT $action INTO @acciones;

        -- dim_vehiculo
        MERGE dbo.dim_vehiculo AS d
        USING (
            SELECT DISTINCT placa, marca, modelo, anio_fabricacion, capacidad_carga_kg
            FROM dbo.staging_encomiendas
        ) AS s ON d.placa = s.placa
        WHEN MATCHED AND (d.marca <> s.marca OR d.modelo <> s.modelo OR d.capacidad_carga_kg <> s.capacidad_carga_kg) THEN
            UPDATE SET marca = s.marca, modelo = s.modelo, capacidad_carga_kg = s.capacidad_carga_kg,
                       categoria = CASE WHEN s.capacidad_carga_kg <= 5000 THEN N'Liviano' WHEN s.capacidad_carga_kg <= 8000 THEN N'Mediano' ELSE N'Pesado' END,
                       fecha_actualizacion = SYSDATETIME()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (placa, marca, modelo, anio_fabricacion, capacidad_carga_kg, categoria)
            VALUES (s.placa, s.marca, s.modelo, s.anio_fabricacion, s.capacidad_carga_kg,
                    CASE WHEN s.capacidad_carga_kg <= 5000 THEN N'Liviano' WHEN s.capacidad_carga_kg <= 8000 THEN N'Mediano' ELSE N'Pesado' END)
        OUTPUT $action INTO @acciones;

        -- dim_estado_encomienda
        MERGE dbo.dim_estado_encomienda AS d
        USING (SELECT DISTINCT estado_encomienda AS codigo FROM dbo.staging_encomiendas) AS s
            ON d.estado_codigo = s.codigo
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (estado_codigo, estado_descripcion, es_estado_final)
            VALUES (s.codigo,
                    CASE s.codigo WHEN 'recibida'    THEN N'Recibida en agencia'
                                  WHEN 'en_transito' THEN N'En tránsito'
                                  WHEN 'entregada'   THEN N'Entregada al destinatario'
                                  WHEN 'devuelta'    THEN N'Devuelta al remitente'
                                  ELSE N'Otro' END,
                    CASE WHEN s.codigo IN ('entregada', 'devuelta') THEN 1 ELSE 0 END)
        OUTPUT $action INTO @acciones;

        SELECT @dims_ins = SUM(CASE WHEN accion = 'INSERT' THEN 1 ELSE 0 END),
               @dims_upd = SUM(CASE WHEN accion = 'UPDATE' THEN 1 ELSE 0 END)
        FROM @acciones;

        /* ---------- L : MERGE DE HECHOS (carga incremental) ---------- */
        MERGE dbo.fact_encomiendas AS f
        USING (
            SELECT s.encomienda_id, s.codigo_rastreo, s.codigo_viaje,
                   ISNULL(t.tiempo_id, -1)       AS tiempo_id,
                   ISNULL(ds.sucursal_sk, -1)     AS sucursal_sk,
                   ISNULL(dr.ruta_sk, -1)         AS ruta_sk,
                   ISNULL(dv.vehiculo_sk, -1)     AS vehiculo_sk,
                   ISNULL(de.estado_sk, -1)       AS estado_sk,
                   s.peso_kg, s.precio_envio, s.costo_asignado,
                   s.precio_envio - s.costo_asignado AS margen
            FROM dbo.staging_encomiendas s
            LEFT JOIN dbo.dim_tiempo            t  ON t.fecha            = s.fecha_salida
            LEFT JOIN dbo.dim_sucursal          ds ON ds.sucursal_codigo = s.origen_codigo
            LEFT JOIN dbo.dim_ruta              dr ON dr.codigo_ruta     = s.codigo_ruta
            LEFT JOIN dbo.dim_vehiculo          dv ON dv.placa           = s.placa
            LEFT JOIN dbo.dim_estado_encomienda de ON de.estado_codigo   = s.estado_encomienda
        ) AS s ON f.encomienda_id_oltp = s.encomienda_id
        WHEN MATCHED AND (f.estado_sk <> s.estado_sk OR f.costo_asignado <> s.costo_asignado
                          OR f.ingreso_envio <> s.precio_envio OR f.peso_kg <> s.peso_kg) THEN
            UPDATE SET estado_sk = s.estado_sk, peso_kg = s.peso_kg, ingreso_envio = s.precio_envio,
                       costo_asignado = s.costo_asignado, margen = s.margen, fecha_carga = SYSDATETIME()
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (tiempo_id, sucursal_sk, ruta_sk, vehiculo_sk, estado_sk, encomienda_id_oltp,
                    codigo_rastreo, codigo_viaje, cantidad_encomiendas, peso_kg, ingreso_envio, costo_asignado, margen)
            VALUES (s.tiempo_id, s.sucursal_sk, s.ruta_sk, s.vehiculo_sk, s.estado_sk, s.encomienda_id,
                    s.codigo_rastreo, s.codigo_viaje, 1, s.peso_kg, s.precio_envio, s.costo_asignado, s.margen)
        OUTPUT $action INTO @acciones_fact;

        COMMIT;

        UPDATE dbo.etl_log
        SET fin = SYSDATETIME(), filas_staging = @filas_stg, estado = 'OK',
            hechos_insertados   = (SELECT COUNT(*) FROM @acciones_fact WHERE accion = 'INSERT'),
            hechos_actualizados = (SELECT COUNT(*) FROM @acciones_fact WHERE accion = 'UPDATE'),
            dims_insertadas = ISNULL(@dims_ins, 0), dims_actualizadas = ISNULL(@dims_upd, 0),
            mensaje = N'Carga completada'
        WHERE ejecucion_id = @log_id;
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0 ROLLBACK;
        UPDATE dbo.etl_log
        SET fin = SYSDATETIME(), estado = 'ERROR', mensaje = ERROR_MESSAGE()
        WHERE ejecucion_id = @log_id;
        THROW;
    END CATCH;

    SELECT * FROM dbo.etl_log WHERE ejecucion_id = @log_id;
END;
GO
PRINT N'FASE 5 OK: procedimiento dbo.usp_etl_akilflow creado.';
GO

/* =============================================================================
   FASE 6. AUTOMATIZACIÓN CON SQL SERVER AGENT (todos los días 02:00)
   En Express (sin Agent) se omite y puede programarse con el Programador
   de tareas de Windows: sqlcmd -S . -E -Q "EXEC dwh_AkilFlow.dbo.usp_etl_akilflow"
   ============================================================================= */
IF CAST(SERVERPROPERTY('EngineEdition') AS INT) <> 4
   AND EXISTS (SELECT 1 FROM msdb.sys.objects WHERE name = N'sp_add_job')
BEGIN
    BEGIN TRY
        IF EXISTS (SELECT 1 FROM msdb.dbo.sysjobs WHERE name = N'ETL_AkilFlow_Diario')
            EXEC msdb.dbo.sp_delete_job @job_name = N'ETL_AkilFlow_Diario';

        EXEC msdb.dbo.sp_add_job        @job_name = N'ETL_AkilFlow_Diario',
                                        @description = N'Carga incremental OLTP AkilFlowOperaciones -> dwh_AkilFlow';
        EXEC msdb.dbo.sp_add_jobstep    @job_name = N'ETL_AkilFlow_Diario', @step_name = N'Ejecutar ETL',
                                        @subsystem = N'TSQL', @database_name = N'dwh_AkilFlow',
                                        @command = N'EXEC dbo.usp_etl_akilflow;',
                                        @retry_attempts = 2, @retry_interval = 5;
        EXEC msdb.dbo.sp_add_schedule   @schedule_name = N'Diario_0200', @freq_type = 4, @freq_interval = 1,
                                        @active_start_time = 020000;
        EXEC msdb.dbo.sp_attach_schedule @job_name = N'ETL_AkilFlow_Diario', @schedule_name = N'Diario_0200';
        EXEC msdb.dbo.sp_add_jobserver  @job_name = N'ETL_AkilFlow_Diario', @server_name = N'(local)';
        PRINT N'FASE 6 OK: Job ETL_AkilFlow_Diario programado (02:00 diario).';
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'FASE 6: no se pudo crear el Job (', ERROR_MESSAGE(), N'). Ejecute el ETL manualmente.');
    END CATCH;
END
ELSE
    PRINT N'FASE 6: edición sin SQL Server Agent. Programe el ETL con el Programador de tareas de Windows.';
GO

/* =============================================================================
   FASE 7. PRIMERA CARGA + CONCILIACIÓN
   ============================================================================= */
EXEC dbo.usp_etl_akilflow;
GO

-- 7.1 Conciliación Staging vs Fact (filas, ingresos, costos y peso deben coincidir)
SELECT 'Staging'                     AS origen,
       COUNT(*)                      AS filas,
       SUM(precio_envio)             AS ingresos,
       SUM(costo_asignado)           AS costos,
       SUM(peso_kg)                  AS peso_kg
FROM dbo.staging_encomiendas
UNION ALL
SELECT 'Fact', SUM(cantidad_encomiendas), SUM(ingreso_envio), SUM(costo_asignado), SUM(peso_kg)
FROM dbo.fact_encomiendas;

-- 7.2 Conciliación OLTP vs DWH del costo de viajes (diferencia = redondeo del prorrateo)
SELECT CAST(o.costo_oltp AS DECIMAL(14,2)) AS costo_viajes_oltp,
       CAST(d.costo_dwh  AS DECIMAL(14,2)) AS costo_prorrateado_dwh,
       CAST(o.costo_oltp - d.costo_dwh AS DECIMAL(14,2)) AS diferencia_redondeo
FROM (SELECT SUM(costo_estimado) AS costo_oltp
      FROM AkilFlowOperaciones.dbo.viajes v
      WHERE v.estado IN ('completado', 'en_curso')
        AND EXISTS (SELECT 1 FROM AkilFlowOperaciones.dbo.encomiendas e WHERE e.viaje_id = v.viaje_id)) o
CROSS JOIN (SELECT SUM(costo_asignado) AS costo_dwh FROM dbo.fact_encomiendas) d;

-- 7.3 Integridad referencial del esquema estrella (0 huérfanos / 0 desconocidos)
SELECT SUM(CASE WHEN sucursal_sk = -1 OR ruta_sk = -1 OR vehiculo_sk = -1 OR estado_sk = -1 THEN 1 ELSE 0 END)
       AS hechos_con_dimension_desconocida
FROM dbo.fact_encomiendas;

-- 7.4 Volumen por tabla
SELECT 'dim_tiempo' AS tabla, COUNT(*) AS filas FROM dbo.dim_tiempo
UNION ALL SELECT 'dim_sucursal',          COUNT(*) FROM dbo.dim_sucursal          WHERE sucursal_sk > 0
UNION ALL SELECT 'dim_ruta',              COUNT(*) FROM dbo.dim_ruta              WHERE ruta_sk > 0
UNION ALL SELECT 'dim_vehiculo',          COUNT(*) FROM dbo.dim_vehiculo          WHERE vehiculo_sk > 0
UNION ALL SELECT 'dim_estado_encomienda', COUNT(*) FROM dbo.dim_estado_encomienda WHERE estado_sk > 0
UNION ALL SELECT 'fact_encomiendas',      COUNT(*) FROM dbo.fact_encomiendas;
GO

/* =============================================================================
   FASE 8. CARGA INCREMENTAL - SIMULACIÓN DE UN NUEVO DÍA
   El viaje en curso más antiguo llega a destino: sus encomiendas pasan a
   "entregada". El ETL solo ACTUALIZA esas filas (no recarga todo).
   ============================================================================= */
DECLARE @viaje INT = (SELECT TOP (1) viaje_id FROM AkilFlowOperaciones.dbo.viajes
                      WHERE estado = 'en_curso' ORDER BY fecha_salida);
IF @viaje IS NOT NULL
BEGIN
    UPDATE AkilFlowOperaciones.dbo.viajes
    SET estado = 'completado', fecha_llegada = DATEADD(HOUR, 3, fecha_salida)
    WHERE viaje_id = @viaje;
    UPDATE AkilFlowOperaciones.dbo.encomiendas
    SET estado = 'entregada'
    WHERE viaje_id = @viaje;
    PRINT CONCAT(N'Viaje ', @viaje, N' completado en la OLTP. Ejecutando ETL incremental...');
END;
GO
EXEC dbo.usp_etl_akilflow;     -- hechos_insertados = 0, hechos_actualizados = n.° de encomiendas del viaje
GO
SELECT ejecucion_id, inicio, fin, filas_staging, filas_rechazadas, hechos_insertados, hechos_actualizados,
       dims_insertadas, dims_actualizadas, estado
FROM dbo.etl_log ORDER BY ejecucion_id;
GO

/* =============================================================================
   FASE 9. PRUEBA DEL MANEJO DE ERRORES (cuarentena)
   Se simula un dato corrupto que llega a Staging (precio negativo, como si
   viniera de un archivo Excel externo). La regla de calidad lo redirige a
   etl_errores y NO contamina la tabla de hechos.
   ============================================================================= */
DECLARE @log_id INT;
INSERT INTO dbo.etl_log (inicio, estado, mensaje) VALUES (SYSDATETIME(), 'PRUEBA', N'Prueba de cuarentena');
SET @log_id = SCOPE_IDENTITY();

INSERT INTO dbo.staging_encomiendas (encomienda_id, codigo_rastreo, codigo_viaje, fecha_salida, codigo_ruta,
                                     placa, estado_encomienda, peso_kg, precio_envio, costo_asignado)
VALUES (-999, 'AK-EXCEL-ERR01', 'VJ-EXTERNO', '2026-11-25', 'JAE-CIX', 'T3A-845', 'recibida', 12.00, -40.00, 5.00);

DELETE s
OUTPUT @log_id, deleted.encomienda_id, deleted.codigo_rastreo, N'Precio nulo o negativo'
INTO dbo.etl_errores (ejecucion_id, encomienda_id, codigo_rastreo, regla_fallida)
FROM dbo.staging_encomiendas s
WHERE s.precio_envio < 0;

UPDATE dbo.etl_log SET fin = SYSDATETIME(), filas_rechazadas = @@ROWCOUNT, estado = 'OK' WHERE ejecucion_id = @log_id;

SELECT error_id, ejecucion_id, codigo_rastreo, regla_fallida, fecha FROM dbo.etl_errores;
SELECT COUNT(*) AS hechos_con_codigo_erroneo
FROM dbo.fact_encomiendas WHERE codigo_rastreo = 'AK-EXCEL-ERR01';   -- 0: no llegó al DWH
GO

PRINT N'=== SCRIPT 04 FINALIZADO: dwh_AkilFlow cargado (Staging + Estrella + ETL MERGE). ===';
GO
