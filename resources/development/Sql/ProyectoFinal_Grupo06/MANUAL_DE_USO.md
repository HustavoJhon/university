# Manual de uso — AkilFlow (Transportes Akil S.A.C.) · BD2 Grupo 6

AkilFlow tiene **dos bases de datos en SQL Server 2022**. Se usa desde **SQL Server Management Studio (SSMS)**.

| Base | Qué contiene |
|---|---|
| `AkilFlowOperaciones` (OLTP) | 7 tablas: `empresas`, `sucursales`, `rutas`, `vehiculos`, `viajes`, `encomiendas`, `usuarios_sistema`. Datos personales cifrados con AES_256, 4 roles y auditoría. |
| `dwh_AkilFlow` (Data Warehouse) | Esquema estrella (`fact_encomiendas` + 5 dimensiones), staging, ETL incremental y la vista `vw_bi_encomiendas` para BI. |

---

## 1. Credenciales

### Usuarios para ingresar como cada rol (Autenticación de SQL Server)

| Rol | Inicio de sesión | Contraseña | Base | Archivo de prueba |
|---|---|---|---|---|
| **Operador** (despachador de agencia) | `login_operador` | `Akil#Operador2026` | AkilFlowOperaciones | `02_Rol_Operador.sql` |
| **Supervisor** (jefe de operaciones) | `login_supervisor` | `Akil#Supervisor2026` | AkilFlowOperaciones | `03_Rol_Supervisor.sql` |
| **Auditor** (control interno) | `login_auditor` | `Akil#Auditor2026` | AkilFlowOperaciones | `04_Rol_Auditor.sql` |
| **Contador** (finanzas) | `login_contador` | `Akil#Contador2026` | AkilFlowOperaciones | `05_Rol_Contador.sql` |
| **Analista BI** | `login_analista_bi` | `Akil#AnalistaBI2026` | **dwh_AkilFlow** | `06_Rol_Analista_BI.sql` |

Las contraseñas distinguen mayúsculas y empiezan con `Akil#`.
Los archivos de prueba están en `00_ENTREGA_Restaurar/02_Consultas_Por_Fase/`.

### Qué puede y qué no puede hacer cada rol

| Rol | ✔ Puede | ✘ No puede |
|---|---|---|
| Operador | Leer sucursales, rutas, vehículos, viajes y encomiendas (datos personales en binario); registrar encomiendas con `usp_registrar_encomienda` (se cifran solas); ver una encomienda descifrada con `usp_consultar_encomienda`; cambiar el **estado** de encomiendas y viajes | Borrar (Msg 229); insertar directo en `encomiendas` (Msg 229); cambiar el **precio** (Msg 230); leer `usuarios_sistema` o la vista financiera (Msg 229); abrir la llave AES (Msg 15151); crear tablas (Msg 262) |
| Supervisor | Leer todo, incluido el personal; ver datos personales descifrados (SP); INSERT/UPDATE en `viajes`, `vehiculos` y `rutas`; cambiar el estado de encomiendas | Borrar cualquier cosa (Msg 229); cambiar el precio (Msg 230); alterar o crear tablas (Msg 1088 / 262) |
| Auditor | Leer todas las tablas y la vista financiera; los datos personales **solo en binario** (`0x…`) | Escribir nada (Msg 229); usar los SP (Msg 229); abrir la llave AES (Msg 15151) |
| Contador | Vista financiera (ingresos, costos, margen); viajes, rutas, vehículos, sucursales; columnas no sensibles de `encomiendas` (precio, peso, estado) | Columnas con datos personales (Msg 230); `SELECT *` de encomiendas (Msg 230); el personal (Msg 229); escribir o ejecutar SP (Msg 229) |
| Analista BI | Vista `vw_bi_encomiendas`, dimensiones y hechos del DWH | Staging y bitácora del ETL (Msg 229); ejecutar el ETL (Msg 229); modificar datos (Msg 229); entrar a `AkilFlowOperaciones` (Msg 916) |

### Administrador

