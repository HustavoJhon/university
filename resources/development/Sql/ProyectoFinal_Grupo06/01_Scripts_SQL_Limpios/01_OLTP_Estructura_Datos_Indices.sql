/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 01_OLTP_Estructura_Datos_Indices.sql
   Base    : AkilFlowOperaciones (entorno transaccional OLTP)
   Criterio: 2 - Diseño OLTP (3FN) e Indexación T-SQL
   -----------------------------------------------------------------------------
   Orden de ejecución: 01 -> 02 -> 03 -> 04 -> 05  (ejecutar con F5 completo)
   Requisitos       : SQL Server 2019/2022 Developer, Standard o Enterprise.
   Contenido:
     FASE 1. Creación limpia de la base de datos
     FASE 2. Modelo relacional en 3FN (7 tablas, PK/FK/UNIQUE/DEFAULT/CHECK)
     FASE 3. Población de datos coherentes (ene-2025 a nov-2026)
     FASE 4. Demo de Plan de Ejecución: ANTES del índice (Clustered Index Scan)
     FASE 5. Estrategia de indexación Clúster / No Clúster
     FASE 6. Demo de Plan de Ejecución: DESPUÉS (Seek + Key Lookup -> Covering)
     FASE 7. Verificación del modelo y de los índices
   ============================================================================= */

/* =============================================================================
   FASE 1. CREACIÓN LIMPIA DE LA BASE DE DATOS
   ============================================================================= */
USE master;
GO

IF DB_ID(N'AkilFlowOperaciones') IS NOT NULL
BEGIN
    ALTER DATABASE AkilFlowOperaciones SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE AkilFlowOperaciones;
END;
GO

CREATE DATABASE AkilFlowOperaciones;
GO

ALTER DATABASE AkilFlowOperaciones SET RECOVERY FULL;   -- requerido por el DRP (script 03)
GO

USE AkilFlowOperaciones;
GO
SET ANSI_NULLS ON;
SET QUOTED_IDENTIFIER ON;
SET NOCOUNT ON;
GO

/* =============================================================================
   FASE 2. MODELO RELACIONAL EN TERCERA FORMA NORMAL (3FN)
   -----------------------------------------------------------------------------
   empresas 1--N sucursales 1--N usuarios_sistema
   sucursales 1--N rutas (origen y destino)     rutas 1--N viajes
   vehiculos 1--N viajes   usuarios(conductor) 1--N viajes
   viajes 1--N encomiendas  usuarios(despachador) 1--N encomiendas
   - Cada atributo no clave depende solo de la PK (no hay dependencias
     transitivas): la distancia y la tarifa dependen de la RUTA, no del viaje;
     la ciudad depende de la SUCURSAL, no del viaje ni de la encomienda.
   ============================================================================= */

-- 2.1 EMPRESAS --------------------------------------------------------------
CREATE TABLE dbo.empresas (
    empresa_id      INT IDENTITY(1,1) NOT NULL,
    razon_social    NVARCHAR(180)     NOT NULL,
    ruc             CHAR(11)          NOT NULL,
    telefono        VARCHAR(20)       NULL,
    direccion       NVARCHAR(250)     NULL,
    fecha_registro  DATETIME2(0)      NOT NULL CONSTRAINT DF_empresas_fecha  DEFAULT (SYSDATETIME()),
    activo          BIT               NOT NULL CONSTRAINT DF_empresas_activo DEFAULT (1),
    CONSTRAINT PK_empresas      PRIMARY KEY CLUSTERED (empresa_id),
    CONSTRAINT UQ_empresas_ruc  UNIQUE (ruc),
    CONSTRAINT CK_empresas_ruc  CHECK (ruc NOT LIKE '%[^0-9]%' AND LEN(ruc) = 11)
);
GO

-- 2.2 SUCURSALES (agencias) -------------------------------------------------
CREATE TABLE dbo.sucursales (
    sucursal_id   INT IDENTITY(1,1) NOT NULL,
    empresa_id    INT               NOT NULL,
    codigo        CHAR(3)           NOT NULL,
    nombre        NVARCHAR(120)     NOT NULL,
    ciudad        NVARCHAR(80)      NOT NULL,
    departamento  NVARCHAR(80)      NOT NULL,
    es_sede_central BIT             NOT NULL CONSTRAINT DF_sucursales_sede   DEFAULT (0),
    activo        BIT               NOT NULL CONSTRAINT DF_sucursales_activo DEFAULT (1),
    CONSTRAINT PK_sucursales         PRIMARY KEY CLUSTERED (sucursal_id),
    CONSTRAINT FK_sucursales_empresa FOREIGN KEY (empresa_id) REFERENCES dbo.empresas (empresa_id),
    CONSTRAINT UQ_sucursales_codigo  UNIQUE (empresa_id, codigo)
);
GO

