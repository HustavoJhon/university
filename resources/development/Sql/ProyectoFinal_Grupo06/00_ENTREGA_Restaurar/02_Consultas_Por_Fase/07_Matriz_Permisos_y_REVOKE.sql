/* =============================================================================
   FASE 7 · MATRIZ DE PERMISOS DE TODOS LOS ROLES + REVOKE vs DENY
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5,
   o seleccionar un bloque y F5.
   Compara en una sola tabla qué puede hacer cada usuario (SÍ / no).
   RECOMENDADO en SSMS: Ctrl + T (Resultados en texto) para ver en orden los
   títulos, las tablas y los mensajes de error. Ctrl + D vuelve a cuadrícula.
   ============================================================================= */
USE AkilFlowOperaciones;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 7.1 Capa 1 (login de instancia) -> capa 2 (usuario de base) -> rol ===';
SELECT sp.name AS login_instancia, dp.name AS usuario_bd, r.name AS rol,
       CASE sp.is_disabled WHEN 0 THEN N'habilitado' ELSE N'deshabilitado' END AS estado_login
FROM sys.database_principals dp
JOIN sys.server_principals sp ON sp.sid = dp.sid
JOIN sys.database_role_members rm ON rm.member_principal_id = dp.principal_id
JOIN sys.database_principals r ON r.principal_id = rm.role_principal_id
WHERE r.name LIKE N'Rol[_]%'
ORDER BY r.name;
GO

PRINT N'=== 7.2 Matriz de permisos efectivos (cada usuario evaluado con EXECUTE AS) ===';
DECLARE @r TABLE (usuario SYSNAME, objeto NVARCHAR(100), permiso NVARCHAR(20), tiene INT);
DECLARE @objetos TABLE (objeto NVARCHAR(100));
INSERT @objetos VALUES (N'dbo.encomiendas'), (N'dbo.viajes'), (N'dbo.vehiculos'),
                       (N'dbo.usuarios_sistema'), (N'dbo.vw_resumen_financiero_viajes');
DECLARE @u SYSNAME;
DECLARE c CURSOR LOCAL FAST_FORWARD FOR
    SELECT v FROM (VALUES (N'usr_operador'), (N'usr_supervisor'), (N'usr_auditor'), (N'usr_contador')) x(v);
OPEN c; FETCH NEXT FROM c INTO @u;
WHILE @@FETCH_STATUS = 0
BEGIN
    EXECUTE AS USER = @u;
        INSERT @r
        SELECT @u, o.objeto, p.permiso, HAS_PERMS_BY_NAME(o.objeto, N'OBJECT', p.permiso)
        FROM @objetos o CROSS JOIN (VALUES (N'SELECT'), (N'INSERT'), (N'UPDATE'), (N'DELETE')) p(permiso);
        INSERT @r SELECT @u, N'dbo.encomiendas', N'SEL_PRECIO', HAS_PERMS_BY_NAME(N'dbo.encomiendas', N'OBJECT', N'SELECT', N'precio_envio', N'COLUMN');
        INSERT @r SELECT @u, N'dbo.encomiendas', N'SEL_PII', HAS_PERMS_BY_NAME(N'dbo.encomiendas', N'OBJECT', N'SELECT', N'remitente_cif', N'COLUMN');
        INSERT @r SELECT @u, N'dbo.encomiendas', N'UPD_PRECIO', HAS_PERMS_BY_NAME(N'dbo.encomiendas', N'OBJECT', N'UPDATE', N'precio_envio', N'COLUMN');
        INSERT @r SELECT @u, N'dbo.encomiendas', N'UPD_ESTADO', HAS_PERMS_BY_NAME(N'dbo.encomiendas', N'OBJECT', N'UPDATE', N'estado', N'COLUMN');
        INSERT @r SELECT @u, N'dbo.usp_consultar_encomienda', N'EXECUTE', HAS_PERMS_BY_NAME(N'dbo.usp_consultar_encomienda', N'OBJECT', N'EXECUTE');
        INSERT @r SELECT @u, N'dbo.usp_registrar_encomienda', N'EXECUTE', HAS_PERMS_BY_NAME(N'dbo.usp_registrar_encomienda', N'OBJECT', N'EXECUTE');
    REVERT;
    FETCH NEXT FROM c INTO @u;
