# Manual de uso — AkilFlow (Transportes Akil S.A.C.) · BD2 Grupo 6

AkilFlow tiene **dos bases de datos en SQL Server 2022**:

|Rol|Login|Login:wq


| Base | Qué contiene |
|---|---|
| `AkilFlowOperaciones` (OLTP) | 7 tablas: `empresas`, `sucursales`, `rutas`, `vehiculos`, `viajes`, `encomiendas`, `usuarios_sistema`. Datos personales cifrados con AES_256, 4 roles RBAC y auditoría. |
| `dwh_AkilFlow` (Data Warehouse) | Esquema estrella (`fact_encomiendas` + 5 dimensiones), staging, ETL incremental (`usp_etl_akilflow`) y la vista `vw_bi_encomiendas` para BI. |

No es una aplicación web: se usa desde **SSMS**, **Azure Data Studio**, **DBeaver** o `sqlcmd`.

---

## 1. Credenciales

### Logins por rol (autenticación SQL)

| Rol | Login | Contraseña | Base | Qué puede hacer | Qué NO puede hacer |
|---|---|---|---|---|---|
| **Operador** (despachador de agencia) | `login_operador` | `Akil#Operador2026` | AkilFlowOperaciones | Leer sucursales/rutas/vehículos/viajes/encomiendas; registrar encomiendas con `usp_registrar_encomienda`; ver datos descifrados con `usp_consultar_encomienda`; cambiar `estado` y `viaje_id` de encomiendas y `estado` de viajes | DELETE, INSERT directo en `encomiendas` (Msg 229); cambiar `precio_envio` (Msg 230); leer `usuarios_sistema` y la vista financiera |
| **Supervisor** (jefe de operaciones) | `login_supervisor` | `Akil#Supervisor2026` | AkilFlowOperaciones | Leer todo; INSERT/UPDATE en `viajes`, `vehiculos`, `rutas`; usar los dos SP (ve datos personales descifrados) | DELETE en cualquier tabla; cambios de estructura (DDL) |
| **Auditor** (control interno) | `login_auditor` | `Akil#Auditor2026` | AkilFlowOperaciones | Leer todas las tablas (datos personales solo como binario `0x…`) | Escribir nada; ejecutar SP; abrir la llave AES (Msg 15151) |
| **Contador** (finanzas) | `login_contador` | `Akil#Contador2026` | AkilFlowOperaciones | `vw_resumen_financiero_viajes`, viajes, rutas, vehículos, sucursales y columnas no sensibles de `encomiendas` | Columnas cifradas (Msg 230), `usuarios_sistema`, cualquier escritura o EXEC |
| **Analista BI** | `login_analista_bi` | `Akil#AnalistaBI2026` | **dwh_AkilFlow** | Vista `vw_bi_encomiendas`, dimensiones y hechos | Tablas `staging_*` / `etl_*`; no tiene acceso a la base OLTP |

### Secretos internos (no son para iniciar sesión)

| Para qué | Valor |
|---|---|
| Database Master Key de `AkilFlowOperaciones` | `Akil#DMK.Operaciones2026` |
| Master Key de `master` (certificado de backups) | `Akil#MasterKey.Instancia2026` |

### Administrador

`sa` o tu usuario de Windows con rol **sysadmin**. Necesario para restaurar y para la demo.
En el contenedor de prueba que se levantó: usuario `sa`, contraseña `Akil#Sa.Prueba2026`.

> Para entrar con los logins SQL, la instancia debe estar en **modo de autenticación mixto**
> (SSMS → clic derecho al servidor → Propiedades → Seguridad → "SQL Server y Windows" → reiniciar el servicio).
> En Docker/Linux ya viene en modo mixto.

---

## 2. Instalación en Windows (lo que hará el docente)