-- 2.3 USUARIOS DEL SISTEMA (personal de negocio, no confundir con logins SQL) -
CREATE TABLE dbo.usuarios_sistema (
    usuario_id      INT IDENTITY(1,1) NOT NULL,
    sucursal_id     INT               NOT NULL,
    nombre_completo NVARCHAR(150)     NOT NULL,
    nombre_usuario  VARCHAR(60)       NOT NULL,
    correo          VARCHAR(150)      NOT NULL,
    cargo           NVARCHAR(40)      NOT NULL,
    activo          BIT               NOT NULL CONSTRAINT DF_usuarios_activo DEFAULT (1),
    CONSTRAINT PK_usuarios_sistema   PRIMARY KEY CLUSTERED (usuario_id),
    CONSTRAINT FK_usuarios_sucursal  FOREIGN KEY (sucursal_id) REFERENCES dbo.sucursales (sucursal_id),
    CONSTRAINT UQ_usuarios_nombre    UNIQUE (nombre_usuario),
    CONSTRAINT UQ_usuarios_correo    UNIQUE (correo),
    CONSTRAINT CK_usuarios_correo    CHECK (correo LIKE '%_@_%._%'),
    CONSTRAINT CK_usuarios_cargo     CHECK (cargo IN (N'Gerente General', N'Jefe de Operaciones', N'Contador',
                                                       N'Administrador BD', N'Conductor', N'Despachador'))
);
GO
-- Nota 3FN: empresa_id NO se repite aquí; se obtiene vía sucursal -> empresa
-- (evita la dependencia transitiva usuario -> sucursal -> empresa).

-- 2.4 RUTAS (origen-destino entre sucursales) --------------------------------
CREATE TABLE dbo.rutas (
    ruta_id             INT IDENTITY(1,1) NOT NULL,
    codigo_ruta         CHAR(7)           NOT NULL,        -- ej. JAE-CIX
    sucursal_origen_id  INT               NOT NULL,
    sucursal_destino_id INT               NOT NULL,
    distancia_km        DECIMAL(7,1)      NOT NULL,
    horas_estimadas     DECIMAL(4,1)      NOT NULL,
    tarifa_kg           DECIMAL(6,2)      NOT NULL,        -- S/ por kg
    activo              BIT               NOT NULL CONSTRAINT DF_rutas_activo DEFAULT (1),
    CONSTRAINT PK_rutas            PRIMARY KEY CLUSTERED (ruta_id),
    CONSTRAINT UQ_rutas_codigo     UNIQUE (codigo_ruta),
    CONSTRAINT UQ_rutas_par        UNIQUE (sucursal_origen_id, sucursal_destino_id),
    CONSTRAINT FK_rutas_origen     FOREIGN KEY (sucursal_origen_id)  REFERENCES dbo.sucursales (sucursal_id),
    CONSTRAINT FK_rutas_destino    FOREIGN KEY (sucursal_destino_id) REFERENCES dbo.sucursales (sucursal_id),
    CONSTRAINT CK_rutas_distinto   CHECK (sucursal_origen_id <> sucursal_destino_id),
    CONSTRAINT CK_rutas_distancia  CHECK (distancia_km > 0),
    CONSTRAINT CK_rutas_horas      CHECK (horas_estimadas > 0),
    CONSTRAINT CK_rutas_tarifa     CHECK (tarifa_kg > 0)
);
GO

-- 2.5 VEHÍCULOS (flota) -----------------------------------------------------
CREATE TABLE dbo.vehiculos (
    vehiculo_id        INT IDENTITY(1,1) NOT NULL,
    empresa_id         INT               NOT NULL,
    placa              VARCHAR(10)       NOT NULL,
    marca              NVARCHAR(60)      NOT NULL,
    modelo             NVARCHAR(60)      NOT NULL,
    anio_fabricacion   SMALLINT          NOT NULL,
    capacidad_carga_kg DECIMAL(10,2)     NOT NULL,
    estado             VARCHAR(15)       NOT NULL CONSTRAINT DF_vehiculos_estado DEFAULT ('disponible'),
    CONSTRAINT PK_vehiculos           PRIMARY KEY CLUSTERED (vehiculo_id),
    CONSTRAINT FK_vehiculos_empresa   FOREIGN KEY (empresa_id) REFERENCES dbo.empresas (empresa_id),
    CONSTRAINT UQ_vehiculos_placa     UNIQUE (placa),
    CONSTRAINT CK_vehiculos_anio      CHECK (anio_fabricacion BETWEEN 2000 AND 2030),
    CONSTRAINT CK_vehiculos_capacidad CHECK (capacidad_carga_kg > 0),
    CONSTRAINT CK_vehiculos_estado    CHECK (estado IN ('disponible', 'en_viaje', 'mantenimiento'))
);
GO

