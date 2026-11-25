/* =============================================================================
   PROYECTO FINAL - BASE DE DATOS 2 (NRC 39572) - GRUPO 6
   Empresa : Transportes Akil S.A.C.
   Script  : 02_Seguridad_RBAC_Cifrado.sql
   Base    : master + AkilFlowOperaciones
   Criterio: 3 - Seguridad perimetral RBAC (2 capas) y cifrado AES_256
   -----------------------------------------------------------------------------
   Prerrequisito: haber ejecutado 01_OLTP_Estructura_Datos_Indices.sql
   NOTA WINDOWS: para que los LOGINS SQL puedan conectarse desde SSMS, la
   instancia debe estar en modo de autenticación MIXTA (SQL Server y Windows):
   SSMS > clic derecho en el servidor > Propiedades > Seguridad > "Modo de
   autenticación de SQL Server y Windows" > reiniciar el servicio.
   Las pruebas de este script usan EXECUTE AS USER, por lo que funcionan
   aunque la instancia esté solo en modo Windows.
   Contenido:
     FASE 1. Capa 1 - LOGINS de instancia (master)
     FASE 2. Capa 2 - USERS de base de datos
     FASE 3. Jerarquía de cifrado: DMK -> Certificado -> Symmetric Key AES_256
     FASE 4. Migración de datos sensibles a VARBINARY(256) y borrado del texto plano
     FASE 5. Procedimientos seguros (EXECUTE AS OWNER) y vista financiera
     FASE 6. Roles RBAC (4 roles) con GRANT / DENY granular
     FASE 7. Pruebas de seguridad (Msg 229 / Msg 230 / acceso a la llave)
     FASE 8. Matriz de permisos efectivos
   ============================================================================= */

/* =============================================================================
   FASE 1. CAPA 1 - AUTENTICACIÓN A NIVEL DE INSTANCIA (LOGINS EN master)
   SID fijo: el mismo login creado en otro servidor (p. ej. al restaurar el
   .bak en el aula) queda enlazado automáticamente con su USER (sin huérfanos).
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO

IF SERVERPROPERTY('IsIntegratedSecurityOnly') = 1
    PRINT N'AVISO: la instancia está en modo SOLO Windows. Los logins se crearán, pero para conectarse con ellos active el modo MIXTO.';
GO

IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_operador')
    CREATE LOGIN login_operador   WITH PASSWORD = N'Akil#Operador2026', SID = 0xA152CA08318D744289C8C8A8DED9E548, DEFAULT_DATABASE = AkilFlowOperaciones,
                                       CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_auditor')
    CREATE LOGIN login_auditor    WITH PASSWORD = N'Akil#Auditor2026', SID = 0x0C7DB05EAF684840AA45F60B17B02B69, DEFAULT_DATABASE = AkilFlowOperaciones,
                                       CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_supervisor')
    CREATE LOGIN login_supervisor WITH PASSWORD = N'Akil#Supervisor2026', SID = 0x76B8A285BA6E8D4989C41C86F821B286, DEFAULT_DATABASE = AkilFlowOperaciones,
                                       CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = N'login_contador')
    CREATE LOGIN login_contador   WITH PASSWORD = N'Akil#Contador2026', SID = 0x4E5B1DA7C4154446B5911694E336724C, DEFAULT_DATABASE = AkilFlowOperaciones,
                                       CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;
GO
PRINT N'FASE 1 OK: 4 logins de instancia disponibles.';
GO

/* =============================================================================
   FASE 2. CAPA 2 - AUTORIZACIÓN A NIVEL DE BASE DE DATOS (USERS)
   Cada USER se mapea a su LOGIN (SID). Sin USER, el login autenticado
   no puede entrar a AkilFlowOperaciones (defensa en profundidad).
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SET NOCOUNT ON;
SET QUOTED_IDENTIFIER ON;
GO

IF USER_ID(N'usr_operador')   IS NULL CREATE USER usr_operador   FOR LOGIN login_operador   WITH DEFAULT_SCHEMA = dbo;
IF USER_ID(N'usr_auditor')    IS NULL CREATE USER usr_auditor    FOR LOGIN login_auditor    WITH DEFAULT_SCHEMA = dbo;
IF USER_ID(N'usr_supervisor') IS NULL CREATE USER usr_supervisor FOR LOGIN login_supervisor WITH DEFAULT_SCHEMA = dbo;
IF USER_ID(N'usr_contador')   IS NULL CREATE USER usr_contador   FOR LOGIN login_contador   WITH DEFAULT_SCHEMA = dbo;
GO
PRINT N'FASE 2 OK: 4 users de base de datos mapeados a sus logins.';
GO

/* =============================================================================
   FASE 3. JERARQUÍA DE CIFRADO SIMÉTRICO AES_256
     Service Master Key (instancia, automática)
        -> Database Master Key (DMK)       protegida por contraseña + SMK
           -> Certificado Cert_AkilFlow_Operaciones (llave asimétrica)
              -> Symmetric Key SymKey_AkilFlow_Datos (AES_256) cifra las columnas
   ============================================================================= */
IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'##MS_DatabaseMasterKey##')
    CREATE MASTER KEY ENCRYPTION BY PASSWORD = N'Akil#DMK.Operaciones2026';
GO

IF NOT EXISTS (SELECT 1 FROM sys.certificates WHERE name = N'Cert_AkilFlow_Operaciones')
    CREATE CERTIFICATE Cert_AkilFlow_Operaciones
        WITH SUBJECT = N'Transportes Akil - Proteccion de datos personales de encomiendas',
             EXPIRY_DATE = '2035-12-31';
GO

IF NOT EXISTS (SELECT 1 FROM sys.symmetric_keys WHERE name = N'SymKey_AkilFlow_Datos')
    CREATE SYMMETRIC KEY SymKey_AkilFlow_Datos
        WITH ALGORITHM = AES_256
        ENCRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
GO

SELECT name, algorithm_desc, key_length, create_date
FROM sys.symmetric_keys;
SELECT name, subject, pvt_key_encryption_type_desc, expiry_date
FROM sys.certificates WHERE name = N'Cert_AkilFlow_Operaciones';
GO
PRINT N'FASE 3 OK: DMK + certificado + llave simétrica AES_256 creados.';
GO

/* =============================================================================
   FASE 4. MIGRACIÓN DE DATOS SENSIBLES A COLUMNAS CIFRADAS
   Regla de negocio (Ley N.° 29733 de Protección de Datos Personales):
   remitente, documento, destinatario y teléfono NUNCA deben quedar en
   texto plano. Se cifran, se valida el round-trip y se ELIMINAN las
   columnas originales + REBUILD para purgar los bytes residuales.
   ============================================================================= */

-- 4.1 ANTES: datos personales expuestos en texto plano
PRINT N'--- [ANTES] Datos sensibles en texto plano ---';
SELECT TOP (5) encomienda_id, codigo_rastreo, remitente, documento_remitente, destinatario, telefono_destinatario
FROM dbo.encomiendas ORDER BY encomienda_id;
GO

-- 4.2 Columnas binarias destino
IF COL_LENGTH(N'dbo.encomiendas', N'remitente_cif') IS NULL
    ALTER TABLE dbo.encomiendas ADD
        remitente_cif             VARBINARY(256) NULL,
        documento_remitente_cif   VARBINARY(256) NULL,
        destinatario_cif          VARBINARY(256) NULL,
        telefono_destinatario_cif VARBINARY(256) NULL;
GO

