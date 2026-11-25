# Consultas de demostración por fase (Windows + SSMS)

Sirven para demostrar, durante o después de la exposición, que todo lo explicado funciona.
Se ejecutan **después** de restaurar con `00_Restaurar_Proyecto.sql`.

## Antes de empezar

1. Ya se ejecutó `00_ENTREGA_Restaurar/00_Restaurar_Proyecto.sql` y terminó con `RESTAURACIÓN COMPLETADA`.
2. SSMS está conectado como **sysadmin** (sirve la autenticación de Windows).
3. Pulsar **Ctrl + T** (*Resultados en texto*): así los títulos `=== ... ===`, las tablas y los errores
   salen en orden en una sola pestaña. Con **Ctrl + D** se vuelve a la cuadrícula.
4. Abrir cada archivo y pulsar **F5**. Cada archivo es independiente y se ejecuta completo.

## Orden

| # | Archivo | Qué demuestra |
|---|---|---|
| 01 | `01_Ver_Bases_y_Tablas.sql` | Bases restauradas ONLINE, tablas con número de filas, columnas cifradas (VARBINARY), muestra de datos y usuarios ↔ roles (0 huérfanos) |
| 02 | `02_Rol_Operador.sql` | ✔ registra una encomienda (cifrada por el SP) y cambia su estado · ✘ DELETE, INSERT directo, cambio de precio, personal, vista financiera, llave AES, DDL |
| 03 | `03_Rol_Supervisor.sql` | ✔ lee todo, ve datos descifrados, actualiza flota · ✘ DELETE, ALTER TABLE, cambio de precio |
| 04 | `04_Rol_Auditor.sql` | ✔ lee todo, pero los datos personales solo en binario · ✘ llave, SP, INSERT, UPDATE, DELETE |
| 05 | `05_Rol_Contador.sql` | ✔ vista financiera y montos · ✘ columnas cifradas, personal, escritura, SP |
| 06 | `06_Rol_Analista_BI.sql` | ✔ vista BI y esquema estrella · ✘ staging, bitácora ETL, ejecutar ETL, base OLTP (Msg 916) |
| 07 | `07_Matriz_Permisos_y_REVOKE.sql` | Tabla SÍ/no de los 4 roles por objeto y permiso; GRANT/DENY declarados; REVOKE vs DENY en vivo |
| 08 | `08_Cifrado_AES256.sql` | Jerarquía SMK → DMK → certificado → llave AES_256; binario vs texto descifrado; cifrado no determinista |
| 09 | `09_Indices_Plan_Ejecucion.sql` | Plan Clustered Index **Scan** → Index **Seek**; lecturas lógicas 381 → 5 (pestaña Mensajes). Para el plan gráfico: Ctrl + M |
| 10 | `10_Auditoria.sql` | Configuración de la auditoría, UPDATE permitido y DELETE denegado registrados, GRANT/REVOKE e inicios de sesión fallidos |
| 11 | `11_Extended_Events.sql` | La consulta rápida no se captura; la de 3 s sí |
| 12 | `12_Backups_FULL_DIFF_LOG.sql` | Crea **Demo_FULL.bak**, **Demo_DIFF.bak** y **Demo_LOG.trn** cifrados AES_256 en `C:\AkilFlow\Backups\`; muestra ruta, tamaño, compresión, cifrado, LSN y `RESTORE VERIFYONLY` |
| 13 | `13_Restaurar_DRP.sql` | Simulacro: restaura FULL → DIFF → LOG en `AkilFlowOperaciones_DR` (RESTORING → ONLINE) y comprueba que no se perdió nada |
| 14 | `14_ETL_Incremental.sql` | Nueva encomienda en la OLTP → ETL → aparece en `fact_encomiendas`; conciliación staging = fact; cuarentena |
| 15 | `15_Consultas_OLAP.sql` | ROLLUP, CUBE, RANK, LAG (mes a mes), SLICE y DICE |

## Cómo se prueban los roles (archivos 02 a 06)

Cada archivo empieza con `EXECUTE AS LOGIN = N'login_xxx'` y termina con `REVERT`. Desde la conexión
sysadmin, SQL Server se comporta exactamente como si hubiera entrado ese login: valida el login
(capa 1), su usuario en la base (capa 2) y los permisos de su rol. La última consulta,
`sesion_restaurada`, debe mostrar de nuevo su usuario.

Si se ejecuta **por partes**, se debe ejecutar primero el bloque del `EXECUTE AS` y al final el
`REVERT`. Si se olvida el REVERT, basta con ejecutar `REVERT;` o cerrar la pestaña.

**Alternativa con el login real** (la instancia debe estar en modo mixto): *Conectar → Autenticación
de SQL Server* con las credenciales de la tabla y ejecutar el archivo desde `¿Quién soy?`, sin las
líneas `EXECUTE AS` y `REVERT`.

| Login | Contraseña | Base |
|---|---|---|
| `login_operador` | `Akil#Operador2026` | AkilFlowOperaciones |
| `login_supervisor` | `Akil#Supervisor2026` | AkilFlowOperaciones |
| `login_auditor` | `Akil#Auditor2026` | AkilFlowOperaciones |
| `login_contador` | `Akil#Contador2026` | AkilFlowOperaciones |
| `login_analista_bi` | `Akil#AnalistaBI2026` | dwh_AkilFlow |

Antes de cada prueba aparece una etiqueta `(OK n) ... PERMITIDO` o `(DENEGADO n) ... ESPERADO: Msg xxx`.
**Los errores en rojo de los archivos 02 a 07 son intencionales.**

| Error | Significado |
|---|---|
| Msg 229 | Permiso denegado sobre el objeto (tabla, vista, SP) |
| Msg 230 | Permiso denegado sobre una columna |
| Msg 262 | No puede crear objetos (DDL) |
| Msg 1088 | No puede alterar la tabla (DENY ALTER) |
| Msg 916 | El login no tiene usuario en esa base (capa 2) |
| Msg 15151 | No puede ver ni abrir la llave AES_256 |

## Archivos que se generan en disco

| Carpeta | Contenido | Lo crea |
|---|---|---|
| `C:\AkilFlow\Backups\` | `Demo_FULL.bak`, `Demo_DIFF.bak`, `Demo_LOG.trn` | 12 |
| `C:\AkilFlow\DR\` | `.mdf` y `.ldf` de `AkilFlowOperaciones_DR` | 13 |
| `C:\AkilFlow\Audit\` | `*.sqlaudit` (bitácora de auditoría) | restauración |
| `C:\AkilFlow\XEvents\` | `*.xel` (consultas lentas) | restauración |

Se pueden mostrar abriendo la carpeta en el Explorador de archivos. La consulta 12.5 también las
lista desde SQL.

## Consejos

- Para el login fallido de la consulta 10.6: antes de ejecutar el archivo 10, intente conectarse en SSMS como
  `login_operador` con una contraseña incorrecta.
- El archivo 13 necesita que antes se haya ejecutado el 12.
- Los archivos 02, 10, 12 y 14 agregan filas de prueba. Para volver al estado original, ejecute de nuevo
  `00_Restaurar_Proyecto.sql`.
- Si sale *Operating system error 5* al hacer los backups, la cuenta del servicio de SQL Server no puede escribir
  en `C:\AkilFlow\Backups`. Vuelva a ejecutar el PASO 1 de la restauración o dé permisos a esa carpeta.

Probado de principio a fin sobre una restauración limpia en SQL Server 2022 (16.x).