1. Instalar **SQL Server 2022** (Developer/Standard/Enterprise). Los `.bak` **no** restauran en 2019.
2. Copiar `00_ENTREGA_Restaurar/AkilFlowOperaciones.bak` y `dwh_AkilFlow.bak` a `C:\AkilFlow\Entrega\`.
   - Si sale *Operating system error 5 (Access is denied)*: copiarlos a la carpeta `Backup` de la instancia
     (p. ej. `C:\Program Files\Microsoft SQL Server\MSSQL16.MSSQLSERVER\MSSQL\Backup\`) y cambiar la ruta del **PASO 0**.
3. Abrir `00_ENTREGA_Restaurar/00_Restaurar_Proyecto.sql` en SSMS como sysadmin y pulsar **F5** (< 1 min).
4. Al final debe aparecer `RESTAURACIÓN COMPLETADA` y las tablas de verificación:
   2 bases ONLINE, 5 usuarios enlazados (ningún `*** HUÉRFANO ***`), Audit + XE en `ACTIVO`.

## 3. Instalación en Linux / macOS con Docker (probado)

```bash
cd ProyectoFinal_Grupo06

docker run -d --name akilflow-prueba \
  -e ACCEPT_EULA=Y -e 'MSSQL_SA_PASSWORD=Akil#Sa.Prueba2026' \
  -e MSSQL_AGENT_ENABLED=true -e MSSQL_PID=Developer \
  -p 14333:1433 -v "$PWD/00_ENTREGA_Restaurar:/bak:ro" \
  mcr.microsoft.com/mssql/server:2022-latest

# Los scripts usan rutas C:\AkilFlow\..., se convierten a rutas Linux:
for f in 00_Restaurar_Proyecto 01_Demo_En_Clase; do
  sed -e 's#C:\\AkilFlow\\Entrega\\#/bak/#g' \
      -e 's#C:\\AkilFlow\\\([A-Za-z]*\)\\#/var/opt/mssql/akil/\1/#g' \
      -e 's#C:\\AkilFlow\\\([A-Za-z]*\)#/var/opt/mssql/akil/\1#g' \
      00_ENTREGA_Restaurar/$f.sql > /tmp/$f.linux.sql
  docker cp /tmp/$f.linux.sql akilflow-prueba:/tmp/$f.sql
done

# Restaurar (esperar ~20 s a que arranque el servidor)
docker exec akilflow-prueba /opt/mssql-tools18/bin/sqlcmd -C -I \
  -S localhost -U sa -P 'Akil#Sa.Prueba2026' -i /tmp/00_Restaurar_Proyecto.sql
```

Conexión desde DBeaver / Azure Data Studio: servidor `localhost,14333`, "Trust server certificate" activado.

> **Importante con `sqlcmd`:** usar siempre la opción `-I` (QUOTED_IDENTIFIER ON). Sin ella, los
> UPDATE/DELETE sobre `encomiendas` fallan con *Msg 1934* por los índices filtrados. SSMS ya lo trae activado.

---

## 4. Cómo probar cada rol

### Opción A — Iniciar sesión con el login del rol (realista)

En SSMS: *Connect* → Authentication **SQL Server Authentication** → login y contraseña de la tabla de arriba.
Con sqlcmd:

```bash
docker exec -it akilflow-prueba /opt/mssql-tools18/bin/sqlcmd -C -I -S localhost \
  -U login_operador -P 'Akil#Operador2026' -d AkilFlowOperaciones
```

### Opción B — Suplantar el usuario siendo sysadmin (lo que usa la demo)

```sql
USE AkilFlowOperaciones;
EXECUTE AS USER = 'usr_operador';   -- usr_supervisor, usr_auditor, usr_contador
SELECT USER_NAME();
-- ... pruebas ...
REVERT;
```

### Pruebas sugeridas y resultado esperado

```sql
-- OPERADOR -------------------------------------------------------------
EXEC dbo.usp_consultar_encomienda 'AK20261125PEND01';         -- OK: remitente/destinatario en texto claro
EXEC dbo.usp_registrar_encomienda
     @codigo_rastreo='AK-MI-PRUEBA-01', @usuario_registro_id=9,
     @remitente=N'Juan Pérez', @documento_remitente='12345678',
     @destinatario=N'Ana Díaz', @telefono_destinatario='987000111',
     @descripcion=N'Caja de prueba', @peso_kg=5, @precio_envio=20;   -- OK: se guarda cifrado
UPDATE dbo.encomiendas SET estado='en_transito' WHERE codigo_rastreo='AK-MI-PRUEBA-01'; -- OK
UPDATE dbo.encomiendas SET precio_envio=0 WHERE codigo_rastreo='AK-MI-PRUEBA-01';      -- Msg 230
DELETE FROM dbo.encomiendas WHERE codigo_rastreo='AK-MI-PRUEBA-01';                    -- Msg 229
SELECT * FROM dbo.usuarios_sistema;                                                    -- Msg 229