Tu usuario de **Windows** con rol sysadmin (o `sa`). Es necesario para restaurar, preparar los logins y ejecutar los archivos 07–16.
En el contenedor Docker de prueba: usuario `sa`, contraseña `Akil#Sa.Prueba2026`.

### Secretos internos (no sirven para iniciar sesión)

| Para qué | Valor |
|---|---|
| Database Master Key de `AkilFlowOperaciones` | `Akil#DMK.Operaciones2026` |
| Master Key de `master` (certificado de backups) | `Akil#MasterKey.Instancia2026` |

---

## 2. Instalación en Windows

1. Instalar **SQL Server 2022** (Developer/Standard/Enterprise). Los `.bak` **no** restauran en 2019.
2. Copiar `00_ENTREGA_Restaurar/AkilFlowOperaciones.bak` y `dwh_AkilFlow.bak` a `C:\AkilFlow\Entrega\`.
   - Si sale *Operating system error 5 (Access is denied)*: copiarlos a la carpeta `Backup` de la instancia
     (p. ej. `C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\`) y cambiar la ruta del **PASO 0**.
3. SSMS con **autenticación de Windows** → abrir `00_ENTREGA_Restaurar/00_Restaurar_Proyecto.sql` → **F5** (menos de 1 min).
   Debe terminar en `RESTAURACIÓN COMPLETADA`.
4. Con la misma conexión: abrir `00_ENTREGA_Restaurar/02_Consultas_Por_Fase/00_Preparar_Logins_Modo_Mixto.sql` → **F5**.
   Este script:
   - activa el **modo mixto** (sin él no se puede entrar con usuario y contraseña de SQL);
   - habilita, desbloquea y restablece la contraseña de los 5 logins;
   - enlaza cada login con su usuario de base;
   - amplía la auditoría para registrar los intentos denegados en todas las tablas.
5. Si la primera tabla del resultado dice **`PENDIENTE: reinicie el servicio`**: *Explorador de objetos → clic
   derecho en el servidor → **Reiniciar*** y vuelva a ejecutar el paso 4. Todo debe decir **OK**.

Repetir los pasos 3 y 4 cada vez que se restaure de nuevo.

---

## 3. Ingresar con cada usuario y probar sus permisos

### 3.1 Conectarse como el rol

En SSMS: *Archivo → Conectar Explorador de objetos* (o el botón **Conectar**):

| Campo | Valor |
|---|---|
| Tipo de servidor | Motor de base de datos |
| Nombre del servidor | el mismo de siempre (ej. `localhost`, `.` o `.\SQLEXPRESS`) |
| Autenticación | **Autenticación de SQL Server** |
| Inicio de sesión | p. ej. `login_operador` |
| Contraseña | p. ej. `Akil#Operador2026` |
| Cifrado (SSMS 20/21) | marcar **Certificado de servidor de confianza** (*Trust server certificate*) |

Al conectarse, el Explorador de objetos ya muestra la seguridad. Por ejemplo, el analista BI no puede
abrir `AkilFlowOperaciones`.

### 3.2 Ejecutar la prueba automática del rol

Con esa conexión: *Archivo → Abrir* → `02_Consultas_Por_Fase/02_Rol_Operador.sql` (o el archivo del rol) → **F5**.

Resultado:
1. `¿Quién soy?`: login, usuario de base y rol.
2. Tablas con columna `prueba` = `(1)`, `(2)`…: los datos que el rol **sí** puede ver.
3. **Tabla final**: cada prueba con `esperado`, `obtenido` y **✔ CORRECTO**. En las denegadas,
   `mensaje_sql_server` muestra el error real (Msg 229, 230, 916…).
4. Conclusión, por ejemplo `14 de 14 pruebas correctas para login_operador`.

No aparecen errores en rojo, porque cada prueba va protegida. Los mismos archivos también funcionan
desde la conexión de Windows: se convierten solos en el rol (`EXECUTE AS LOGIN`) y al final vuelven.

### 3.3 Probar a mano

Con la conexión del rol → **Nueva consulta**:

```sql
SELECT SUSER_NAME() AS login, USER_NAME() AS usuario;   -- ¿quién soy?

-- OPERADOR -----------------------------------------------------------------
SELECT * FROM dbo.sucursales;                                         -- OK
EXEC dbo.usp_consultar_encomienda 'AK20261125PEND01';                 -- OK: datos personales descifrados
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo='AK-MI-PRUEBA-01', @usuario_registro_id=9,
     @remitente=N'Juan Pérez', @documento_remitente='12345678',
     @destinatario=N'Ana Díaz', @telefono_destinatario='987000111',
     @descripcion=N'Caja de prueba', @peso_kg=5, @precio_envio=20;    -- OK: se guarda cifrada
UPDATE dbo.encomiendas SET estado='entregada' WHERE codigo_rastreo='AK-MI-PRUEBA-01';  -- OK
UPDATE dbo.encomiendas SET precio_envio=0 WHERE codigo_rastreo='AK-MI-PRUEBA-01';      -- Msg 230
DELETE FROM dbo.encomiendas WHERE codigo_rastreo='AK-MI-PRUEBA-01';                    -- Msg 229
SELECT * FROM dbo.usuarios_sistema;                                                    -- Msg 229

-- SUPERVISOR ---------------------------------------------------------------
SELECT * FROM dbo.usuarios_sistema;                                   -- OK
UPDATE dbo.vehiculos SET estado = estado WHERE placa = 'M1C-302';     -- OK
DELETE FROM dbo.viajes WHERE viaje_id = -1;                           -- Msg 229

-- AUDITOR ------------------------------------------------------------------
SELECT TOP 3 codigo_rastreo, remitente_cif FROM dbo.encomiendas;      -- OK, pero sale 0x... (cifrado)
EXEC dbo.usp_consultar_encomienda 'AK20261125PEND01';                 -- Msg 229
UPDATE dbo.encomiendas SET estado = estado WHERE encomienda_id = 1;   -- Msg 229

-- CONTADOR -----------------------------------------------------------------
SELECT TOP 5 * FROM dbo.vw_resumen_financiero_viajes;                 -- OK: ingresos y margen
SELECT TOP 1 remitente_cif FROM dbo.encomiendas;                      -- Msg 230
SELECT TOP 1 * FROM dbo.usuarios_sistema;                             -- Msg 229

-- ANALISTA BI (conectado a dwh_AkilFlow) -----------------------------------
SELECT TOP 10 * FROM dbo.vw_bi_encomiendas;                           -- OK
SELECT TOP 1 * FROM dbo.staging_encomiendas;                          -- Msg 229
SELECT TOP 1 * FROM AkilFlowOperaciones.dbo.sucursales;               -- Msg 916
```

| Error | Significado |
|---|---|
| Msg 229 | Permiso denegado sobre la tabla, vista o SP |
| Msg 230 | Permiso denegado sobre una columna |
| Msg 262 | No puede crear objetos |
| Msg 1088 | No puede alterar la tabla |
| Msg 916 | El login no tiene usuario en esa base |
| Msg 15151 | No puede ver ni abrir la llave AES_256 |

### 3.4 Ver qué usuarios intentaron entrar a donde no tienen permiso

Con la conexión de **Windows/administrador**:

- **Con consulta:** `02_Consultas_Por_Fase/16_Intentos_Denegados.sql` → F5. Muestra cada intento denegado
  (hora, login, base, acción, tabla y sentencia exacta), resúmenes por usuario y por tabla, y los inicios
  de sesión fallidos.
- **Sin consulta:** *Explorador de objetos → Seguridad → Auditorías → `Audit_AkilFlow` → clic derecho →
  **Ver registros de auditoría***, y filtrar *Correcto = False*.

---

## 4. Demostrar el resto de fases

Con la conexión de Windows, en `00_ENTREGA_Restaurar/02_Consultas_Por_Fase/`: **Ctrl + T** (resultados en texto),
abrir cada archivo y pulsar **F5**. El detalle de cada archivo está en el README de esa carpeta.