-- 4.3 Cifrado masivo (transaccional: todo o nada)
IF COL_LENGTH(N'dbo.encomiendas', N'remitente') IS NOT NULL
BEGIN
    BEGIN TRAN;
        OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;

        EXEC (N'UPDATE dbo.encomiendas
                SET remitente_cif             = EncryptByKey(Key_GUID(N''SymKey_AkilFlow_Datos''), remitente),
                    documento_remitente_cif   = EncryptByKey(Key_GUID(N''SymKey_AkilFlow_Datos''), documento_remitente),
                    destinatario_cif          = EncryptByKey(Key_GUID(N''SymKey_AkilFlow_Datos''), destinatario),
                    telefono_destinatario_cif = EncryptByKey(Key_GUID(N''SymKey_AkilFlow_Datos''), telefono_destinatario);');

        -- 4.4 Validación round-trip: descifrar y comparar con el original
        DECLARE @errores INT;
        EXEC sp_executesql N'
            SELECT @e = COUNT(*)
            FROM dbo.encomiendas
            WHERE remitente_cif IS NULL OR documento_remitente_cif IS NULL
               OR destinatario_cif IS NULL OR telefono_destinatario_cif IS NULL
               OR CAST(DecryptByKey(remitente_cif)             AS NVARCHAR(120)) <> remitente
               OR CAST(DecryptByKey(documento_remitente_cif)   AS VARCHAR(11))   <> documento_remitente
               OR CAST(DecryptByKey(destinatario_cif)          AS NVARCHAR(120)) <> destinatario
               OR CAST(DecryptByKey(telefono_destinatario_cif) AS VARCHAR(12))   <> telefono_destinatario;',
            N'@e INT OUTPUT', @e = @errores OUTPUT;

        CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;

    IF @errores = 0
    BEGIN
        COMMIT;
        PRINT N'Validación OK: 100% de filas cifradas y descifradas correctamente.';
    END
    ELSE
    BEGIN
        ROLLBACK;
        RAISERROR(N'Validación de cifrado fallida: %d filas inconsistentes. Se revierte.', 16, 1, @errores);
    END
END;
GO

-- 4.5 Eliminación del texto plano + columnas cifradas obligatorias
IF COL_LENGTH(N'dbo.encomiendas', N'remitente') IS NOT NULL
   AND NOT EXISTS (SELECT 1 FROM dbo.encomiendas WHERE remitente_cif IS NULL)
BEGIN
    ALTER TABLE dbo.encomiendas DROP COLUMN remitente, documento_remitente, destinatario, telefono_destinatario;
    ALTER TABLE dbo.encomiendas ALTER COLUMN remitente_cif             VARBINARY(256) NOT NULL;
    ALTER TABLE dbo.encomiendas ALTER COLUMN documento_remitente_cif   VARBINARY(256) NOT NULL;
    ALTER TABLE dbo.encomiendas ALTER COLUMN destinatario_cif          VARBINARY(256) NOT NULL;
    ALTER TABLE dbo.encomiendas ALTER COLUMN telefono_destinatario_cif VARBINARY(256) NOT NULL;
    -- DROP COLUMN solo marca la columna como eliminada en metadatos: los bytes
    -- siguen físicamente en las páginas. REBUILD reescribe las páginas y los purga.
    ALTER INDEX ALL ON dbo.encomiendas REBUILD;
    PRINT N'Columnas en texto plano eliminadas y tabla reconstruida (sin residuos).';
END;
GO

-- 4.6 Evidencia: ya no existe ninguna columna sensible en texto plano
SELECT c.name AS columna, t.name AS tipo, c.max_length
FROM sys.columns c
JOIN sys.types t ON t.user_type_id = c.user_type_id
WHERE c.object_id = OBJECT_ID(N'dbo.encomiendas')
ORDER BY c.column_id;
GO

-- 4.7 DESPUÉS: sin llave abierta solo se ve binario; con la llave, el texto
PRINT N'--- [DESPUÉS] Columnas cifradas (VARBINARY) ---';
SELECT TOP (5) encomienda_id, codigo_rastreo, remitente_cif, destinatario_cif
FROM dbo.encomiendas ORDER BY encomienda_id;

OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
SELECT TOP (5) encomienda_id, codigo_rastreo,
       CAST(DecryptByKey(remitente_cif)             AS NVARCHAR(120)) AS remitente,
       CAST(DecryptByKey(documento_remitente_cif)   AS VARCHAR(11))   AS documento,
       CAST(DecryptByKey(destinatario_cif)          AS NVARCHAR(120)) AS destinatario,
       CAST(DecryptByKey(telefono_destinatario_cif) AS VARCHAR(12))   AS telefono
FROM dbo.encomiendas ORDER BY encomienda_id;
CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
GO
PRINT N'FASE 4 OK: datos sensibles protegidos con AES_256 y sin texto plano.';
GO

/* =============================================================================
   FASE 5. PROCEDIMIENTOS SEGUROS Y VISTA FINANCIERA
   Los usuarios NO reciben permisos sobre el certificado ni la llave: solo
   EXECUTE sobre procedimientos firmados por el dueño (EXECUTE AS OWNER).
   Así el cifrado/descifrado ocurre dentro del servidor y de forma controlada.
   ============================================================================= */
CREATE OR ALTER PROCEDURE dbo.usp_registrar_encomienda
    @codigo_rastreo        VARCHAR(20),
    @viaje_id              INT = NULL,
    @usuario_registro_id   INT,
    @remitente             NVARCHAR(80),     -- 80 caracteres -> cifrado <= 256 bytes
    @documento_remitente   VARCHAR(11),
    @destinatario          NVARCHAR(80),
    @telefono_destinatario VARCHAR(12),
    @descripcion           NVARCHAR(200),
    @peso_kg               DECIMAL(10,2),
    @precio_envio          DECIMAL(10,2)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;

    INSERT INTO dbo.encomiendas (codigo_rastreo, viaje_id, usuario_registro_id, descripcion, peso_kg, precio_envio,
                                 estado, remitente_cif, documento_remitente_cif, destinatario_cif, telefono_destinatario_cif)
    VALUES (@codigo_rastreo, @viaje_id, @usuario_registro_id, @descripcion, @peso_kg, @precio_envio,
            CASE WHEN @viaje_id IS NULL THEN 'recibida' ELSE 'en_transito' END,
            EncryptByKey(Key_GUID(N'SymKey_AkilFlow_Datos'), @remitente),
            EncryptByKey(Key_GUID(N'SymKey_AkilFlow_Datos'), @documento_remitente),
            EncryptByKey(Key_GUID(N'SymKey_AkilFlow_Datos'), @destinatario),
            EncryptByKey(Key_GUID(N'SymKey_AkilFlow_Datos'), @telefono_destinatario));

    CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
    SELECT SCOPE_IDENTITY() AS encomienda_id_nueva;
END;
GO

CREATE OR ALTER PROCEDURE dbo.usp_consultar_encomienda
    @codigo_rastreo VARCHAR(20)
WITH EXECUTE AS OWNER
AS
BEGIN
    SET NOCOUNT ON;
    OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;

    SELECT e.codigo_rastreo, e.estado, e.descripcion, e.peso_kg, e.precio_envio, e.fecha_registro,
           CAST(DecryptByKey(e.remitente_cif)             AS NVARCHAR(120)) AS remitente,
           CAST(DecryptByKey(e.destinatario_cif)          AS NVARCHAR(120)) AS destinatario,
           CAST(DecryptByKey(e.telefono_destinatario_cif) AS VARCHAR(12))   AS telefono_destinatario,
           v.codigo_viaje, r.codigo_ruta
    FROM dbo.encomiendas e
    LEFT JOIN dbo.viajes v ON v.viaje_id = e.viaje_id
    LEFT JOIN dbo.rutas  r ON r.ruta_id  = v.ruta_id
    WHERE e.codigo_rastreo = @codigo_rastreo;

    CLOSE SYMMETRIC KEY SymKey_AkilFlow_Datos;
END;
GO

CREATE OR ALTER VIEW dbo.vw_resumen_financiero_viajes
AS
SELECT v.viaje_id, v.codigo_viaje, r.codigo_ruta, CAST(v.fecha_salida AS DATE) AS fecha,
       v.estado, v.costo_estimado,
       COUNT(e.encomienda_id)            AS cantidad_encomiendas,
       ISNULL(SUM(e.precio_envio), 0)    AS ingresos,
       ISNULL(SUM(e.precio_envio), 0) - v.costo_estimado AS margen_bruto
FROM dbo.viajes v
JOIN dbo.rutas r ON r.ruta_id = v.ruta_id
LEFT JOIN dbo.encomiendas e ON e.viaje_id = v.viaje_id
GROUP BY v.viaje_id, v.codigo_viaje, r.codigo_ruta, CAST(v.fecha_salida AS DATE), v.estado, v.costo_estimado;
GO
PRINT N'FASE 5 OK: procedimientos seguros y vista financiera creados.';
GO

/* =============================================================================
   FASE 6. MODELO RBAC - 4 ROLES CON MÍNIMO PRIVILEGIO
   ┌────────────────┬───────────────────────────────────────────────────────────┐
   │ Rol_Operador   │ Despachador de agencia: registra y actualiza estados.     │
   │ Rol_Supervisor │ Jefe de Operaciones: planifica viajes/flota, ve PII.      │
   │ Rol_Auditor    │ Control interno: lectura total, cero escritura, sin PII.  │
   │ Rol_Contador   │ Finanzas: solo montos y costos, nunca datos personales.   │
   └────────────────┴───────────────────────────────────────────────────────────┘
   DENY prevalece sobre cualquier GRANT heredado (incluso de otro rol).
   ============================================================================= */
IF DATABASE_PRINCIPAL_ID(N'Rol_Operador')   IS NULL CREATE ROLE Rol_Operador   AUTHORIZATION dbo;
IF DATABASE_PRINCIPAL_ID(N'Rol_Supervisor') IS NULL CREATE ROLE Rol_Supervisor AUTHORIZATION dbo;
IF DATABASE_PRINCIPAL_ID(N'Rol_Auditor')    IS NULL CREATE ROLE Rol_Auditor    AUTHORIZATION dbo;
IF DATABASE_PRINCIPAL_ID(N'Rol_Contador')   IS NULL CREATE ROLE Rol_Contador   AUTHORIZATION dbo;
GO

-- 6.1 Rol_Operador -------------------------------------------------------------
GRANT SELECT ON dbo.sucursales  TO Rol_Operador;
GRANT SELECT ON dbo.rutas       TO Rol_Operador;
GRANT SELECT ON dbo.vehiculos   TO Rol_Operador;
GRANT SELECT ON dbo.viajes      TO Rol_Operador;
GRANT SELECT ON dbo.encomiendas TO Rol_Operador;
GRANT UPDATE (estado, viaje_id) ON dbo.encomiendas TO Rol_Operador;   -- permiso a nivel de COLUMNA
GRANT UPDATE (estado)           ON dbo.viajes      TO Rol_Operador;
GRANT EXECUTE ON dbo.usp_registrar_encomienda TO Rol_Operador;          -- único camino para insertar
GRANT EXECUTE ON dbo.usp_consultar_encomienda TO Rol_Operador;
DENY  INSERT, DELETE ON dbo.encomiendas      TO Rol_Operador;          -- obliga a usar el SP (cifrado)
DENY  DELETE         ON dbo.viajes           TO Rol_Operador;
DENY  SELECT         ON dbo.usuarios_sistema TO Rol_Operador;          -- correos del personal
DENY  SELECT         ON dbo.vw_resumen_financiero_viajes TO Rol_Operador;
GO

-- 6.2 Rol_Supervisor -----------------------------------------------------------
GRANT SELECT ON SCHEMA::dbo TO Rol_Supervisor;
GRANT INSERT, UPDATE ON dbo.viajes    TO Rol_Supervisor;
GRANT INSERT, UPDATE ON dbo.vehiculos TO Rol_Supervisor;
GRANT INSERT, UPDATE ON dbo.rutas     TO Rol_Supervisor;
GRANT UPDATE (estado, viaje_id) ON dbo.encomiendas TO Rol_Supervisor;
GRANT EXECUTE ON dbo.usp_registrar_encomienda TO Rol_Supervisor;
GRANT EXECUTE ON dbo.usp_consultar_encomienda TO Rol_Supervisor;
DENY  DELETE ON SCHEMA::dbo TO Rol_Supervisor;                          -- borrado lógico por estado, nunca físico
DENY  ALTER  ON SCHEMA::dbo TO Rol_Supervisor;                          -- sin cambios de estructura (DDL)
GO

-- 6.3 Rol_Auditor --------------------------------------------------------------
GRANT SELECT ON SCHEMA::dbo TO Rol_Auditor;                             -- ve todo, pero PII solo en binario
DENY  INSERT, UPDATE, DELETE ON SCHEMA::dbo TO Rol_Auditor;
DENY  EXECUTE ON SCHEMA::dbo TO Rol_Auditor;                            -- no puede usar los SP de descifrado
GO

-- 6.4 Rol_Contador -------------------------------------------------------------
GRANT SELECT ON dbo.vw_resumen_financiero_viajes TO Rol_Contador;
GRANT SELECT ON dbo.viajes     TO Rol_Contador;
GRANT SELECT ON dbo.rutas      TO Rol_Contador;
GRANT SELECT ON dbo.vehiculos  TO Rol_Contador;
GRANT SELECT ON dbo.sucursales TO Rol_Contador;
GRANT SELECT ON dbo.encomiendas (encomienda_id, codigo_rastreo, viaje_id, descripcion,
                                 peso_kg, precio_envio, fecha_registro, estado) TO Rol_Contador;
DENY  SELECT ON dbo.encomiendas (remitente_cif, documento_remitente_cif,
                                 destinatario_cif, telefono_destinatario_cif) TO Rol_Contador;
DENY  SELECT ON dbo.usuarios_sistema TO Rol_Contador;
DENY  INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::dbo TO Rol_Contador;
GO

-- 6.5 Asignación de usuarios a roles
IF IS_ROLEMEMBER(N'Rol_Operador',   N'usr_operador')   = 0 ALTER ROLE Rol_Operador   ADD MEMBER usr_operador;
IF IS_ROLEMEMBER(N'Rol_Supervisor', N'usr_supervisor') = 0 ALTER ROLE Rol_Supervisor ADD MEMBER usr_supervisor;
IF IS_ROLEMEMBER(N'Rol_Auditor',    N'usr_auditor')    = 0 ALTER ROLE Rol_Auditor    ADD MEMBER usr_auditor;
IF IS_ROLEMEMBER(N'Rol_Contador',   N'usr_contador')   = 0 ALTER ROLE Rol_Contador   ADD MEMBER usr_contador;
GO
PRINT N'FASE 6 OK: 4 roles RBAC configurados con GRANT/DENY granular.';
GO

/* =============================================================================
   FASE 7. PRUEBAS DE SEGURIDAD (suplantación con EXECUTE AS USER)
   Se usan TRY/CATCH para que el script continúe y muestre el código de error.
   En la DEMO en vivo puede ejecutarse la sentencia "desnuda" para que SSMS
   muestre el mensaje rojo original: Msg 229, Level 14.
   ============================================================================= */

-- 7.1 OPERADOR: registra una encomienda por el SP (OK) y consulta descifrado (OK)
EXECUTE AS USER = N'usr_operador';
    PRINT CONCAT(N'Sesión actual: ', USER_NAME());
    EXEC dbo.usp_registrar_encomienda
         @codigo_rastreo = 'AK20261125DEMO01', @viaje_id = NULL, @usuario_registro_id = 9,
         @remitente = N'Cooperativa Agraria La Prosperidad', @documento_remitente = '20480001371',
         @destinatario = N'Marleny Guevara Tapia', @telefono_destinatario = '976112233',
         @descripcion = N'Sacos de café pergamino (demo RBAC)', @peso_kg = 180.00, @precio_envio = 104.00;
    EXEC dbo.usp_consultar_encomienda @codigo_rastreo = 'AK20261125DEMO01';
    UPDATE dbo.encomiendas SET estado = 'recibida' WHERE codigo_rastreo = 'AK20261125DEMO01';  -- UPDATE de columna permitida
    PRINT N'Operador: INSERT vía SP, consulta y UPDATE(estado) -> PERMITIDOS';
REVERT;
GO

-- 7.2 OPERADOR: intenta DELETE -> Msg 229 (DENY explícito)
EXECUTE AS USER = N'usr_operador';
BEGIN TRY
    DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK20261125DEMO01';
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Operador DELETE   -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
END CATCH;
-- 7.3 OPERADOR: intenta INSERT directo (saltándose el cifrado) -> Msg 229
BEGIN TRY
    INSERT INTO dbo.encomiendas (codigo_rastreo, usuario_registro_id, descripcion, peso_kg, precio_envio,
                                 remitente_cif, documento_remitente_cif, destinatario_cif, telefono_destinatario_cif)
    VALUES ('AK-HACK-01', 9, N'Intento sin cifrado', 1, 1, 0x00, 0x00, 0x00, 0x00);
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Operador INSERT   -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
END CATCH;
-- 7.4 OPERADOR: intenta modificar el precio (columna no autorizada) -> Msg 230
BEGIN TRY
    UPDATE dbo.encomiendas SET precio_envio = 0 WHERE codigo_rastreo = 'AK20261125DEMO01';
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Operador UPDATE precio -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
END CATCH;
REVERT;
GO

-- 7.5 AUDITOR: lee todo, pero los datos personales solo como binario
EXECUTE AS USER = N'usr_auditor';
    SELECT TOP (3) codigo_rastreo, estado, precio_envio, remitente_cif,
           CAST(DecryptByKey(remitente_cif) AS NVARCHAR(120)) AS intento_descifrar  -- NULL: no tiene la llave
    FROM dbo.encomiendas ORDER BY encomienda_id;
    BEGIN TRY
        UPDATE dbo.encomiendas SET estado = 'entregada' WHERE encomienda_id = 1;
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Auditor UPDATE    -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
    BEGIN TRY
        OPEN SYMMETRIC KEY SymKey_AkilFlow_Datos DECRYPTION BY CERTIFICATE Cert_AkilFlow_Operaciones;
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Auditor OPEN KEY  -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
    BEGIN TRY
        EXEC dbo.usp_consultar_encomienda @codigo_rastreo = 'AK20261125DEMO01';
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Auditor EXEC SP   -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
REVERT;
GO

-- 7.6 CONTADOR: ve la vista financiera, pero no las columnas cifradas
EXECUTE AS USER = N'usr_contador';
    SELECT TOP (5) codigo_viaje, codigo_ruta, fecha, cantidad_encomiendas, ingresos, costo_estimado, margen_bruto
    FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;
    BEGIN TRY
        SELECT TOP (1) codigo_rastreo, remitente_cif FROM dbo.encomiendas;
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Contador SELECT PII -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
    BEGIN TRY
        SELECT TOP (1) correo FROM dbo.usuarios_sistema;
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Contador SELECT usuarios -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
REVERT;
GO

-- 7.7 SUPERVISOR: puede planificar viajes pero nunca borrar ni alterar estructura
EXECUTE AS USER = N'usr_supervisor';
    UPDATE dbo.vehiculos SET estado = 'mantenimiento' WHERE placa = 'T6H-226';
    PRINT N'Supervisor UPDATE vehiculos -> PERMITIDO';
    BEGIN TRY
        DELETE FROM dbo.viajes WHERE estado = 'cancelado';
    END TRY
    BEGIN CATCH
        PRINT CONCAT(N'Supervisor DELETE -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
    END CATCH;
REVERT;
GO

-- 7.8 REVOKE vs DENY (Laboratorio 9): GRANT -> prueba OK -> REVOKE -> prueba falla -> GRANT de nuevo
--     REVOKE solo RETIRA un permiso concedido (vuelve al estado neutro);
--     DENY lo PROHÍBE aunque otro rol lo conceda.
PRINT N'--- REVOKE: Rol_Operador pierde temporalmente UPDATE(estado) sobre viajes ---';
REVOKE UPDATE (estado) ON dbo.viajes FROM Rol_Operador;
EXECUTE AS USER = N'usr_operador';
BEGIN TRY
    UPDATE dbo.viajes SET estado = estado WHERE viaje_id = 1;
    PRINT N'Operador UPDATE viajes -> PERMITIDO (no debería ocurrir)';
END TRY
BEGIN CATCH
    PRINT CONCAT(N'Operador UPDATE viajes tras REVOKE -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
END CATCH;
REVERT;
GRANT UPDATE (estado) ON dbo.viajes TO Rol_Operador;          -- se restituye el permiso original
EXECUTE AS USER = N'usr_operador';
    UPDATE dbo.viajes SET estado = estado WHERE viaje_id = 1;
    PRINT N'Operador UPDATE viajes tras nuevo GRANT -> PERMITIDO';
REVERT;
GO

/* --- Para la DEMO en vivo (resaltar y ejecutar; SSMS mostrará el error rojo) ---
EXECUTE AS USER = 'usr_operador';
DELETE FROM dbo.encomiendas WHERE codigo_rastreo = 'AK20261125DEMO01';
-- Msg 229, Level 14, State 5: The DELETE permission was denied on the object 'encomiendas'...
REVERT;
------------------------------------------------------------------------------- */

/* =============================================================================
   FASE 8. MATRIZ DE PERMISOS EFECTIVOS POR ROL
   ============================================================================= */
SELECT pr.name                                   AS rol,
       pe.state_desc                             AS accion,       -- GRANT / DENY
       pe.permission_name                        AS permiso,
       pe.class_desc                             AS ambito,
       COALESCE(SCHEMA_NAME(o.schema_id) + '.' + o.name,
                SCHEMA_NAME(pe.major_id))        AS objeto,
       COL_NAME(pe.major_id, pe.minor_id)        AS columna
FROM sys.database_permissions pe
JOIN sys.database_principals  pr ON pr.principal_id = pe.grantee_principal_id
LEFT JOIN sys.objects          o ON o.object_id = pe.major_id AND pe.class = 1
WHERE pr.name LIKE N'Rol[_]%'
ORDER BY pr.name, pe.state_desc DESC, objeto, permiso;

SELECT r.name AS rol, m.name AS usuario, sp.name AS login_instancia
FROM sys.database_role_members rm
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
JOIN sys.database_principals m ON m.principal_id = rm.member_principal_id
LEFT JOIN sys.server_principals sp ON sp.sid = m.sid
WHERE r.name LIKE N'Rol[_]%'
ORDER BY r.name;
GO

PRINT N'=== SCRIPT 02 FINALIZADO: RBAC (4 roles) + cifrado AES_256 operativos. ===';
GO
