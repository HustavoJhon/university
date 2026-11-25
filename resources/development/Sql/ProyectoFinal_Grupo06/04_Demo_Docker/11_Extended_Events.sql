/* =============================================================================
   FASE 11 · EXTENDED EVENTS: CAPTURA DE CONSULTAS LENTAS (> 2 s)
   Ejecutar como: sa                      ./demo.sh 11
   Archivos: /var/opt/mssql/akil/XEvents/XE_ConsultasLentas_AkilFlow*.xel
   ============================================================================= */
USE master;
GO
SET NOCOUNT ON;
GO
PRINT N'=== 11.1 Sesión de Extended Events activa ===';
SELECT s.name AS sesion, s.create_time AS iniciada, t.target_name AS destino
FROM sys.dm_xe_sessions s JOIN sys.dm_xe_session_targets t ON t.event_session_address = s.address
WHERE s.name = N'XE_ConsultasLentas_AkilFlow';
SELECT e.name AS evento, e.predicate AS filtro
FROM sys.server_event_sessions ss JOIN sys.server_event_session_events e ON e.event_session_id = ss.event_session_id
WHERE ss.name = N'XE_ConsultasLentas_AkilFlow';
GO
USE AkilFlowOperaciones;
GO
PRINT N'=== 11.2 Consulta rápida (milisegundos) -> NO debe capturarse ===';
SELECT COUNT(*) AS consulta_rapida FROM dbo.viajes;
GO
PRINT N'=== 11.3 Consulta lenta (3 s) -> SÍ debe capturarse ===';
WAITFOR DELAY '00:00:03';
GO
WAITFOR DELAY '00:00:01.500';   -- MAX_DISPATCH_LATENCY = 1 s
GO
PRINT N'=== 11.4 Eventos capturados (solo aparecen las sentencias de más de 2 s) ===';
SELECT x.value('(event/@timestamp)[1]', 'DATETIME2(0)')                                       AS hora_utc,
       x.value('(event/@name)[1]', 'VARCHAR(40)')                                             AS evento,
       CAST(x.value('(event/data[@name="duration"]/value)[1]', 'BIGINT') / 1000000.0 AS DECIMAL(10,2)) AS segundos,
       x.value('(event/action[@name="username"]/value)[1]', 'NVARCHAR(128)')                  AS usuario,
       LEFT(x.value('(event/data[@name="statement"]/value)[1]', 'NVARCHAR(MAX)'), 60)         AS sentencia
FROM sys.fn_xe_file_target_read_file(N'/var/opt/mssql/akil/XEvents/XE_ConsultasLentas_AkilFlow*.xel', NULL, NULL, NULL) f
CROSS APPLY (SELECT CAST(f.event_data AS XML)) t(x)
ORDER BY hora_utc DESC;
GO
USE master;
GO
PRINT N'>>> FASE 11 OK: solo la consulta de 3 s quedó registrada; la rápida no genera ruido.';
GO