-- 2.6 VIAJES ----------------------------------------------------------------
CREATE TABLE dbo.viajes (
    viaje_id       INT IDENTITY(1,1) NOT NULL,
    codigo_viaje   VARCHAR(20)       NOT NULL,
    ruta_id        INT               NOT NULL,
    vehiculo_id    INT               NOT NULL,
    conductor_id   INT               NOT NULL,
    fecha_salida   DATETIME2(0)      NOT NULL,
    fecha_llegada  DATETIME2(0)      NULL,
    costo_estimado DECIMAL(12,2)     NOT NULL CONSTRAINT DF_viajes_costo  DEFAULT (0),
    estado         VARCHAR(12)       NOT NULL CONSTRAINT DF_viajes_estado DEFAULT ('programado'),
    CONSTRAINT PK_viajes           PRIMARY KEY CLUSTERED (viaje_id),
    CONSTRAINT UQ_viajes_codigo    UNIQUE (codigo_viaje),
    CONSTRAINT FK_viajes_ruta      FOREIGN KEY (ruta_id)      REFERENCES dbo.rutas (ruta_id),
    CONSTRAINT FK_viajes_vehiculo  FOREIGN KEY (vehiculo_id)  REFERENCES dbo.vehiculos (vehiculo_id),
    CONSTRAINT FK_viajes_conductor FOREIGN KEY (conductor_id) REFERENCES dbo.usuarios_sistema (usuario_id),
    CONSTRAINT CK_viajes_costo     CHECK (costo_estimado >= 0),
    CONSTRAINT CK_viajes_fechas    CHECK (fecha_llegada IS NULL OR fecha_llegada > fecha_salida),
    CONSTRAINT CK_viajes_estado    CHECK (estado IN ('programado', 'en_curso', 'completado', 'cancelado'))
);
GO

-- 2.7 ENCOMIENDAS -------------------------------------------------------------
-- remitente / destinatario / documento / teléfono son DATOS SENSIBLES:
-- nacen aquí en texto plano solo para la carga inicial y el script 02 los
-- migra a VARBINARY(256) cifrado con AES_256 y ELIMINA las columnas planas.
CREATE TABLE dbo.encomiendas (
    encomienda_id         INT IDENTITY(1,1) NOT NULL,
    codigo_rastreo        VARCHAR(20)       NOT NULL,
    viaje_id              INT               NULL,          -- NULL = aún no asignada a un viaje
    usuario_registro_id   INT               NOT NULL,      -- despachador que la recibió
    remitente             NVARCHAR(120)     NOT NULL,
    documento_remitente   VARCHAR(11)       NOT NULL,      -- DNI (8) o RUC (11)
    destinatario          NVARCHAR(120)     NOT NULL,
    telefono_destinatario VARCHAR(12)       NOT NULL,
    descripcion           NVARCHAR(200)     NOT NULL,
    peso_kg               DECIMAL(10,2)     NOT NULL,
    precio_envio          DECIMAL(10,2)     NOT NULL,
    fecha_registro        DATETIME2(0)      NOT NULL CONSTRAINT DF_encomiendas_fecha  DEFAULT (SYSDATETIME()),
    estado                VARCHAR(12)       NOT NULL CONSTRAINT DF_encomiendas_estado DEFAULT ('recibida'),
    CONSTRAINT PK_encomiendas          PRIMARY KEY CLUSTERED (encomienda_id),
    CONSTRAINT UQ_encomiendas_codigo   UNIQUE (codigo_rastreo),
    CONSTRAINT FK_encomiendas_viaje    FOREIGN KEY (viaje_id)            REFERENCES dbo.viajes (viaje_id),
    CONSTRAINT FK_encomiendas_usuario  FOREIGN KEY (usuario_registro_id) REFERENCES dbo.usuarios_sistema (usuario_id),
    CONSTRAINT CK_encomiendas_peso     CHECK (peso_kg > 0 AND peso_kg <= 5000),
    CONSTRAINT CK_encomiendas_precio   CHECK (precio_envio >= 0),
    CONSTRAINT CK_encomiendas_estado   CHECK (estado IN ('recibida', 'en_transito', 'entregada', 'devuelta'))
);
GO

PRINT N'FASE 2 OK: 7 tablas creadas en 3FN con PK, FK, UNIQUE, DEFAULT y CHECK.';
GO

