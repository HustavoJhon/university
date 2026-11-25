/* =============================================================================
   FASE 10 · SQL SERVER AUDIT
   Cómo ejecutar en SSMS (conectado como sysadmin): abrir el archivo y F5,
   o seleccionar un bloque y F5.
   Tip: antes intente conectarse en SSMS (Archivo > Conectar > Autenticación de
   SQL Server) como login_operador con una contraseña INCORRECTA, para que
   aparezca un FAILED_LOGIN en la bitácora del servidor (10.6).
   Archivos de auditoría: carpeta C:\AkilFlow\Audit (extensión .sqlaudit)
   RECOMENDADO en SSMS: Ctrl + T (Resultados en texto) para ver en orden los
   títulos, las tablas y los mensajes de error. Ctrl + D vuelve a cuadrícula.
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 10.1 Auditoría de servidor: destino y estado ===';
SELECT a.name AS auditoria, a.audit_guid, f.log_file_path AS carpeta, f.max_file_size AS max_mb,
       CASE a.is_state_enabled WHEN 1 THEN N'ACTIVA' ELSE N'INACTIVA' END AS estado
FROM sys.server_audits a JOIN sys.server_file_audits f ON f.audit_id = a.audit_id;
PRINT N'=== 10.2 Qué se audita a nivel de servidor ===';
SELECT s.name AS especificacion, d.audit_action_name AS accion
FROM sys.server_audit_specifications s
JOIN sys.server_audit_specification_details d ON d.server_specification_id = s.server_specification_id;
GO
USE AkilFlowOperaciones;
GO
PRINT N'=== 10.3 Qué se audita en AkilFlowOperaciones ===';
SELECT d.audit_action_name AS accion, ISNULL(OBJECT_NAME(d.major_id), N'(base completa)') AS objeto,
       USER_NAME(d.audited_principal_id) AS a_quien
FROM sys.database_audit_specifications s
JOIN sys.database_audit_specification_details d ON d.database_specification_id = s.database_specification_id;
GO

PRINT N'=== 10.4 Generando eventos: un UPDATE permitido y un DELETE denegado ===';
DECLARE @id INT = (SELECT TOP (1) encomienda_id FROM dbo.encomiendas ORDER BY encomienda_id DESC);
SELECT encomienda_id, codigo_rastreo, estado AS estado_antes FROM dbo.encomiendas WHERE encomienda_id = @id;
UPDATE dbo.encomiendas SET estado = 'devuelta' WHERE encomienda_id = @id;
SELECT encomienda_id, codigo_rastreo, estado AS estado_despues FROM dbo.encomiendas WHERE encomienda_id = @id;
GO
EXECUTE AS USER = N'usr_operador';
BEGIN TRY
    DELETE FROM dbo.encomiendas WHERE encomienda_id = 1;
END TRY
BEGIN CATCH
    PRINT CONCAT(N'DELETE del operador bloqueado (Msg ', ERROR_NUMBER(), N') y registrado en la auditoría.');
END CATCH;
REVERT;
GO
WAITFOR DELAY '00:00:01.500';   -- QUEUE_DELAY = 1 s: esperar a que se escriba el archivo
GO
PRINT N'=== 10.5 Bitácora: cambios y permisos (UP=update, DL=delete, IN=insert, EX=execute, G=grant, R=revoke, D=deny; exito=0 -> DENEGADO) ===';
SELECT TOP (15)
       CAST(event_time AS DATETIME2(0)) AS hora_utc, action_id AS accion, succeeded AS exito,
       server_principal_name AS login, database_principal_name AS usuario_bd,
       object_name AS objeto, LEFT(REPLACE(REPLACE(statement, CHAR(13), ' '), CHAR(10), ' '), 90) AS sentencia
FROM sys.fn_get_audit_file(N'C:\AkilFlow\Audit\*.sqlaudit', DEFAULT, DEFAULT)
WHERE database_name = N'AkilFlowOperaciones' AND action_id <> 'SL'
ORDER BY event_time DESC;
GO
PRINT N'=== 10.6 Bitácora: inicios de sesión fallidos (LGIF) ===';
SELECT TOP (10) CAST(event_time AS DATETIME2(0)) AS hora_utc, server_principal_name AS login,
       client_ip, LEFT(additional_information, 120) AS detalle
FROM sys.fn_get_audit_file(N'C:\AkilFlow\Audit\*.sqlaudit', DEFAULT, DEFAULT)
WHERE action_id = 'LGIF'
ORDER BY event_time DESC;
GO
PRINT N'>>> FASE 10 OK: accesos, cambios y denegaciones quedan registrados con usuario, hora y sentencia.';
GO