-- SUPERVISOR -----------------------------------------------------------
SELECT COUNT(*) FROM dbo.viajes;                                -- OK (697)
UPDATE dbo.vehiculos SET estado='mantenimiento' WHERE placa='T6H-226';   -- OK
DELETE FROM dbo.viajes WHERE estado='cancelado';                -- Msg 229

-- AUDITOR --------------------------------------------------------------
SELECT TOP 3 codigo_rastreo, remitente_cif FROM dbo.encomiendas;  -- OK, pero remitente sale como 0x...
EXEC dbo.usp_consultar_encomienda 'AK20261125PEND01';             -- Msg 229
UPDATE dbo.encomiendas SET estado=estado WHERE encomienda_id=1;   -- Msg 229

-- CONTADOR -------------------------------------------------------------
SELECT TOP 5 * FROM dbo.vw_resumen_financiero_viajes ORDER BY viaje_id DESC;  -- OK: ingresos y margen
SELECT TOP 1 remitente_cif FROM dbo.encomiendas;                              -- Msg 230

-- ANALISTA BI (base dwh_AkilFlow) ------------------------------------
SELECT TOP 10 * FROM dbo.vw_bi_encomiendas;     -- OK
SELECT TOP 1 * FROM dbo.staging_encomiendas;    -- Msg 229
```

Significado de los errores: **Msg 229** = permiso denegado sobre el objeto; **Msg 230** = denegado sobre una
columna; **Msg 15151** = no puede ver/abrir la llave simétrica.

---

## 5. Demo para la exposición

Abrir `00_ENTREGA_Restaurar/01_Demo_En_Clase.sql` y ejecutar **por bloques** (seleccionar + F5):

| Bloque | Criterio | Qué muestra |
|---|---|---|
| A | 2 | Plan de ejecución antes/después del índice (activar *Incluir plan real*, Ctrl+M) |
| B | 3 | RBAC: operador OK/Msg 229/230, auditor sin llave (Msg 15151), contador sin PII, REVOKE vs DENY |
| C | 4 | SQL Server Audit: bitácora de cambios de permisos |
| D | 4 | Extended Events: captura solo la consulta de 3 s, no la rápida |
| E | 4 | DRP: backup FULL → DIFF → LOG cifrados y restauración en `AkilFlowOperaciones_DR` |
| F | 5 | ETL incremental (MERGE) + cuarentena de errores en `etl_errores` |
| G | 5 | Consultas OLAP (ROLLUP/CUBE, ranking) y seguridad del Analista BI |

Los mensajes rojos de los bloques B y G son **intencionales**.

Ejecutar el ETL a mano: `EXEC dwh_AkilFlow.dbo.usp_etl_akilflow;` (también queda un Job diario a las 02:00).

---

## 6. Problemas comunes

| Síntoma | Solución |
|---|---|
| `Login failed for user 'login_xxx'` | Instancia en modo solo Windows → activar modo mixto y reiniciar. O contraseña mal escrita (distingue mayúsculas; empieza con `Akil#`). |
| `Cannot open database "AkilFlowOperaciones"` con `login_analista_bi` | Normal: ese rol solo tiene acceso a `dwh_AkilFlow`. |
| Error al restaurar: versión | Los `.bak` exigen SQL Server 2022 (16.x). |
| `Operating system error 5` | Mover los `.bak` a la carpeta `Backup` de la instancia y editar el PASO 0. |
| Datos personales salen `NULL` al descifrar como sa | Volver a ejecutar el PASO 6 del script de restauración (re-vincula la DMK). |
| Msg 1934 `QUOTED_IDENTIFIER` | Usar `sqlcmd -I` o `SET QUOTED_IDENTIFIER ON;`. |
| Volver al estado original | Ejecutar de nuevo `00_Restaurar_Proyecto.sql` (usa `REPLACE`). |

## 7. Apagar / borrar el contenedor de prueba

```bash
docker stop akilflow-prueba     # apagar (conserva los datos)
docker start akilflow-prueba    # volver a encender
docker rm -f akilflow-prueba    # borrar del todo
```
