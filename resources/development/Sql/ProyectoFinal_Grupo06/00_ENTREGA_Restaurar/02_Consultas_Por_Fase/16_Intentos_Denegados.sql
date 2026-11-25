/* =============================================================================
   FASE 16 · ¿QUIÉN INTENTÓ ENTRAR A DONDE NO TENÍA PERMISO?
   Lee la bitácora de SQL Server Audit (C:\AkilFlow\Audit) y muestra cada
   intento DENEGADO: qué login, a qué tabla/vista/SP, qué acción, cuándo y
   con qué sentencia. También los inicios de sesión fallidos.

   Cómo ejecutar en SSMS: conectado como administrador (sysadmin), abrir y F5.
   Requisitos: haber ejecutado 00_Preparar_Logins_Modo_Mixto.sql (amplía la
   auditoría a todas las tablas) y luego alguna prueba de rol (02 a 06) o
   haber ingresado con un login e intentado algo no permitido.

   TAMBIÉN SE PUEDE VER SIN CONSULTAS (interfaz gráfica de SSMS):
     Explorador de objetos > Seguridad > Auditorías > Audit_AkilFlow
     > clic derecho > "Ver registros de auditoría" (View Audit Logs).
     Filtrar por "Correcto" (Succeeded) = False para ver solo los denegados.
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO
-- Diferencia horaria para mostrar la hora local (la auditoría guarda la hora UTC)
IF OBJECT_ID(N'tempdb..#auditoria') IS NOT NULL DROP TABLE #auditoria;
SELECT DATEADD(MINUTE, DATEDIFF(MINUTE, SYSUTCDATETIME(), SYSDATETIME()), CAST(f.event_time AS DATETIME2(0))) AS hora_local,
       f.action_id, a.accion, f.succeeded, f.server_principal_name AS login,
       f.database_principal_name AS usuario_bd, f.database_name AS base,
       f.schema_name, f.object_name AS objeto,
       LEFT(REPLACE(REPLACE(f.statement, CHAR(13), N' '), CHAR(10), N' '), 150) AS sentencia,
       f.client_ip, f.application_name AS aplicacion
INTO #auditoria
FROM sys.fn_get_audit_file(N'C:\AkilFlow\Audit\*.sqlaudit', DEFAULT, DEFAULT) f
OUTER APPLY (SELECT TOP (1) name AS accion FROM sys.dm_audit_actions da WHERE da.action_id = f.action_id) a
-- se excluyen las comprobaciones de permisos de la matriz (HAS_PERMS_BY_NAME, archivo 07): no son intentos reales
WHERE f.statement NOT LIKE N'%HAS[_]PERMS[_]BY[_]NAME%';
GO

PRINT N'=== 16.1 Qué se está auditando (debe incluir usuarios_sistema, la vista financiera y el DWH) ===';
SELECT N'AkilFlowOperaciones' AS base, d.audit_action_name AS accion,
       ISNULL(OBJECT_SCHEMA_NAME(d.major_id, DB_ID(N'AkilFlowOperaciones')) + N'.'
              + OBJECT_NAME(d.major_id, DB_ID(N'AkilFlowOperaciones')), d.class_desc) AS sobre
FROM AkilFlowOperaciones.sys.database_audit_specification_details d
UNION ALL
SELECT N'dwh_AkilFlow', d.audit_action_name, CASE d.class_desc WHEN N'SCHEMA' THEN N'todo el esquema dbo' ELSE d.class_desc END
FROM dwh_AkilFlow.sys.database_audit_specification_details d
ORDER BY base, sobre, accion;
GO

PRINT N'=== 16.2 DETALLE: cada intento DENEGADO (más reciente primero) ===';
SELECT TOP (100) hora_local, login, usuario_bd, base, accion, objeto, sentencia, client_ip, aplicacion
FROM #auditoria
WHERE succeeded = 0 AND action_id <> 'LGIF'
ORDER BY hora_local DESC;
GO

PRINT N'=== 16.3 RESUMEN POR USUARIO: cuántos intentos denegados hizo cada login ===';
SELECT login, usuario_bd, COUNT(*) AS intentos_denegados,
       COUNT(DISTINCT objeto) AS objetos_distintos,
       MIN(hora_local) AS primer_intento, MAX(hora_local) AS ultimo_intento
FROM #auditoria
WHERE succeeded = 0 AND action_id <> 'LGIF'
GROUP BY login, usuario_bd
ORDER BY intentos_denegados DESC;
GO

PRINT N'=== 16.4 RESUMEN POR OBJETO: qué tablas/vistas/SP intentaron usar sin permiso ===';
SELECT a.base, a.objeto, a.accion, COUNT(*) AS intentos,
       (SELECT STRING_AGG(l.login, N', ') WITHIN GROUP (ORDER BY l.login)
        FROM (SELECT DISTINCT b.login FROM #auditoria b
              WHERE b.succeeded = 0 AND b.base = a.base AND b.objeto = a.objeto AND b.accion = a.accion) l) AS logins
FROM #auditoria a
WHERE a.succeeded = 0 AND a.action_id <> 'LGIF'
GROUP BY a.base, a.objeto, a.accion
ORDER BY intentos DESC;
GO

PRINT N'=== 16.5 INICIOS DE SESIÓN FALLIDOS (contraseña incorrecta o login inexistente) ===';
SELECT TOP (50) hora_local, login, client_ip, aplicacion
FROM #auditoria
WHERE action_id = 'LGIF'
ORDER BY hora_local DESC;
GO

PRINT N'=== 16.6 Ejemplo de filtro: solo un login (cambie el nombre) ===';
SELECT hora_local, accion, objeto, sentencia
FROM #auditoria
WHERE succeeded = 0 AND login = N'login_operador'
ORDER BY hora_local DESC;
GO
DROP TABLE #auditoria;
GO
PRINT N'>>> FASE 16 OK: cada intento sin permiso queda registrado con login, objeto, acción, hora y sentencia.';
GO