/* =============================================================================
   FASE 3. POBLACIÓN DE DATOS COHERENTES
   - Datos maestros escritos a mano (empresa, 6 sucursales, 14 usuarios,
     10 rutas, 8 vehículos).
   - Historial generado de forma DETERMINÍSTICA (sin RAND) para que todos
     los integrantes obtengan exactamente los mismos resultados en la demo:
       * ~697 viajes diarios (01/01/2025 - 28/11/2026)
       * ~6 900 encomiendas con estacionalidad (campaña del café may-ago y
         campaña navideña de diciembre) y crecimiento en 2026.
   ============================================================================= */

-- 3.1 Empresa
INSERT INTO dbo.empresas (razon_social, ruc, telefono, direccion)
VALUES (N'Transportes Akil S.A.C.', '20601234567', '076-431520', N'Av. Mesones Muro 1250, Jaén, Cajamarca');

-- 3.2 Sucursales (norte y nororiente del Perú)
INSERT INTO dbo.sucursales (empresa_id, codigo, nombre, ciudad, departamento, es_sede_central) VALUES
(1, 'JAE', N'Agencia Central Jaén',   N'Jaén',         N'Cajamarca',  1),
(1, 'CIX', N'Agencia Chiclayo',       N'Chiclayo',     N'Lambayeque', 0),
(1, 'BGR', N'Agencia Bagua Grande',   N'Bagua Grande', N'Amazonas',   0),
(1, 'CHA', N'Agencia Chachapoyas',    N'Chachapoyas',  N'Amazonas',   0),
(1, 'MOY', N'Agencia Moyobamba',      N'Moyobamba',    N'San Martín', 0),
(1, 'TPP', N'Agencia Tarapoto',       N'Tarapoto',     N'San Martín', 0);

-- 3.3 Usuarios del sistema (IDs 5-8 conductores, 9-14 despachadores por sucursal)
INSERT INTO dbo.usuarios_sistema (sucursal_id, nombre_completo, nombre_usuario, correo, cargo) VALUES
(1, N'Luis Alberto Akil Carrasco',   'lakil',      'gerencia@akilflow.pe',       N'Gerente General'),
(1, N'Marco Antonio Delgado Vera',   'mdelgado',   'operaciones@akilflow.pe',    N'Jefe de Operaciones'),
(2, N'Carmen Rosa Paredes Inga',     'cparedes',   'contabilidad@akilflow.pe',   N'Contador'),
(1, N'Diego Fernando Ríos Salazar',  'drios',      'dba@akilflow.pe',            N'Administrador BD'),
(1, N'Carlos Huamán Tineo',          'chuaman',    'chuaman@akilflow.pe',        N'Conductor'),
(2, N'José Luis Vásquez Correa',     'jvasquez',   'jvasquez@akilflow.pe',       N'Conductor'),
(3, N'Wilmer Tapia Guevara',         'wtapia',     'wtapia@akilflow.pe',         N'Conductor'),
(5, N'Edwin Rojas Pizarro',          'erojas',     'erojas@akilflow.pe',         N'Conductor'),
(1, N'Ana Lucía Torres Medina',      'atorres',    'jaen@akilflow.pe',           N'Despachador'),
(2, N'Pedro Pablo Quispe Llontop',   'pquispe',    'chiclayo@akilflow.pe',       N'Despachador'),
(3, N'Rosa Elvira Chávez Montenegro','rchavez',    'baguagrande@akilflow.pe',    N'Despachador'),
(4, N'Juan Carlos Mendoza Culqui',   'jmendoza',   'chachapoyas@akilflow.pe',    N'Despachador'),
(5, N'Lucía Fernández Del Águila',   'lfernandez', 'moyobamba@akilflow.pe',      N'Despachador'),
(6, N'Kevin Saavedra Panduro',       'ksaavedra',  'tarapoto@akilflow.pe',       N'Despachador');

-- 3.4 Rutas (distancias aproximadas por carretera)
INSERT INTO dbo.rutas (codigo_ruta, sucursal_origen_id, sucursal_destino_id, distancia_km, horas_estimadas, tarifa_kg) VALUES
('JAE-CIX', 1, 2, 290.0,  6.0, 0.55),
('CIX-JAE', 2, 1, 290.0,  6.0, 0.55),
('JAE-BGR', 1, 3,  75.0,  1.5, 0.30),
('BGR-JAE', 3, 1,  75.0,  1.5, 0.30),
('BGR-CHA', 3, 4, 110.0,  2.5, 0.40),
('JAE-CHA', 1, 4, 185.0,  4.0, 0.50),
('BGR-MOY', 3, 5, 230.0,  5.0, 0.60),
('MOY-TPP', 5, 6, 110.0,  2.0, 0.35),
('CIX-TPP', 2, 6, 680.0, 14.0, 1.10),
('TPP-CIX', 6, 2, 680.0, 14.0, 1.10);

