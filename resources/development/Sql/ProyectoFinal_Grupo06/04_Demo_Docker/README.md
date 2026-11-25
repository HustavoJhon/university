# Demo por fases en Docker — AkilFlow (BD2 Grupo 6)

Cada fase es un archivo `.sql` independiente. `demo.sh` lo copia al contenedor y lo ejecuta
**conectado con el login que corresponde** (sa o el login del rol).

Todos los comandos se ejecutan desde esta carpeta:

```bash
cd ProyectoFinal_Grupo06/04_Demo_Docker
```

## Orden de la demostración

| # | Comando | Archivo | Conectado como | Qué demuestra |
|---|---|---|---|---|
| — | `./demo.sh levantar` | — | — | Crea el contenedor SQL Server 2022 (puerto 14333) |
| 0 | `./demo.sh 00` | `00_Restaurar_Docker.sql` | sa | Restaura los 2 `.bak` + logins, auditoría, XE, certificado y Job |
| 1 | `./demo.sh 01` | `01_Ver_Bases_y_Tablas.sql` | sa | Bases ONLINE, tablas y filas, columnas cifradas, muestra de datos, usuarios ↔ roles |
| 2 | `./demo.sh 02` | `02_Rol_Operador.sql` | `login_operador` | Registra encomienda y cambia estado ✔ · DELETE, INSERT directo, precio, personal ✘ |
| 3 | `./demo.sh 03` | `03_Rol_Supervisor.sql` | `login_supervisor` | Lee todo, ve PII, actualiza flota ✔ · DELETE y DDL ✘ |
| 4 | `./demo.sh 04` | `04_Rol_Auditor.sql` | `login_auditor` | Lee todo (PII en binario) ✔ · llave, SP, cualquier escritura ✘ |
| 5 | `./demo.sh 05` | `05_Rol_Contador.sql` | `login_contador` | Vista financiera ✔ · columnas cifradas, personal, escritura ✘ |
| 6 | `./demo.sh 06` | `06_Rol_Analista_BI.sql` | `login_analista_bi` | Vista BI y estrella ✔ · staging, ETL, base OLTP ✘ |
| 7 | `./demo.sh 07` | `07_Matriz_Permisos_y_REVOKE.sql` | sa | Tabla SÍ/no de cada rol × objeto × permiso; REVOKE vs DENY |
| 8 | `./demo.sh 08` | `08_Cifrado_AES256.sql` | sa | Jerarquía de llaves, binario vs descifrado |
| 9 | `./demo.sh 09` | `09_Indices_Plan_Ejecucion.sql` | sa | Plan Scan → Seek y lecturas lógicas (381 → 5) |
| 10 | `./demo.sh login-fallido` y luego `./demo.sh 10` | `10_Auditoria.sql` | sa | Bitácora: UPDATE, DELETE denegado, GRANT/REVOKE, login fallido |
| 11 | `./demo.sh 11` | `11_Extended_Events.sql` | sa | Solo se captura la consulta de más de 2 s |
| 12 | `./demo.sh 12` | `12_Backups_FULL_DIFF_LOG.sql` | sa | Crea los 3 backups cifrados, muestra ruta, tamaño, cifrado y los verifica |
| — | `./demo.sh ver-backups` | — | — | `ls -lh` de la carpeta de backups dentro del contenedor |
| — | `./demo.sh copiar-backups` | — | — | Copia los 3 archivos a `./backups_generados/` en tu PC |
| 13 | `./demo.sh 13` | `13_Restaurar_DRP.sql` | sa | Restaura FULL → DIFF → LOG en `AkilFlowOperaciones_DR` y valida |
| 14 | `./demo.sh 14` | `14_ETL_Incremental.sql` | sa | Nueva encomienda en la OLTP → ETL → aparece en `fact_encomiendas` |
| 15 | `./demo.sh 15` | `15_Consultas_OLAP.sql` | sa | ROLLUP, CUBE, RANK, LAG, SLICE y DICE |

Atajos: `./demo.sh roles` (fases 02–07 seguidas) · `./demo.sh todo` (01–15) · `./demo.sh ayuda`.

Los mensajes **Msg 229 / 230 / 262 / 916 / 1088 / 15151** de las fases 2 a 7 son **intencionales**:
cada uno va precedido de `(DENEGADO n) ... ESPERADO: Msg xxx`.