END;
CLOSE c; DEALLOCATE c;

SELECT objeto, permiso,
       MAX(CASE WHEN usuario = N'usr_operador'   AND tiene = 1 THEN N'SÍ' WHEN usuario = N'usr_operador'   THEN N'no' END) AS operador,
       MAX(CASE WHEN usuario = N'usr_supervisor' AND tiene = 1 THEN N'SÍ' WHEN usuario = N'usr_supervisor' THEN N'no' END) AS supervisor,
       MAX(CASE WHEN usuario = N'usr_auditor'    AND tiene = 1 THEN N'SÍ' WHEN usuario = N'usr_auditor'    THEN N'no' END) AS auditor,
       MAX(CASE WHEN usuario = N'usr_contador'   AND tiene = 1 THEN N'SÍ' WHEN usuario = N'usr_contador'   THEN N'no' END) AS contador
FROM @r
GROUP BY objeto, permiso
ORDER BY objeto, CASE permiso WHEN N'SELECT' THEN 1 WHEN N'SEL_PRECIO' THEN 2 WHEN N'SEL_PII' THEN 3 WHEN N'INSERT' THEN 4
                              WHEN N'UPDATE' THEN 5 WHEN N'UPD_ESTADO' THEN 6 WHEN N'UPD_PRECIO' THEN 7
                              WHEN N'DELETE' THEN 8 ELSE 9 END;
GO
PRINT N'Leyenda: SELECT = tabla completa · SEL_PRECIO = solo la columna precio_envio ·';
PRINT N'         SEL_PII = columna cifrada remitente_cif (operador y auditor la leen, pero solo en binario) ·';
PRINT N'         UPD_ESTADO / UPD_PRECIO = UPDATE de esa columna.';
GO

PRINT N'=== 7.3 GRANT / DENY declarados por rol ===';
SELECT pr.name AS rol, pe.state_desc AS accion, pe.permission_name AS permiso,
       COALESCE(SCHEMA_NAME(o.schema_id) + N'.' + o.name, N'SCHEMA::' + SCHEMA_NAME(pe.major_id)) AS objeto,
       COL_NAME(pe.major_id, pe.minor_id) AS columna
FROM sys.database_permissions pe
JOIN sys.database_principals pr ON pr.principal_id = pe.grantee_principal_id
LEFT JOIN sys.objects o ON o.object_id = pe.major_id AND pe.class = 1
WHERE pr.name LIKE N'Rol[_]%'
ORDER BY pr.name, pe.state_desc DESC, objeto, permiso;
GO

PRINT N'';
PRINT N'=== 7.4 REVOKE vs DENY: el operador pierde y recupera UPDATE(estado) en viajes ===';
PRINT N'(a) Con GRANT -> PERMITIDO';
EXECUTE AS USER = N'usr_operador';
UPDATE dbo.viajes SET estado = estado WHERE viaje_id = 1;
PRINT N'    UPDATE viajes OK';
REVERT;
GO
REVOKE UPDATE (estado) ON dbo.viajes FROM Rol_Operador;
PRINT N'(b) Tras REVOKE (permiso retirado, estado neutro) -> ESPERADO: DENEGADO (Msg 229)';
GO
EXECUTE AS USER = N'usr_operador';
BEGIN TRY
    UPDATE dbo.viajes SET estado = estado WHERE viaje_id = 1;
    PRINT N'    UPDATE viajes PERMITIDO (no debería ocurrir)';
END TRY
BEGIN CATCH
    PRINT CONCAT(N'    UPDATE viajes DENEGADO como se esperaba -> Msg ', ERROR_NUMBER(), N': ', ERROR_MESSAGE());
END CATCH;
REVERT;
GO
GRANT UPDATE (estado) ON dbo.viajes TO Rol_Operador;
PRINT N'(c) GRANT restituido -> PERMITIDO de nuevo';
EXECUTE AS USER = N'usr_operador';
UPDATE dbo.viajes SET estado = estado WHERE viaje_id = 1;
PRINT N'    UPDATE viajes OK';
REVERT;
GO
PRINT N'>>> FASE 7 OK. REVOKE solo quita lo concedido; DENY prohíbe aunque otro rol lo conceda.';
GO