-- 3.5 Vehículos
INSERT INTO dbo.vehiculos (empresa_id, placa, marca, modelo, anio_fabricacion, capacidad_carga_kg, estado) VALUES
(1, 'T3A-845', N'Volvo',           N'FH 460',         2021, 10000, 'en_viaje'),
(1, 'T4B-127', N'Scania',          N'R450',           2020,  9000, 'en_viaje'),
(1, 'M1C-302', N'Mercedes-Benz',   N'Actros 2645',    2022, 10000, 'disponible'),
(1, 'T5D-560', N'Hino',            N'500 GH',         2019,  6000, 'disponible'),
(1, 'B7E-918', N'Isuzu',           N'FVR 34',         2018,  5000, 'disponible'),
(1, 'T2F-441', N'Volkswagen',      N'Constellation',  2023,  8000, 'disponible'),
(1, 'C9G-073', N'Foton',           N'Auman TX',       2021,  7000, 'disponible'),
(1, 'T6H-226', N'JAC',             N'N-Series 120',   2017,  3500, 'mantenimiento');

-- 3.6 Viajes: 1 salida diaria rotando rutas, vehículos y conductores
;WITH n AS (
    SELECT TOP (697) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) - 1 AS i
    FROM sys.all_objects a CROSS JOIN sys.all_objects b
), base AS (
    SELECT n.i,
           r.ruta_id, r.horas_estimadas, r.distancia_km,
           DATEADD(HOUR, 5 + (n.i % 3) * 6,
                   CAST(DATEADD(DAY, n.i, CAST('2025-01-01' AS DATE)) AS DATETIME2(0))) AS fs
    FROM n
    JOIN dbo.rutas r ON r.ruta_id = 1 + (n.i % 10)
)
INSERT INTO dbo.viajes (codigo_viaje, ruta_id, vehiculo_id, conductor_id,
                        fecha_salida, fecha_llegada, costo_estimado, estado)
SELECT CONCAT('VJ-', CONVERT(CHAR(8), b.fs, 112), '-', RIGHT('000' + CAST(b.i AS VARCHAR(4)), 4)),
       b.ruta_id,
       1 + (b.i % 7),                     -- vehículos 1-7 (el 8 está en mantenimiento)
       5 + (b.i % 4),                     -- conductores (usuarios 5-8)
       b.fs,
       CASE WHEN e.estado = 'completado'
            THEN DATEADD(MINUTE, CAST(b.horas_estimadas * 60 AS INT), b.fs) END,
       ROUND(b.distancia_km * (1.15 + (b.i % 5) * 0.05) + 25, 2),   -- combustible + peajes + viáticos (S/ por km)
       e.estado
FROM base b
CROSS APPLY (SELECT CASE WHEN b.i % 23 = 7          THEN 'cancelado'
                         WHEN b.fs < '2026-11-24'   THEN 'completado'
                         WHEN b.fs < '2026-11-26'   THEN 'en_curso'
                         ELSE 'programado' END AS estado) e;