| Error | Significado |
|---|---|
| Msg 229 | Permiso denegado sobre el objeto (tabla, vista, SP) |
| Msg 230 | Permiso denegado sobre una columna |
| Msg 262 | No puede crear objetos (DDL) |
| Msg 1088 | No puede alterar la tabla (DENY ALTER) |
| Msg 916 | El login no tiene usuario en esa base (capa 2) |
| Msg 15151 | No puede ver ni abrir la llave AES_256 |

## Rutas dentro del contenedor

| Qué | Ruta |
|---|---|
| `.bak` de entrega (solo lectura) | `/bak/` |
| Backups FULL / DIFF / LOG | `/var/opt/mssql/akil/Backups/Demo_FULL.bak`, `Demo_DIFF.bak`, `Demo_LOG.trn` |
| Base de contingencia (DRP) | `/var/opt/mssql/akil/DR/` |
| Auditoría | `/var/opt/mssql/akil/Audit/*.sqlaudit` |
| Extended Events | `/var/opt/mssql/akil/XEvents/*.xel` |

`./demo.sh ver-archivos` lista todo eso de una vez.

## Probar a mano con cada rol

```bash
./demo.sh consola operador      # también: supervisor | auditor | contador | analista | sa
```

Dentro de la consola se escribe la consulta, luego `GO` y Enter. Para salir: `exit`.

```sql
SELECT USER_NAME();
GO
DELETE FROM dbo.encomiendas WHERE encomienda_id = 1;   -- operador: Msg 229
GO
```

## Los mismos comandos sin `demo.sh`

```bash
# Crear el contenedor (desde la carpeta ProyectoFinal_Grupo06)
docker run -d --name akilflow-prueba -e ACCEPT_EULA=Y -e 'MSSQL_SA_PASSWORD=Akil#Sa.Prueba2026' \
  -e MSSQL_AGENT_ENABLED=true -e MSSQL_PID=Developer -p 14333:1433 \
  -v "$PWD/00_ENTREGA_Restaurar:/bak:ro" mcr.microsoft.com/mssql/server:2022-latest

# Copiar los scripts al contenedor
docker cp 04_Demo_Docker/. akilflow-prueba:/tmp/demo/

# Ejecutar una fase como sa
docker exec akilflow-prueba /opt/mssql-tools18/bin/sqlcmd -C -I -S localhost \
  -U sa -P 'Akil#Sa.Prueba2026' -W -s '|' -i /tmp/demo/01_Ver_Bases_y_Tablas.sql

# Ejecutar una fase como un rol (ejemplo: operador)
docker exec akilflow-prueba /opt/mssql-tools18/bin/sqlcmd -C -I -S localhost \
  -U login_operador -P 'Akil#Operador2026' -d AkilFlowOperaciones -W -s '|' -i /tmp/demo/02_Rol_Operador.sql

# Analista BI (su base es dwh_AkilFlow)
docker exec akilflow-prueba /opt/mssql-tools18/bin/sqlcmd -C -I -S localhost \
  -U login_analista_bi -P 'Akil#AnalistaBI2026' -d dwh_AkilFlow -W -s '|' -i /tmp/demo/06_Rol_Analista_BI.sql

# Ver y copiar los backups
docker exec akilflow-prueba ls -lh /var/opt/mssql/akil/Backups
docker cp akilflow-prueba:/var/opt/mssql/akil/Backups/. ./backups_generados/
```

`-C` confía en el certificado del servidor; `-I` activa QUOTED_IDENTIFIER (obligatorio, como en SSMS);
`-W -s '|'` da una salida compacta con columnas separadas por `|`.

## Credenciales

| Login | Contraseña | Base |
|---|---|---|
| `sa` | `Akil#Sa.Prueba2026` | todas |
| `login_operador` | `Akil#Operador2026` | AkilFlowOperaciones |
| `login_supervisor` | `Akil#Supervisor2026` | AkilFlowOperaciones |
| `login_auditor` | `Akil#Auditor2026` | AkilFlowOperaciones |
| `login_contador` | `Akil#Contador2026` | AkilFlowOperaciones |
| `login_analista_bi` | `Akil#AnalistaBI2026` | dwh_AkilFlow |

Desde DBeaver / Azure Data Studio: servidor `localhost,14333`, con "Trust server certificate" activado.

## Volver a empezar

`./demo.sh 00` restaura todo al estado original (las fases 2, 10, 12 y 14 agregan filas de prueba).
`./demo.sh apagar` · `./demo.sh encender` · `./demo.sh borrar`.
