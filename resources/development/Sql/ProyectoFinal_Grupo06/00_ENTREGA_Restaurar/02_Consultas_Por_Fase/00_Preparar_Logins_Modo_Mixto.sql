/* =============================================================================
   PASO PREVIO · DEJAR LISTOS LOS LOGINS PARA INGRESAR COMO CADA ROL
   Ejecutar UNA VEZ después de 00_Restaurar_Proyecto.sql, conectado como
   administrador (autenticación de Windows / sysadmin): abrir y F5.

   Qué hace:
     1. Activa el modo de autenticación MIXTO (SQL Server y Windows) si hace falta.
     2. Crea los 5 logins si faltan, los habilita, los desbloquea y restablece
        su contraseña (por si se escribió mal varias veces y quedaron bloqueados).
     3. Pone como base predeterminada la que usa cada rol.
     4. Enlaza cada usuario de base con su login (sin usuarios huérfanos).
     5. Amplía la auditoría para registrar intentos denegados en TODAS las tablas.
     6. Muestra una tabla de verificación: todo debe decir OK.

   SI EL PASO 1 CAMBIA EL MODO, HAY QUE REINICIAR EL SERVICIO UNA VEZ:
     SSMS > Explorador de objetos > clic derecho en el servidor > Reiniciar
     (o Administrador de configuración de SQL Server > SQL Server (MSSQLSERVER) > Reiniciar)

   CREDENCIALES PARA INGRESAR (Autenticación de SQL Server):
     login_operador     Akil#Operador2026     base AkilFlowOperaciones
     login_supervisor   Akil#Supervisor2026   base AkilFlowOperaciones
     login_auditor      Akil#Auditor2026      base AkilFlowOperaciones
     login_contador     Akil#Contador2026     base AkilFlowOperaciones
     login_analista_bi  Akil#AnalistaBI2026   base dwh_AkilFlow
   En la ventana de conexión de SSMS 20/21 marque "Certificado de servidor de
   confianza" (Trust server certificate) o ponga Cifrado = Opcional.
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO

/* ---------------------------------------------------------------------------
   1. MODO DE AUTENTICACIÓN MIXTO
   --------------------------------------------------------------------------- */
IF CAST(SERVERPROPERTY('IsIntegratedSecurityOnly') AS INT) = 1
BEGIN
    IF EXISTS (SELECT 1 FROM sys.dm_os_host_info WHERE host_platform = N'Windows')
    BEGIN
        EXEC master.dbo.xp_instance_regwrite
             N'HKEY_LOCAL_MACHINE', N'Software\Microsoft\MSSQLServer\MSSQLServer',
             N'LoginMode', REG_DWORD, 2;
        PRINT N'*** Modo MIXTO activado. REINICIE EL SERVICIO de SQL Server para que tenga efecto. ***';
        PRINT N'    SSMS > clic derecho en el servidor > Reiniciar. Luego ya puede ingresar con los logins.';
    END
    ELSE
        PRINT N'La instancia no es Windows: active el modo mixto desde su configuración.';
END
ELSE
    PRINT N'1 OK: la instancia ya está en modo MIXTO (SQL Server y Windows).';
GO

/* ---------------------------------------------------------------------------
   2 y 3. LOGINS: crear si faltan, habilitar, desbloquear, contraseña y base
   --------------------------------------------------------------------------- */
DECLARE @logins TABLE (login SYSNAME, pwd NVARCHAR(128), sid VARBINARY(85), base SYSNAME);
INSERT INTO @logins VALUES
 (N'login_operador',    N'Akil#Operador2026',   0xA152CA08318D744289C8C8A8DED9E548, N'AkilFlowOperaciones'),
 (N'login_supervisor',  N'Akil#Supervisor2026', 0x76B8A285BA6E8D4989C41C86F821B286, N'AkilFlowOperaciones'),
 (N'login_auditor',     N'Akil#Auditor2026',    0x0C7DB05EAF684840AA45F60B17B02B69, N'AkilFlowOperaciones'),
 (N'login_contador',    N'Akil#Contador2026',   0x4E5B1DA7C4154446B5911694E336724C, N'AkilFlowOperaciones'),
 (N'login_analista_bi', N'Akil#AnalistaBI2026', 0x1D87A11C44BB334D8F1E7EE4726495B7, N'dwh_AkilFlow');