-- 3.7 Encomiendas: entre 5 y 15 por viaje según temporada
;WITH k AS (
    SELECT TOP (16) ROW_NUMBER() OVER (ORDER BY (SELECT NULL)) AS k FROM sys.all_objects
), nombres AS (
    SELECT * FROM (VALUES (0,N'Juan'),(1,N'María'),(2,N'Rosa'),(3,N'José'),(4,N'Luis'),(5,N'Carmen'),
        (6,N'Pedro'),(7,N'Ana'),(8,N'Jorge'),(9,N'Elena'),(10,N'Miguel'),(11,N'Lucía'),(12,N'César'),
        (13,N'Gladys'),(14,N'Víctor'),(15,N'Flor'),(16,N'Raúl'),(17,N'Norma'),(18,N'Segundo'),(19,N'Delia')) t(id, nombre)
), apellidos AS (
    SELECT * FROM (VALUES (0,N'Pérez'),(1,N'Quispe'),(2,N'Huamán'),(3,N'Vásquez'),(4,N'Díaz'),(5,N'Rojas'),
        (6,N'Chávez'),(7,N'Torres'),(8,N'Guevara'),(9,N'Tapia'),(10,N'Fernández'),(11,N'Sánchez'),(12,N'Cruz'),
        (13,N'Montenegro'),(14,N'Llontop'),(15,N'Culqui'),(16,N'Saavedra'),(17,N'Mego'),(18,N'Bustamante'),(19,N'Carrasco')) t(id, apellido)
), empresas_cli AS (
    SELECT * FROM (VALUES (0,N'Cooperativa Agraria La Prosperidad'),(1,N'Comercial Norte E.I.R.L.'),
        (2,N'Ferretería El Constructor S.A.C.'),(3,N'Distribuidora Amazónica S.R.L.'),
        (4,N'Botica Santa Rosa S.A.C.'),(5,N'Cafés Especiales del Marañón S.A.C.')) t(id, razon)
), productos AS (
    SELECT * FROM (VALUES (0,N'Sacos de café pergamino',120.0),(1,N'Cajas de repuestos mecánicos',35.0),
        (2,N'Sobre de documentos',0.5),(3,N'Electrodomésticos',45.0),(4,N'Cajas de cacao en grano',90.0),
        (5,N'Medicamentos en caja térmica',8.0),(6,N'Fardos de ropa',25.0),(7,N'Abarrotes surtidos',60.0),
        (8,N'Materiales de ferretería',80.0),(9,N'Equipos de cómputo',15.0),(10,N'Plantones de café',150.0),
        (11,N'Paquete pequeño',3.0)) t(id, descripcion, peso_base)
), v AS (
    SELECT vi.viaje_id, vi.fecha_salida, vi.estado, r.sucursal_origen_id, r.tarifa_kg,
           5 + (vi.viaje_id * 3) % 7
             + CASE WHEN MONTH(vi.fecha_salida) IN (5,6,7,8) THEN 3      -- campaña del café
                    WHEN MONTH(vi.fecha_salida) = 12          THEN 4      -- campaña navideña
                    ELSE 0 END
             + CASE WHEN YEAR(vi.fecha_salida) = 2026 THEN 1 ELSE 0 END AS cantidad
    FROM dbo.viajes vi
    JOIN dbo.rutas r ON r.ruta_id = vi.ruta_id
    WHERE vi.estado <> 'cancelado'
)
INSERT INTO dbo.encomiendas (codigo_rastreo, viaje_id, usuario_registro_id, remitente, documento_remitente,
                             destinatario, telefono_destinatario, descripcion, peso_kg, precio_envio,
                             fecha_registro, estado)
SELECT CONCAT('AK', CONVERT(CHAR(8), v.fecha_salida, 112), RIGHT('0000' + CAST(v.viaje_id AS VARCHAR(5)), 4),
              RIGHT('0' + CAST(k.k AS VARCHAR(2)), 2)),
       v.viaje_id,
       8 + v.sucursal_origen_id,                                         -- despachador de la agencia origen
       CASE WHEN (v.viaje_id + k.k) % 4 = 0 THEN ec.razon
            ELSE CONCAT(nm.nombre, N' ', a1.apellido, N' ', a2.apellido) END,
       CASE WHEN (v.viaje_id + k.k) % 4 = 0
            THEN CONCAT('20', RIGHT('000000000' + CAST(480000000 + ec.id * 1371 AS VARCHAR(9)), 9))
            ELSE RIGHT('00000000' + CAST(40000000 + (CAST(v.viaje_id AS BIGINT) * 7919 + k.k * 104729) % 39999999 AS VARCHAR(8)), 8) END,
       CONCAT(nm2.nombre, N' ', a2.apellido, N' ', a1.apellido),
       CONCAT('9', RIGHT('00000000' + CAST((CAST(v.viaje_id AS BIGINT) * 15485863 + k.k * 2750159) % 99999999 AS VARCHAR(8)), 8)),
       p.descripcion,
       CAST(ROUND(p.peso_base * (1 + ((v.viaje_id * 31 + k.k * 17) % 50) / 50.0), 2) AS DECIMAL(10,2)),
       CAST(CASE WHEN p.peso_base < 1 THEN 10.00
                 ELSE ROUND(5 + p.peso_base * (1 + ((v.viaje_id * 31 + k.k * 17) % 50) / 50.0) * v.tarifa_kg, 2)
            END AS DECIMAL(10,2)),
       DATEADD(HOUR, -(2 + (k.k % 20)), v.fecha_salida),
       CASE v.estado WHEN 'completado' THEN CASE WHEN (v.viaje_id * k.k) % 97 = 0 THEN 'devuelta' ELSE 'entregada' END
                     WHEN 'en_curso'   THEN 'en_transito'
                     ELSE 'recibida' END
FROM v
JOIN k              ON k.k <= v.cantidad
JOIN productos p    ON p.id  = (v.viaje_id + k.k * 5) % 12
JOIN nombres nm     ON nm.id = (v.viaje_id * 3 + k.k) % 20
JOIN nombres nm2    ON nm2.id = (v.viaje_id + k.k * 7) % 20
JOIN apellidos a1   ON a1.id = (v.viaje_id + k.k * 11) % 20
JOIN apellidos a2   ON a2.id = (v.viaje_id * 13 + k.k) % 20
JOIN empresas_cli ec ON ec.id = (v.viaje_id + k.k) % 6;