| Archivo | Qué demuestra |
|---|---|
| `01_Ver_Bases_y_Tablas.sql` | Bases restauradas, tablas y filas, columnas cifradas, usuarios ↔ roles |
| `07_Matriz_Permisos_y_REVOKE.sql` | Tabla SÍ/no de cada rol por objeto y permiso; REVOKE vs DENY |
| `08_Cifrado_AES256.sql` | Jerarquía de llaves; datos binarios vs descifrados |
| `09_Indices_Plan_Ejecucion.sql` | Plan Scan → Seek; lecturas lógicas 381 → 5 |
| `10_Auditoria.sql` | Bitácora de cambios, denegaciones y GRANT/REVOKE |
| `11_Extended_Events.sql` | Captura solo la consulta de más de 2 s |
| `12_Backups_FULL_DIFF_LOG.sql` | Crea `Demo_FULL.bak`, `Demo_DIFF.bak` y `Demo_LOG.trn` cifrados en `C:\AkilFlow\Backups\` y muestra ruta, tamaño, cifrado y verificación |
| `13_Restaurar_DRP.sql` | Restaura FULL → DIFF → LOG en `AkilFlowOperaciones_DR` sin pérdida |
| `14_ETL_Incremental.sql` | Nueva encomienda → ETL → aparece en el DWH |
| `15_Consultas_OLAP.sql` | ROLLUP, CUBE, RANK, LAG, SLICE y DICE |
| `16_Intentos_Denegados.sql` | Quién intentó acceder a qué sin permiso |

También se puede usar la demo en bloques `00_ENTREGA_Restaurar/01_Demo_En_Clase.sql` (A–G, seleccionar cada
bloque y pulsar F5). Los mensajes rojos de sus bloques B y G son intencionales.

---

## 5. Problemas comunes

| Síntoma | Solución |
|---|---|
| `Error 18456: Login failed for user 'login_xxx'` | Falta el modo mixto o el reinicio: ejecute `00_Preparar_Logins_Modo_Mixto.sql` y reinicie el servicio. O la contraseña está mal escrita. |
| *The certificate chain was issued by an authority that is not trusted* | Marque **Certificado de servidor de confianza** en la ventana de conexión |
| *The login is locked out* | Ejecute de nuevo `00_Preparar_Logins_Modo_Mixto.sql` (desbloquea) |
| `Cannot open database "AkilFlowOperaciones"` con `login_analista_bi` | Es lo esperado: ese rol solo tiene acceso a `dwh_AkilFlow` |
| El archivo de rol dice *Conéctese con el login … o con un usuario sysadmin* | La pestaña está conectada con otro rol: use el login de ese archivo o la conexión de Windows |
| Los archivos 07–16 fallan por permisos | Se ejecutan con la conexión de Windows/administrador, no con un rol |
| Error al restaurar por la versión | Los `.bak` exigen SQL Server 2022 (16.x) |
| `Operating system error 5` | Mueva los `.bak` a la carpeta `Backup` de la instancia y edite el PASO 0 |
| Datos personales salen `NULL` al descifrar como administrador | Vuelva a ejecutar el PASO 6 del script de restauración (re-vincula la DMK) |
| Volver al estado original | Ejecute `00_Restaurar_Proyecto.sql` y luego `00_Preparar_Logins_Modo_Mixto.sql` |

---

## 6. Alternativa en Linux/macOS con Docker

Desde `04_Demo_Docker/`:

```bash
./demo.sh levantar               # SQL Server 2022 en el puerto 14333
./demo.sh 00                     # restaurar y preparar logins
./demo.sh 02                     # operador (02..06 = cada rol, con su login real)
./demo.sh todo                   # todas las fases 01-16
./demo.sh consola operador       # consola SQL como un rol (supervisor|auditor|contador|analista|sa)
./demo.sh borrar                 # eliminar el contenedor
```

Desde DBeaver / Azure Data Studio: servidor `localhost,14333` con *Trust server certificate*.
Con `sqlcmd` use siempre `-I` (QUOTED_IDENTIFIER ON); si falta, aparece el Msg 1934.
El detalle está en `04_Demo_Docker/README.md`.