DECLARE @login SYSNAME, @pwd NVARCHAR(128), @sid VARBINARY(85), @base SYSNAME, @sql NVARCHAR(MAX);
DECLARE c CURSOR LOCAL FAST_FORWARD FOR SELECT login, pwd, sid, base FROM @logins;
OPEN c;
FETCH NEXT FROM c INTO @login, @pwd, @sid, @base;
WHILE @@FETCH_STATUS = 0
BEGIN
    IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = @login)
    BEGIN
        SET @sql = N'CREATE LOGIN ' + QUOTENAME(@login) + N' WITH PASSWORD = N' + QUOTENAME(@pwd, '''')
                 + N', SID = ' + CONVERT(NVARCHAR(100), @sid, 1) + N', CHECK_POLICY = ON, CHECK_EXPIRATION = OFF;';
        EXEC (@sql);
        PRINT CONCAT(N'Login creado: ', @login);
    END;
    -- contraseña conocida + desbloqueo (UNLOCK exige volver a poner la contraseña)
    SET @sql = N'ALTER LOGIN ' + QUOTENAME(@login) + N' WITH PASSWORD = N' + QUOTENAME(@pwd, '''') + N' UNLOCK;';
    EXEC (@sql);
    SET @sql = N'ALTER LOGIN ' + QUOTENAME(@login) + N' WITH CHECK_EXPIRATION = OFF, DEFAULT_DATABASE = ' + QUOTENAME(@base) + N';';
    EXEC (@sql);
    SET @sql = N'ALTER LOGIN ' + QUOTENAME(@login) + N' ENABLE;';
    EXEC (@sql);
    FETCH NEXT FROM c INTO @login, @pwd, @sid, @base;
END;
CLOSE c;
DEALLOCATE c;
PRINT N'2 OK: 5 logins habilitados, desbloqueados y con su contraseña y base predeterminada.';
GO

/* ---------------------------------------------------------------------------
   4. USUARIOS DE BASE ENLAZADOS A SU LOGIN
   --------------------------------------------------------------------------- */
USE AkilFlowOperaciones;
GO
ALTER USER usr_operador   WITH LOGIN = login_operador;
ALTER USER usr_supervisor WITH LOGIN = login_supervisor;
ALTER USER usr_auditor    WITH LOGIN = login_auditor;
ALTER USER usr_contador   WITH LOGIN = login_contador;
GRANT CONNECT TO usr_operador, usr_supervisor, usr_auditor, usr_contador;
GO
USE dwh_AkilFlow;
GO
ALTER USER usr_analista_bi WITH LOGIN = login_analista_bi;
GRANT CONNECT TO usr_analista_bi;
GO
PRINT N'4 OK: usuarios enlazados a sus logins.';
GO

/* ---------------------------------------------------------------------------
   5. AUDITORÍA DE INTENTOS DENEGADOS EN TODAS LAS TABLAS
   La especificación restaurada solo vigila encomiendas, viajes y un SP. Se
   amplía para registrar cualquier intento (permitido o denegado) sobre el
   personal, la vista financiera, sucursales, rutas, vehículos y el DWH.
   Los intentos denegados se consultan con 16_Intentos_Denegados.sql.
   --------------------------------------------------------------------------- */
USE AkilFlowOperaciones;
GO
IF NOT EXISTS (SELECT 1
               FROM sys.database_audit_specification_details d
               JOIN sys.database_audit_specifications s ON s.database_specification_id = d.database_specification_id
               WHERE s.name = N'DB_Audit_AkilFlow' AND d.major_id = OBJECT_ID(N'dbo.usuarios_sistema'))
BEGIN
    ALTER DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow WITH (STATE = OFF);
    ALTER DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow
        ADD (SELECT, INSERT, UPDATE, DELETE ON dbo.usuarios_sistema BY public),
        ADD (SELECT ON dbo.vw_resumen_financiero_viajes BY public),
        ADD (INSERT, UPDATE, DELETE ON dbo.sucursales BY public),
        ADD (INSERT, UPDATE, DELETE ON dbo.rutas BY public),
        ADD (INSERT, UPDATE, DELETE ON dbo.vehiculos BY public),
        ADD (EXECUTE ON dbo.usp_registrar_encomienda BY public),
        ADD (SCHEMA_OBJECT_CHANGE_GROUP);
    PRINT N'5 OK: auditoría de AkilFlowOperaciones ampliada a todas las tablas sensibles.';
END
ELSE
    PRINT N'5 OK: la auditoría de AkilFlowOperaciones ya estaba ampliada.';
ALTER DATABASE AUDIT SPECIFICATION DB_Audit_AkilFlow WITH (STATE = ON);
GO
USE dwh_AkilFlow;
GO
IF NOT EXISTS (SELECT 1 FROM sys.database_audit_specifications WHERE name = N'DB_Audit_DWH_AkilFlow')
BEGIN
    CREATE DATABASE AUDIT SPECIFICATION DB_Audit_DWH_AkilFlow
    FOR SERVER AUDIT Audit_AkilFlow
        ADD (SELECT, INSERT, UPDATE, DELETE, EXECUTE ON SCHEMA::dbo BY public),
        ADD (SCHEMA_OBJECT_CHANGE_GROUP)
    WITH (STATE = ON);
    PRINT N'5 OK: auditoría creada en dwh_AkilFlow.';
END
ELSE
    ALTER DATABASE AUDIT SPECIFICATION DB_Audit_DWH_AkilFlow WITH (STATE = ON);
GO

/* ---------------------------------------------------------------------------
   6. VERIFICACIÓN: todo debe decir OK
   --------------------------------------------------------------------------- */
USE master;
GO
SELECT CASE CAST(SERVERPROPERTY('IsIntegratedSecurityOnly') AS INT)
            WHEN 0 THEN N'OK: modo MIXTO activo'
            ELSE N'PENDIENTE: reinicie el servicio de SQL Server' END AS modo_autenticacion,
       @@SERVERNAME AS nombre_servidor_para_conectarse;

SELECT sp.name AS login,
       CASE WHEN sp.is_disabled = 0 THEN N'OK' ELSE N'DESHABILITADO' END AS habilitado,
       CASE WHEN LOGINPROPERTY(sp.name, 'IsLocked') = 0 THEN N'OK' ELSE N'BLOQUEADO' END AS bloqueo,
       sp.default_database_name AS base_predeterminada,
       COALESCE(u1.name, u2.name, N'*** SIN USUARIO ***') AS usuario_bd,
       COALESCE(r1.name, r2.name) AS rol
FROM sys.server_principals sp
LEFT JOIN AkilFlowOperaciones.sys.database_principals u1 ON u1.sid = sp.sid
LEFT JOIN AkilFlowOperaciones.sys.database_role_members m1 ON m1.member_principal_id = u1.principal_id
LEFT JOIN AkilFlowOperaciones.sys.database_principals r1 ON r1.principal_id = m1.role_principal_id
LEFT JOIN dwh_AkilFlow.sys.database_principals u2 ON u2.sid = sp.sid
LEFT JOIN dwh_AkilFlow.sys.database_role_members m2 ON m2.member_principal_id = u2.principal_id
LEFT JOIN dwh_AkilFlow.sys.database_principals r2 ON r2.principal_id = m2.role_principal_id
WHERE sp.name IN (N'login_operador', N'login_supervisor', N'login_auditor', N'login_contador', N'login_analista_bi')
ORDER BY sp.name;

SELECT N'AkilFlowOperaciones' AS base, name AS especificacion_auditoria,
       CASE is_state_enabled WHEN 1 THEN N'OK: ACTIVA' ELSE N'INACTIVA' END AS estado
FROM AkilFlowOperaciones.sys.database_audit_specifications
UNION ALL
SELECT N'dwh_AkilFlow', name, CASE is_state_enabled WHEN 1 THEN N'OK: ACTIVA' ELSE N'INACTIVA' END
FROM dwh_AkilFlow.sys.database_audit_specifications;
GO
PRINT N'>>> LISTO. Ahora: Conectar > Autenticación de SQL Server > login y contraseña de la tabla del encabezado.';
GO