-- 3.8 Encomiendas recién recibidas en agencia, aún sin viaje asignado
INSERT INTO dbo.encomiendas (codigo_rastreo, viaje_id, usuario_registro_id, remitente, documento_remitente,
                             destinatario, telefono_destinatario, descripcion, peso_kg, precio_envio,
                             fecha_registro, estado) VALUES
('AK20261125PEND01', NULL,  9, N'Rosa Morales Díaz',        '41235678', N'Comercial Chiclayo S.A.C.', '987654321', N'Bulto de café pergamino', 80.00, 49.00, '2026-11-25 08:15', 'recibida'),
('AK20261125PEND02', NULL, 10, N'Juan Pérez Llontop',       '16784523', N'Distribuidora Norte',       '976543210', N'Caja de repuestos',       45.50, 30.03, '2026-11-25 09:40', 'recibida'),
('AK20261125PEND03', NULL, 11, N'Agroexportadora Jaén SAC', '20487654321', N'Pedro Quispe Huamán',    '965432109', N'Sobre de documentos',      0.50, 10.00, '2026-11-25 10:05', 'recibida'),
('AK20261125PEND04', NULL, 13, N'Elena Saavedra Mego',      '45671238', N'Botica Santa Rosa S.A.C.',  '954321098', N'Medicamentos en caja térmica', 9.20, 8.22, '2026-11-25 11:30', 'recibida');
GO

DECLARE @msg NVARCHAR(200) = CONCAT(N'FASE 3 OK: ',
    (SELECT COUNT(*) FROM dbo.viajes), N' viajes y ',
    (SELECT COUNT(*) FROM dbo.encomiendas), N' encomiendas cargadas.');
PRINT @msg;
GO

/* =============================================================================
   FASE 4. DEMO DEL PLAN DE EJECUCIÓN - ANTES DEL ÍNDICE
   -----------------------------------------------------------------------------
   En SSMS: activar "Incluir plan de ejecución real" (Ctrl + M) y ejecutar
   SOLO este bloque. Revisar la pestaña "Mensajes" (lecturas lógicas).
   Consulta de negocio: "¿Qué encomiendas siguen EN TRÁNSITO desde el
   23/11/2026?" (pantalla de seguimiento del despachador).
   RESULTADO ESPERADO: Clustered Index Scan sobre PK_encomiendas
   (lee TODA la tabla aunque devuelve pocas filas).
   ============================================================================= */
SET STATISTICS IO ON;
SET STATISTICS TIME ON;
GO
PRINT N'--- [ANTES] Sin índice de soporte -> Clustered Index Scan ---';
SELECT codigo_rastreo, fecha_registro, peso_kg, precio_envio, estado
FROM dbo.encomiendas
WHERE estado = 'en_transito'
  AND fecha_registro >= '2026-11-23';
GO

/* =============================================================================
   FASE 5. ESTRATEGIA DE INDEXACIÓN
   -----------------------------------------------------------------------------
   ÍNDICES CLÚSTER (ya creados por las PRIMARY KEY CLUSTERED):
     Cada tabla está físicamente ordenada por su PK INT IDENTITY: clave
     estrecha (4 bytes), única, estática y creciente -> inserciones al final
     de la página, sin page splits y punteros pequeños para los no clúster.
   ÍNDICES NO CLÚSTER (creados aquí):
     Paso intermedio: IX sin INCLUDE -> muestra Index Seek + Key Lookup.
   ============================================================================= */
PRINT N'--- [PASO INTERMEDIO] Índice simple (estado, fecha_registro) -> Index Seek + Key Lookup ---';
CREATE NONCLUSTERED INDEX IX_encomiendas_estado_fecha
    ON dbo.encomiendas (estado, fecha_registro);
GO
SELECT codigo_rastreo, fecha_registro, peso_kg, precio_envio, estado
FROM dbo.encomiendas
WHERE estado = 'en_transito'
  AND fecha_registro >= '2026-11-23';
GO

/* Índice definitivo: COVERING INDEX. Las columnas del SELECT viajan en el
   nivel hoja (INCLUDE) y desaparece el Key Lookup. Se recrea con DROP_EXISTING
   para no dejar un índice duplicado. */
CREATE NONCLUSTERED INDEX IX_encomiendas_estado_fecha
    ON dbo.encomiendas (estado, fecha_registro)
    INCLUDE (codigo_rastreo, peso_kg, precio_envio)
    WITH (DROP_EXISTING = ON);
GO

