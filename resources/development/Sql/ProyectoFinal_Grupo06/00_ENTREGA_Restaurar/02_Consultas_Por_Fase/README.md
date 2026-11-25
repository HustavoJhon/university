# Consultas de demostración por fase (Windows + SQL Server Management Studio)

Sirven para demostrar, durante o después de la exposición, que todo lo explicado funciona.

## Paso 1 · Restaurar (una vez)

SSMS conectado con **autenticación de Windows** → abrir `00_ENTREGA_Restaurar/00_Restaurar_Proyecto.sql` → **F5**.
Debe terminar en `RESTAURACIÓN COMPLETADA`.

## Paso 2 · Preparar los logins (una vez, después de cada restauración)

Con la misma conexión de Windows: abrir `00_Preparar_Logins_Modo_Mixto.sql` → **F5**.

Este script:
- activa el **modo mixto** (necesario para entrar con usuario y contraseña de SQL);
- habilita, desbloquea y restablece la contraseña de los 5 logins;
- enlaza cada login con su usuario de base;
- amplía la auditoría para registrar los intentos denegados en **todas** las tablas, también en el DWH.

Si la primera tabla dice **`PENDIENTE: reinicie el servicio`**, reinicie una sola vez:
*Explorador de objetos → clic derecho en el servidor → Reiniciar*. Después vuelva a ejecutar el script:
todo debe decir **OK**.

## Paso 3 · Ingresar como un rol (lo que pide el profesor)

*Archivo → Conectar Explorador de objetos* (o el botón **Conectar**):

| Campo | Valor |
|---|---|
| Tipo de servidor | Motor de base de datos |
| Nombre del servidor | el mismo de siempre (ej. `localhost`, `.` o `.\SQLEXPRESS`) |
| Autenticación | **Autenticación de SQL Server** |
| Inicio de sesión / Contraseña | según la tabla de abajo |
| Cifrado (SSMS 20/21) | marcar **Certificado de servidor de confianza** (*Trust server certificate*) |

| Rol | Inicio de sesión | Contraseña | Base | Archivo de prueba |
|---|---|---|---|---|
| Operador | `login_operador` | `Akil#Operador2026` | AkilFlowOperaciones | `02_Rol_Operador.sql` |
| Supervisor | `login_supervisor` | `Akil#Supervisor2026` | AkilFlowOperaciones | `03_Rol_Supervisor.sql` |
| Auditor | `login_auditor` | `Akil#Auditor2026` | AkilFlowOperaciones | `04_Rol_Auditor.sql` |
| Contador | `login_contador` | `Akil#Contador2026` | AkilFlowOperaciones | `05_Rol_Contador.sql` |
| Analista BI | `login_analista_bi` | `Akil#AnalistaBI2026` | **dwh_AkilFlow** | `06_Rol_Analista_BI.sql` |

Ya conectado como el rol: *Archivo → Abrir* el archivo de prueba → verificar arriba que la conexión
de la pestaña sea la del rol → **F5**.

**Qué se ve:**
1. `¿Quién soy?`: confirma el login, el usuario de base y el rol.
2. Las tablas con columna `prueba` = `(1)`, `(2)`… son los datos que el rol **sí** puede ver.
3. **La última tabla** resume cada prueba: `esperado`, `obtenido` y **`✔ CORRECTO`**. En las denegadas,
   la columna `mensaje_sql_server` muestra el error real (Msg 229, 230, 916…).
4. La conclusión, por ejemplo `14 de 14 pruebas correctas`.

No salen errores en rojo: cada prueba se ejecuta protegida. Los archivos 02 a 06 también funcionan
desde la conexión de Windows (administrador): en ese caso se convierten solos en el rol
(`EXECUTE AS LOGIN`) y al final vuelven a su usuario.

En el **Explorador de objetos** de la conexión del rol también se nota la seguridad: el contador no ve
la tabla `usuarios_sistema`, y el analista BI no puede abrir `AkilFlowOperaciones`.

### Probar a mano (Nueva consulta con la conexión del rol)

```sql
SELECT SUSER_NAME() AS login, USER_NAME() AS usuario;              -- ¿quién soy?
SELECT * FROM dbo.sucursales;                                      -- todos los roles OLTP: OK
EXEC dbo.usp_consultar_encomienda 'AK20261125PEND01';              -- operador/supervisor: OK · auditor/contador: Msg 229
DELETE FROM dbo.encomiendas WHERE encomienda_id = -1;              -- todos: Msg 229
UPDATE dbo.encomiendas SET precio_envio = 0 WHERE encomienda_id = -1;  -- operador/supervisor: Msg 230
SELECT TOP 5 remitente_cif FROM dbo.encomiendas;                   -- contador: Msg 230 · auditor: binario
SELECT TOP 5 * FROM dbo.usuarios_sistema;                          -- operador/contador: Msg 229
SELECT TOP 5 * FROM dbo.vw_resumen_financiero_viajes;              -- operador: Msg 229
-- analista BI (base dwh_AkilFlow):
SELECT TOP 5 * FROM dbo.vw_bi_encomiendas;                         -- OK
SELECT TOP 5 * FROM dbo.staging_encomiendas;                       -- Msg 229
```

Cada intento denegado queda registrado y se ve con el archivo **16**.

## Paso 4 · El resto de fases (conexión de Windows / administrador)

Pulse **Ctrl + T** (*Resultados en texto*) para ver títulos, tablas y mensajes en orden. Abrir cada archivo → **F5**.

| # | Archivo | Qué demuestra |
|---|---|---|
| 01 | `01_Ver_Bases_y_Tablas.sql` | Bases ONLINE, tablas con número de filas, columnas cifradas (VARBINARY), muestra de datos, usuarios ↔ roles |
| 07 | `07_Matriz_Permisos_y_REVOKE.sql` | Tabla SÍ/no de los 4 roles × objeto × permiso; GRANT/DENY declarados; REVOKE vs DENY en vivo |
| 08 | `08_Cifrado_AES256.sql` | Jerarquía SMK → DMK → certificado → llave AES_256; binario vs descifrado |
| 09 | `09_Indices_Plan_Ejecucion.sql` | Plan Scan → Seek; lecturas lógicas 381 → 5 (pestaña Mensajes). Plan gráfico: Ctrl + M |
| 10 | `10_Auditoria.sql` | Configuración de la auditoría; UPDATE permitido y DELETE denegado registrados; GRANT/REVOKE |
| 11 | `11_Extended_Events.sql` | La consulta rápida no se captura; la de 3 s sí |
| 12 | `12_Backups_FULL_DIFF_LOG.sql` | Crea **Demo_FULL.bak**, **Demo_DIFF.bak** y **Demo_LOG.trn** cifrados AES_256 en `C:\AkilFlow\Backups\`: ruta, tamaño, compresión, cifrado, LSN y `RESTORE VERIFYONLY` |
| 13 | `13_Restaurar_DRP.sql` | Restaura FULL → DIFF → LOG en `AkilFlowOperaciones_DR` (RESTORING → ONLINE) sin pérdida de datos |
| 14 | `14_ETL_Incremental.sql` | Nueva encomienda en la OLTP → ETL → aparece en `fact_encomiendas` |
| 15 | `15_Consultas_OLAP.sql` | ROLLUP, CUBE, RANK, LAG, SLICE y DICE |
| 16 | `16_Intentos_Denegados.sql` | **Quién intentó entrar a qué sin permiso**: detalle, resumen por usuario, resumen por tabla y logins fallidos |

## ¿Dónde veo qué usuarios intentaron entrar a tablas sin permiso?

1. **Con consulta:** `16_Intentos_Denegados.sql` (conexión de administrador).
   - 16.2: cada intento denegado con hora, login, base, acción, tabla y sentencia exacta.
   - 16.3: cuántos intentos hizo cada login.
   - 16.4: qué tablas, vistas o SP se intentaron usar y por quién.
   - 16.5: inicios de sesión fallidos (contraseña incorrecta).
2. **Sin consulta, en SSMS:** *Explorador de objetos → Seguridad → Auditorías → `Audit_AkilFlow` →
   clic derecho → **Ver registros de auditoría***. Filtre *Correcto = False* para ver solo los denegados.
3. **Los archivos en disco:** `C:\AkilFlow\Audit\*.sqlaudit`.

Para generar ejemplos: ejecute los archivos 02 a 06, o conéctese como un rol e intente algo no permitido.
Para un login fallido: intente conectarse con una contraseña incorrecta.

## Archivos que se generan en disco

| Carpeta | Contenido | Lo crea |
|---|---|---|
| `C:\AkilFlow\Backups\` | `Demo_FULL.bak`, `Demo_DIFF.bak`, `Demo_LOG.trn` | 12 |
| `C:\AkilFlow\DR\` | `.mdf` y `.ldf` de `AkilFlowOperaciones_DR` | 13 |
| `C:\AkilFlow\Audit\` | `*.sqlaudit` (bitácora de auditoría) | restauración |
| `C:\AkilFlow\XEvents\` | `*.xel` (consultas lentas) | restauración |

## Problemas comunes

| Síntoma | Solución |
|---|---|
| `Error 18456 Login failed` al conectar como rol | Falta el modo mixto o el reinicio: ejecute `00_Preparar_Logins_Modo_Mixto.sql` y reinicie el servicio |
| *The certificate chain was issued by an authority that is not trusted* | Marque **Certificado de servidor de confianza** en la ventana de conexión |
| *The login is locked out* | Ejecute de nuevo `00_Preparar_Logins_Modo_Mixto.sql` (desbloquea) |
| El archivo de rol dice *Conéctese con el login … o con un usuario sysadmin* | Está conectado con otro rol: use el login de ese archivo o la conexión de Windows |
| Los archivos 07–16 fallan por permisos | Se ejecutan con la conexión de **Windows/administrador**, no con un rol |
| *Operating system error 5* en los backups | La cuenta del servicio no puede escribir en `C:\AkilFlow\Backups`: ejecute de nuevo el PASO 1 de la restauración o dé permisos a la carpeta |
| Volver al estado original | Ejecute `00_Restaurar_Proyecto.sql` y luego `00_Preparar_Logins_Modo_Mixto.sql` |

Probado de principio a fin sobre una restauración limpia en SQL Server 2022: los 5 roles, entrando con
su login y desde administrador, 52/52 pruebas ✔ CORRECTO y 0 errores en todos los archivos.