-- Índice sobre la FK viaje_id (JOIN viajes-encomiendas del ETL y de reportes)
CREATE NONCLUSTERED INDEX IX_encomiendas_viaje
    ON dbo.encomiendas (viaje_id)
    INCLUDE (peso_kg, precio_envio, estado);
GO

-- Índice FILTRADO: solo encomiendas pendientes (pocas filas, muy consultadas)
CREATE NONCLUSTERED INDEX IX_encomiendas_pendientes
    ON dbo.encomiendas (usuario_registro_id, fecha_registro)
    INCLUDE (codigo_rastreo, viaje_id)
    WHERE estado = 'recibida';
GO

-- Índice por rango de fechas de viajes (reportes mensuales y extracción ETL)
CREATE NONCLUSTERED INDEX IX_viajes_fecha_salida
    ON dbo.viajes (fecha_salida)
    INCLUDE (ruta_id, vehiculo_id, costo_estimado, estado);
GO

-- Índice compuesto para la agenda de cada vehículo (evita doble asignación)
CREATE NONCLUSTERED INDEX IX_viajes_vehiculo_fecha
    ON dbo.viajes (vehiculo_id, fecha_salida)
    INCLUDE (estado);
GO

-- Índice sobre la FK ruta_id
CREATE NONCLUSTERED INDEX IX_viajes_ruta
    ON dbo.viajes (ruta_id);
GO

PRINT N'FASE 5 OK: índices no clúster creados.';
GO

/* =============================================================================
   FASE 6. DEMO DEL PLAN DE EJECUCIÓN - DESPUÉS (COVERING INDEX)
   RESULTADO ESPERADO: Index Seek (NonClustered) sobre IX_encomiendas_estado_fecha,
   SIN Key Lookup, con una fracción de las lecturas lógicas del Scan inicial.
   ============================================================================= */
PRINT N'--- [DESPUÉS] Covering index -> Index Seek (sin Key Lookup) ---';
SELECT codigo_rastreo, fecha_registro, peso_kg, precio_envio, estado
FROM dbo.encomiendas
WHERE estado = 'en_transito'
  AND fecha_registro >= '2026-11-23';
GO

-- Consulta extra: el índice filtrado resuelve la bandeja de pendientes por agencia
SELECT codigo_rastreo, fecha_registro
FROM dbo.encomiendas
WHERE estado = 'recibida' AND usuario_registro_id = 9;
GO
SET STATISTICS IO OFF;
SET STATISTICS TIME OFF;
GO

/* =============================================================================
   FASE 7. VERIFICACIÓN DEL MODELO Y DE LOS ÍNDICES
   ============================================================================= */
-- 7.1 Inventario de índices (clúster vs no clúster, filtrados, columnas incluidas)
SELECT t.name                          AS tabla,
       i.name                          AS indice,
       i.type_desc                     AS tipo,
       i.is_primary_key                AS es_pk,
       i.is_unique                     AS es_unico,
       i.has_filter                    AS filtrado,
       STUFF((SELECT ', ' + c.name + CASE WHEN ic.is_included_column = 1 THEN ' (INCLUDE)' ELSE '' END
              FROM sys.index_columns ic
              JOIN sys.columns c ON c.object_id = ic.object_id AND c.column_id = ic.column_id
              WHERE ic.object_id = i.object_id AND ic.index_id = i.index_id
              ORDER BY ic.is_included_column, ic.key_ordinal
              FOR XML PATH('')), 1, 2, '') AS columnas
FROM sys.indexes i
JOIN sys.tables  t ON t.object_id = i.object_id
WHERE i.type > 0
ORDER BY t.name, i.type, i.name;

-- 7.2 Conteo de filas por tabla
SELECT t.name AS tabla, SUM(p.rows) AS filas
FROM sys.tables t
JOIN sys.partitions p ON p.object_id = t.object_id AND p.index_id IN (0,1)
GROUP BY t.name
ORDER BY t.name;

-- 7.3 Prueba de integridad: el CHECK rechaza un peso negativo (error 547 controlado)
BEGIN TRY
    INSERT INTO dbo.encomiendas (codigo_rastreo, usuario_registro_id, remitente, documento_remitente,
                                 destinatario, telefono_destinatario, descripcion, peso_kg, precio_envio)
    VALUES ('AK-ERROR-TEST', 9, N'Prueba', '12345678', N'Prueba', '900000000', N'Prueba CHECK', -5, 10);
END TRY
BEGIN CATCH
    PRINT CONCAT(N'CHECK OK -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
END CATCH;
GO

PRINT N'=== SCRIPT 01 FINALIZADO: AkilFlowOperaciones lista (OLTP + índices). ===';
GO
