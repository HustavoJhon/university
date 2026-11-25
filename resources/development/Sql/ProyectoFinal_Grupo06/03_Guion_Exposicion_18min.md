# Guion de Exposición — Grupo 6 (18 minutos)
**Proyecto:** AkilFlow — Plataforma de datos para Transportes Akil S.A.C.
**Curso:** Base de Datos 2 · NRC 39572 · Mg. Oscar Añazco Durand

---

## 0. Distribución de tiempos

| Bloque | Integrante | Tema (criterio) | Tiempo | Acumulado | Diapositivas |
|:-:|---|---|:-:|:-:|:-:|
| 1 | **Sevillanos Tinco, Rodrigo Antonio** | Apertura, empresa, organigramas y DBA (C1) | 3:30 | 0:00 – 3:30 | 1 – 4 |
| 2 | **Espinoza Zea, Andre Sebastián** | OLTP 3FN e indexación con plan de ejecución (C2) | 3:30 | 3:30 – 7:00 | 5 – 6 |
| 3 | **Tumi Huanari, Amy Ariadna** | Seguridad RBAC (4 roles) y cifrado AES_256 (C3) | 3:30 | 7:00 – 10:30 | 7 – 8 |
| 4 | **Condemayta Alvarez, Jessica Alessandra** | Auditoría, Extended Events y DRP (C4) | 4:00 | 10:30 – 14:30 | 9 – 11 |
| 5 | **Ccarita Velasquez, Jhon Gustavo** | DWH, ETL, OLAP, entrega y cierre (C5) | 3:30 | 14:30 – 18:00 | 12 – 15 |

> El bloque 4 tiene 30 s más porque el Criterio 4 vale 2.5 puntos (el de mayor peso). Margen de seguridad: 2 min antes del tope de 20 min.

---

## 1. Preparación (30 min antes de exponer)

**Checklist técnico (lo hace el responsable de la laptop: Jhon Gustavo)**
- [ ] SQL Server 2022 **Developer** + SSMS abiertos como `sysadmin`.
- [ ] Copiar `AkilFlowOperaciones.bak` y `dwh_AkilFlow.bak` a `C:\AkilFlow\Entrega\` y ejecutar `00_Restaurar_Proyecto.sql` con **F5** (< 1 min). **No se ejecutan los scripts 01–05 uno por uno**: el docente pidió restaurar. Así la demo parte del mismo estado que el informe.
- [ ] Ejecutar `02_Consultas_Por_Fase/00_Preparar_Logins_Modo_Mixto.sql` con **F5**. Activa el modo mixto, desbloquea los 5 logins y amplía la auditoría a todas las tablas. Si dice **PENDIENTE**: clic derecho en el servidor → **Reiniciar**, y volver a ejecutarlo hasta que todo diga **OK**.
- [ ] **Dejar abiertas 3 conexiones de rol** (*Conectar → Autenticación de SQL Server*, marcando *Certificado de servidor de confianza*), cada una con su archivo ya cargado en una pestaña:

  | Pestaña | Inicio de sesión | Contraseña | Archivo (`02_Consultas_Por_Fase/`) | Quién lo usa |
  |---|---|---|---|---|
  | Operador | `login_operador` | `Akil#Operador2026` | `02_Rol_Operador.sql` | Amy |
  | Contador | `login_contador` | `Akil#Contador2026` | `05_Rol_Contador.sql` | Amy |
  | Analista BI | `login_analista_bi` | `Akil#AnalistaBI2026` | `06_Rol_Analista_BI.sql` | Jhon Gustavo |

  La barra inferior de cada pestaña muestra el login conectado: así el docente ve que **no** es el administrador.
- [ ] Hacer una prueba en seco de esas 3 pestañas (F5): deben terminar en `14 de 14`, `9 de 9` y `8 de 8 pruebas correctas`. Después **volver a restaurar** (`00_Restaurar_Proyecto.sql` + `00_Preparar_Logins_Modo_Mixto.sql`) para empezar limpio.
- [ ] En la conexión de **Windows (administrador)**, abrir `01_Demo_En_Clase.sql` y `16_Intentos_Denegados.sql`. Cada integrante ejecuta **su bloque** (seleccionar de un encabezado al siguiente + F5): A Andre · B (solo B.2, el cifrado) Amy · C, D y E Jessica · F y G Jhon Gustavo.
- [ ] Zoom del editor al **150 %** (Ctrl + rueda) y la grilla de resultados a fuente 12 (*Herramientas → Opciones → Fuentes y colores → Grid Results*).
- [ ] **Ctrl + M** activado antes del bloque A (plan de ejecución real).
- [ ] Desactivar notificaciones de Windows (Asistente de concentración) y cerrar WhatsApp, correo y Teams.
- [ ] **Plan B:** carpeta con capturas de pantalla de cada demo, por si SSMS falla.
- [ ] Cronómetro visible para el siguiente expositor (celular en la mesa): **seña con la mano a los 30 s del final** de cada bloque.

**Presentación personal (rúbrica B1, 2 pts individuales)**
- Vestimenta **formal**: terno o blazer + camisa; ellas, traje sastre o blusa + pantalón o falda de vestir. Colores sobrios y uniformes en todo el grupo.
- Postura erguida, manos visibles (sin bolsillos ni brazos cruzados) y contacto visual con el docente **y** con el auditorio.
- **No leer las diapositivas**: cada uno lleva a lo sumo una tarjeta con 3 palabras clave.
- Cuando habla un compañero, el resto mira la pantalla o al expositor, nunca el celular.

**Comandos SSMS útiles durante la demo**
| Acción | Atajo |
|---|---|
| Ejecutar solo lo seleccionado | Seleccionar + **F5** |
| Plan de ejecución real | **Ctrl + M** |
| Plan estimado (sin ejecutar) | **Ctrl + L** |
| Mostrar/ocultar resultados | **Ctrl + R** |
| Pestaña Mensajes (STATISTICS IO, Msg 229) | clic en "Mensajes" |
| Cambiar de pestaña (operador → contador → admin) | **Ctrl + Tab** |
| Ver el login de la pestaña actual | barra de estado inferior del editor |

---

## 2. Bloque 1 — Rodrigo Sevillanos · Empresa, organigramas y DBA (0:00 – 3:30)

**[Diapositiva 1 — Portada] (0:00 – 0:30)**
> "Buenos días, Mg. Añazco y compañeros. Somos el Grupo 6 y presentamos **AkilFlow**: la plataforma de datos que diseñamos para Transportes Akil S.A.C., una empresa de carga y encomiendas del nororiente peruano. Hoy les vamos a demostrar en vivo, en SQL Server, cómo resolvimos cuatro necesidades de esta empresa: **rendimiento, seguridad, continuidad y análisis**."

**[Diapositiva 2 — Transportes Akil] (0:30 – 1:30)**
> "Transportes Akil tiene su sede en **Jaén** y opera **6 agencias**: Jaén, Chiclayo, Bagua Grande, Chachapoyas, Moyobamba y Tarapoto, con **10 rutas** de entre 75 y 680 km y una flota de **8 camiones** que suman 58.5 toneladas de capacidad. Sus clientes principales son cooperativas cafeteras, ferreterías y boticas.
> El problema es que hoy todo se registra en Excel y cuadernos. Eso genera seis dolores: datos duplicados, rastreo lento, **DNI y teléfonos de clientes expuestos** (lo que incumple la Ley 29733), nadie sabe quién modificó un registro, **no hay backups** y la gerencia no sabe qué rutas pierden dinero."

**[Diapositiva 3 — Organigramas] (1:30 – 2:15)**
> "A la izquierda, el organigrama general: la Gerencia General con tres gerencias de línea (Operaciones, Administración y Finanzas, y Comercial) y el **Área de TI** como unidad de soporte transversal. A la derecha, el organigrama de TI, donde **proponemos un puesto nuevo, el DBA** (en rojo), que reporta a la Jefatura de TI, supervisa al Analista de BI y coordina con Seguridad e Infraestructura."

**[Diapositiva 4 — Decálogo del DBA] (2:15 – 3:15)**
> "Este DBA tiene diez funciones estratégicas, y cada una está implementada en un script y tiene un indicador. Por ejemplo: la función 2, **optimización**, se mide con 0 consultas de más de 2 segundos; la 4, **protección de datos**, con 100 % de datos personales cifrados; y la 7, **recuperación**, con un RPO de 15 minutos y un RTO de 1 hora. Mis compañeros les van a demostrar cada una."

**Transición (3:15 – 3:30)**
> "Todo empieza con un buen modelo de datos. Le paso la palabra a **Andre**."

### Preguntas probables del docente — Rodrigo
| Pregunta | Respuesta técnica |
|---|---|
| ¿Por qué TI depende de la Gerencia General y no de Administración? | Porque sus sistemas sirven a todas las gerencias (operaciones, rastreo, facturación y BI). Si dependiera de Administración, priorizaría solo lo contable. Así además el Oficial de Seguridad tiene independencia. |
| ¿Cuál es la diferencia entre un DBA y un desarrollador? | El desarrollador construye la aplicación y escribe consultas. El DBA garantiza la **disponibilidad, seguridad, rendimiento y recuperación** de los datos: administra índices, permisos, backups, auditoría y monitoreo. |
| ¿Cómo mediría que el DBA cumple su función de recuperación? | Con un **simulacro trimestral**: restaurar la cadena FULL/DIFF/LOG en la base `_DR` y medir que la pérdida sea ≤ 15 min (RPO) y el tiempo de vuelta ≤ 60 min (RTO). |
| ¿Qué certificación pediría para el puesto? | La *DP-300 Azure Database Administrator Associate* de Microsoft, que cubre SQL Server on-premise y en la nube. |

---

## 3. Bloque 2 — Andre Espinoza · OLTP 3FN e indexación (3:30 – 7:00)

**[Diapositiva 5 — Modelo OLTP] (3:30 – 4:45)**
> "La base transaccional `AkilFlowOperaciones` tiene **7 tablas en tercera forma normal**: empresas, sucursales, usuarios del sistema, **rutas**, vehículos, viajes y encomiendas.
> Respecto de nuestro avance anterior, **separamos la tabla rutas**. Antes, origen y destino eran texto libre dentro de viajes, y la distancia dependía de la ruta y no del viaje: eso es una **dependencia transitiva**, que viola la 3FN. Ahora `rutas` tiene dos FK hacia sucursales y un `CHECK` que impide que el origen sea igual al destino.
> En total hay **53 restricciones**: 7 PK, 10 FK, 9 UNIQUE, 16 CHECK y 11 DEFAULT. Cargamos **697 viajes y 6 487 encomiendas** de casi dos años con estacionalidad real: la campaña del café y la Navidad."

**🖥️ DEMO SSMS — Bloque A de `01_Demo_En_Clase.sql` (4:45 – 6:30)**
1. Con **Ctrl + M** activado, ejecutar el bloque A. La primera consulta fuerza el índice clúster (`WITH (INDEX (PK_encomiendas))`), o sea, lo que haría SQL Server **sin** el índice:
   > "Esta es la pantalla de seguimiento del despachador: encomiendas en tránsito desde el 23 de noviembre. Forzando el índice clúster, el plan muestra un **Clustered Index Scan**: lee toda la tabla para devolver 15 filas (381 lecturas en la base restaurada, porque las filas cifradas son más anchas). La segunda consulta usa nuestro índice: **Index Seek** y **2 lecturas**."
2. **Diapositiva 6** y explicar las 3 etapas medidas al construir la base:
   > "Con un índice simple sobre `estado, fecha_registro` aparece un **Index Seek + Key Lookup**: encuentra las 15 filas, pero salta 15 veces al índice clúster a buscar el peso y el precio, y baja a **32 lecturas**. Al agregar `INCLUDE` con esas columnas, el índice **cubre** la consulta: solo **Index Seek** y **2 lecturas**. Es una **mejora del 99 %**."
3. Mostrar el inventario de índices (última consulta del bloque A).

**Cierre (6:30 – 7:00)**
> "Pusimos `estado` primero porque es una igualdad y `fecha` segundo porque es un rango. También creamos un **índice filtrado** solo para encomiendas pendientes. Ahora que los datos son rápidos, hay que protegerlos: **Amy**."

### Preguntas probables del docente — Andre
| Pregunta | Respuesta técnica |
|---|---|
| ¿Cuál es la diferencia entre un índice clúster y uno no clúster? | El **clúster** ordena físicamente la tabla: su nivel hoja **son** las filas, y solo puede haber uno. El **no clúster** es una estructura aparte (árbol B+) cuya hoja guarda la clave + el puntero (la clave del clúster). Puede haber hasta 999. |
| ¿Por qué la PK es un `INT IDENTITY` clúster y no el `codigo_rastreo`? | Es **estrecha** (4 bytes frente a 20), **única**, **estática** y **creciente**: las inserciones van al final, no hay *page splits* y todos los índices no clúster heredan un puntero pequeño. |
| ¿Qué es un Key Lookup y cuándo es un problema? | Es la búsqueda en el clúster de las columnas que el índice no clúster no tiene. Cuesta 1 lectura aleatoria por fila. Con pocas filas es aceptable, pero con muchas el optimizador prefiere un *Scan* (*tipping point*, ≈ 25–33 % de las páginas). Se elimina con `INCLUDE`. |
| ¿Por qué no indexar todas las columnas? | Cada índice se actualiza en cada `INSERT/UPDATE/DELETE`, ocupa disco y memoria y alarga los backups. Solo se indexan las consultas frecuentes y críticas. |
| ¿Cuál es la diferencia entre `INCLUDE` y poner la columna en la clave? | Las columnas `INCLUDE` solo están en el nivel hoja: no sirven para ordenar ni para buscar, pero tampoco ensanchan los niveles intermedios del árbol ni cuentan para el límite de 900/1700 bytes de la clave. |
| ¿Qué es un índice filtrado? | Un índice con `WHERE` que solo almacena un subconjunto (aquí, ≈ 35 encomiendas `recibida` de 6 485). Es pequeño, barato de mantener y muy selectivo. |

---

## 4. Bloque 3 — Amy Tumi · Seguridad RBAC y cifrado AES_256 (7:00 – 10:30)

**[Diapositiva 7 — 2 capas + 4 roles] (7:00 – 8:00)**
> "La seguridad tiene **dos capas**. En la instancia, el **LOGIN** responde a *¿quién eres?*. En la base, el **USER** responde a *¿qué puedes hacer?*. Sin user, un login autenticado no entra a la base.
> Creamos **4 roles** con el principio de **mínimo privilegio**:
> - **Operador** (despachador): registra encomiendas y cambia su estado, **pero no puede borrar**.
> - **Supervisor** (jefe de operaciones): planifica viajes y flota, pero no borra ni altera la estructura.
> - **Auditor**: lee todo, pero los datos personales solo los ve cifrados.
> - **Contador**: ve montos y costos, nunca nombres ni teléfonos.
> Los permisos nunca se dan a personas, siempre a roles. Y usamos `DENY` explícito, que **gana sobre cualquier GRANT**."

**🖥️ DEMO SSMS — Ingresando como cada rol (8:00 – 9:15)**

1. **Pestaña Operador** (conectada como `login_operador` / `Akil#Operador2026`) → **F5** en `02_Rol_Operador.sql` (≈ 35 s):
   > "Aquí no estoy como administrador: entré con **usuario y contraseña del operador**, como lo haría un despachador de la agencia. La primera tabla lo confirma: login `login_operador`, usuario `usr_operador`, rol `Rol_Operador`."

   Bajar a la **tabla final** (resumen):
   > "El script prueba 14 acciones. **Registrar una encomienda** por el procedimiento: PERMITIDO, y se guardó cifrada sola. **Cambiar el estado**: PERMITIDO. Pero **borrar** da **Msg 229** (el operador no puede borrar evidencia), **bajar el precio** da **Msg 230** (a nivel de **columna**: solo puede tocar `estado` y `viaje_id`), leer los correos del personal o la vista financiera da **Msg 229** y abrir la llave AES da **Msg 15151**. **14 de 14 correctas**: lo esperado coincide con lo que respondió SQL Server."

2. **Pestaña Contador** (conectada como `login_contador` / `Akil#Contador2026`) → **F5** en `05_Rol_Contador.sql` (≈ 25 s):
   > "El contador sí ve ingresos, costos y margen por viaje. Pero si pide `remitente_cif` o hace un `SELECT *` de encomiendas, recibe **Msg 230**: nunca ve datos personales. **9 de 9 correctas**."

3. *(Si sobra tiempo)* Pestaña de **administrador** → `07_Matriz_Permisos_y_REVOKE.sql`, consulta 7.2:
   > "Esta matriz resume los 4 roles: SÍ o no por tabla y permiso, calculado por SQL Server, no escrito a mano."

> 💡 Si el docente pide probar otro rol, se abre una conexión nueva con las credenciales de la **sección 9** y se ejecuta su archivo (03 supervisor, 04 auditor).

**[Diapositiva 8 — Cifrado] (9:15 – 10:15)**
> "Para los datos personales usamos la **jerarquía completa**: la Service Master Key de la instancia protege la **Database Master Key**, esta protege al **certificado** y el certificado protege la **llave simétrica AES de 256 bits**.
> Ciframos nombre, DNI o RUC y teléfono de remitentes y destinatarios en columnas `VARBINARY(256)`. Lo más importante: **validamos** dentro de una transacción que todo se descifrara bien, luego **eliminamos las columnas en texto plano** e hicimos un `REBUILD`, porque `DROP COLUMN` deja los bytes en las páginas.
> *(Pestaña admin, B.2 de `01_Demo_En_Clase.sql`)* "Así se ve la columna **sin la llave**: `0x004F26...`. Y así **con la llave abierta**: el nombre legible. En la prueba del operador vieron que él tampoco puede abrir la llave (**Msg 15151**): para registrar usa un procedimiento `EXECUTE AS OWNER` que cifra dentro del servidor. Un auditor que intenta descifrar obtiene `NULL`."

> *(Verbal, sin demo)* "Y la diferencia entre **REVOKE y DENY**: `REVOKE` retira lo concedido y deja el permiso neutro; `DENY` lo prohíbe aunque otro rol lo conceda. Está demostrado en el archivo 07."

**Transición (10:15 – 10:30)**
> "Ya sabemos quién puede hacer qué. Ahora, **¿cómo sabemos lo que realmente hicieron y cómo sobrevivimos a un desastre?** Jessica."

### Preguntas probables del docente — Amy
| Pregunta | Respuesta técnica |
|---|---|
| ¿Cuál es la diferencia entre `REVOKE` y `DENY`? | `REVOKE` **elimina** un GRANT o DENY previo y deja el permiso en estado neutro (podría heredarse de otro rol). `DENY` **prohíbe** explícitamente y prevalece sobre cualquier GRANT heredado. |
| ¿Por qué Msg 229 en un caso y Msg 230 en otro? | El 229 es la denegación a nivel de **objeto** (tabla/SP). El 230 es la denegación a nivel de **columna** (`GRANT UPDATE (estado, viaje_id)` no incluye `precio_envio`). |
| ¿Por qué cifrado simétrico y no asimétrico directo? | AES es cientos de veces más rápido para miles de filas. El certificado asimétrico solo protege la llave AES (*envelope encryption*). |
| ¿Cuál es la diferencia con TDE y Always Encrypted? | **TDE** cifra los archivos en disco, pero quien tiene `SELECT` ve el texto plano. **Always Encrypted** cifra en el cliente y ni el DBA ve los datos, pero obliga a cambiar el driver. **El cifrado de columnas** protege campos puntuales dentro del servidor y se combina con RBAC. |
| ¿Por qué el operador no recibe permiso sobre la llave? | Por mínimo privilegio. Usa un SP `WITH EXECUTE AS OWNER` que abre y cierra la llave internamente, y el SP está auditado. |
| ¿Cómo prueban que de verdad entraron como el rol y no como administrador? | La primera tabla muestra `SUSER_SNAME()` = `login_operador`, `USER_NAME()` = `usr_operador` e `IS_ROLEMEMBER('Rol_Operador')` = 1. La barra inferior de SSMS también muestra el login. Además, un administrador **no** recibiría Msg 229. |
| ¿Por qué no salen los errores en rojo? | Cada prueba va dentro de `TRY/CATCH` y el error se guarda en la tabla resumen (`mensaje_sql_server`), para que el script siga y muestre todas. Es el **mismo** error de SQL Server: si lo escribo suelto en una consulta nueva (`DELETE FROM dbo.encomiendas WHERE encomienda_id = -1`), sale en rojo con el Msg 229. |
| ¿Qué pasa si el login existe pero no tiene usuario en la base? | Se autentica en la instancia (capa 1), pero no entra a la base (capa 2): **Msg 916**. Por eso el analista BI no puede leer `AkilFlowOperaciones`. |
| ¿`EXECUTE AS LOGIN` o `EXECUTE AS USER`? | `LOGIN` suplanta en la instancia y valida las dos capas. `USER` solo suplanta dentro de una base. Los archivos de rol usan `EXECUTE AS LOGIN` **solo** si se ejecutan desde el administrador; si se entra con el login del rol, no suplantan nada. |
| ¿Cuántos bytes ocupa un dato cifrado? | Encabezado (≈ 20 B) + IV (16 B) + texto con relleno a bloques de 16 B. Por eso limitamos los parámetros a `NVARCHAR(80)` (160 B), para no pasar de 256. |
| ¿Por qué el `REBUILD` después del `DROP COLUMN`? | `DROP COLUMN` solo cambia los metadatos; los bytes del texto plano siguen en las páginas de datos y podrían leerse con `DBCC PAGE`. El *rebuild* reescribe las páginas sin ellos. |

---

## 5. Bloque 4 — Jessica Condemayta · Auditoría, Extended Events y DRP (10:30 – 14:30)

**[Diapositiva 9 — SQL Server Audit] (10:30 – 11:30)**
> "La auditoría tiene dos niveles. En `master`, el **Server Audit** define el destino: archivos `.sqlaudit` en `C:\AkilFlow\Audit`, escritos de forma asíncrona cada segundo. En la base, la **Database Audit Specification** dice qué se audita: `SELECT, INSERT, UPDATE, DELETE` sobre encomiendas y viajes, quién ejecuta el procedimiento que descifra y cualquier cambio de permisos."

**🖥️ DEMO SSMS — ¿Quién intentó entrar a donde no tenía permiso? (11:30 – 12:15)**

Pestaña de **administrador** → **F5** en `16_Intentos_Denegados.sql`:
> "Hace tres minutos Amy entró como operador y como contador e intentó cosas prohibidas. **Todo quedó registrado.** En 16.2 vemos cada intento denegado: la hora, el login `login_operador`, la tabla `encomiendas`, la acción `DELETE` y la **sentencia exacta** que escribió. En 16.3 se ve el resumen por usuario, en 16.4 qué tablas intentaron usar y quién, y en 16.5 los inicios de sesión con contraseña incorrecta. Eso es **no repudio**: un trigger no puede capturar ni los SELECT ni los intentos fallidos."

> Lo mismo sin consultas: *Seguridad → Auditorías → Audit_AkilFlow → clic derecho → Ver registros de auditoría*, filtrando *Correcto = False*.
> *(Plan B: el bloque C de `01_Demo_En_Clase.sql` muestra el `UPDATE` y el `DL` con `succeeded = 0`.)*

**[Diapositiva 10 — Extended Events] (12:15 – 12:45)**
> *(Bloque D)* "Para el monitoreo creamos la sesión `XE_ConsultasLentas_AkilFlow` con el filtro `duration > 2000000`. Está en **microsegundos**, o sea, 2 segundos. El conteo rápido no se registró y el `WAITFOR` de 3 segundos sí, con su duración, usuario y aplicación. El filtro se evalúa antes de escribir, así que el costo es mínimo."

**[Diapositiva 11 — DRP] (12:45 – 14:15)**
> "Para el plan de recuperación pusimos la base en **RECOVERY FULL** y creamos un certificado de respaldo en `master`. La cadena es: **FULL** semanal, **DIFFERENTIAL** diario y **LOG cada 15 minutos**, todos cifrados con **AES_256**, con `CHECKSUM` y verificados.
> *(Bloque E: E.1–E.3 generan los tres respaldos cifrados)*
> Luego simulamos el desastre: restauramos el **FULL y el DIFF con NORECOVERY** (la base queda en *Restoring* esperando más respaldos) y el **LOG con RECOVERY**, que la pone en línea. *(E.4 y E.5)* La base pasa de *RESTORING* a *ONLINE* y desciframos la encomienda AK-DRP-POSTFULL, que se recuperó **gracias al DIFF**, y la AK-DRP-POSTDIFF, **gracias al LOG**. En el informe está la validación completa: 6 487 filas iguales y `CHECKDB` sin errores.
> Aplicamos la **regla 3-2-1**: 3 copias, en 2 medios (disco y NAS) y 1 fuera del sitio (Azure o la agencia Chiclayo). **RPO de 15 minutos**: como mucho perdemos ~6 encomiendas, que se re-digitan desde la guía física. **RTO de 60 minutos**: 50 calculados más holgura."

**Transición (14:15 – 14:30)**
> "Los datos están seguros y respaldados. Ahora, **¿qué nos dicen para decidir mejor?** Jhon Gustavo."

### Preguntas probables del docente — Jessica
| Pregunta | Respuesta técnica |
|---|---|
| ¿Qué pasa si restauro el FULL con `RECOVERY`? | La base se abre, se hace *rollback* de las transacciones incompletas y la cadena **se rompe**: ya no se puede aplicar ni el DIFF ni el LOG (error 4306). Habría que empezar de nuevo. |
| ¿Cuál es la diferencia entre DIFF y LOG? | El **DIFF** copia las extensiones modificadas desde el **último FULL** (es acumulativo; solo se aplica el último). El **LOG** copia las transacciones desde el **último LOG** (son secuenciales y se aplican todos en orden) y permite restaurar a un punto en el tiempo (`STOPAT`). |
| ¿Por qué RECOVERY FULL? | En `SIMPLE` el log se trunca en cada checkpoint y no existe `BACKUP LOG`, así que el RPO sería igual a la frecuencia del DIFF (24 h). |
| ¿Qué pasa si pierdo el certificado de respaldo? | Los `.bak` cifrados son **irrecuperables**. Por eso exportamos el `.cer` y el `.pvk` con `BACKUP CERTIFICATE` y los guardamos separados de los backups. |
| ¿Por qué en la base DR hiciste `OPEN MASTER KEY ... ALTER MASTER KEY ADD ENCRYPTION BY SERVICE MASTER KEY`? | La DMK restaurada quedó cifrada con la Service Master Key "de origen". La abrimos con su contraseña y la volvemos a vincular a la SMK de esta instancia para que el certificado pueda abrir la llave AES. |
| ¿Qué es un *tail-log backup*? | Un último `BACKUP LOG ... WITH NO_TRUNCATE` hecho después del fallo, si el archivo de log sobrevive. Lleva el RPO a casi 0. |
| ¿Extended Events o Profiler? | Profiler está obsoleto: filtra después de capturar y tiene alto costo. XE filtra en el origen con predicados y su impacto es mínimo. |
| ¿La auditoría registra un intento aunque el script lo capture con TRY/CATCH? | Sí. La auditoría se dispara en la **comprobación de permisos**, antes de que el error llegue al cliente. Por eso aparecen los intentos de la demo de Amy. |
| ¿Por qué ampliaron la auditoría con `00_Preparar_Logins_Modo_Mixto.sql`? | La especificación original vigilaba `encomiendas`, `viajes` y el SP de descifrado. La ampliamos a `usuarios_sistema`, la vista financiera, sucursales, rutas, vehículos y todo el esquema del DWH, para registrar **cualquier** intento denegado. |
| ¿Por qué `ON_FAILURE = CONTINUE`? | Para que una falla del disco de auditoría no detenga la operación de las agencias. En entornos regulados (bancos) se usaría `SHUTDOWN`. |

---

## 6. Bloque 5 — Jhon Gustavo Ccarita · DWH, ETL y OLAP + cierre (14:30 – 18:00)

**[Diapositiva 12 — Arquitectura DWH] (14:30 – 15:30)**
> "Para el análisis construimos `dwh_AkilFlow` con **tres capas**. Primero, una **zona Staging**, que se vacía y se recarga en cada corrida, donde limpiamos con `LTRIM/RTRIM/UPPER` y **prorrateamos el costo del viaje según el peso** de cada encomienda. Segundo, un **esquema estrella** con 5 dimensiones (tiempo, sucursal, ruta, vehículo y estado) que usan **claves subrogadas** propias del DWH, y una tabla de hechos con métricas aditivas: cantidad, peso, ingreso, costo y margen. Tercero, una **vista** para Power BI.
> El ETL es un procedimiento con `MERGE`: si la fila existe y cambió la actualiza; si no existe, la inserta. Se programa como **Job del SQL Server Agent a las 2 a. m.**"

**🖥️ DEMO SSMS — Bloque F (15:30 – 16:15)**
> "Un viaje en curso llega a destino y corremos el ETL. Las filas que no cumplen las reglas de calidad van a la tabla de cuarentena `etl_errores`. La conciliación cuadra al centavo: **6 451 filas y S/ 325 059.90** tanto en Staging como en Fact. Y en la carga incremental, cuando un viaje se completó, el ETL **insertó 0 y actualizó solo 7 filas**: no recarga todo."

**[Diapositiva 13 — Hallazgos OLAP] (16:15 – 17:00)**
> *(Bloque G)* "Con `RANK()` y `SUM() OVER` encontramos una **paradoja**: la ruta **Tarapoto–Chiclayo** factura el 18 % del total, pero tiene **margen negativo**. Las rutas cortas de Bagua Grande y Jaén superan el 50 % de margen.
> Con `LAG` vemos que **mayo sube un 47 %** por la campaña del café y **diciembre un 71 %**. Con `ROLLUP` tenemos subtotales por región y con `CUBE` vemos que las unidades livianas pierden dinero en el primer y cuarto trimestre.
> Por último, la seguridad del DWH. *(Pestaña **Analista BI**, conectada como `login_analista_bi` / `Akil#AnalistaBI2026` → **F5** en `06_Rol_Analista_BI.sql`)* El analista lee la vista BI y el esquema estrella, pero el Staging y la bitácora del ETL le dan **Msg 229**, y si intenta leer la base operativa recibe **Msg 916**, porque ni siquiera tiene usuario allí. **8 de 8 correctas**: solo publica datos conciliados."

**[Diapositiva 14 — Entrega por restauración] (17:00 – 17:20)**
> "Como pidió el profesor, entregamos **dos respaldos y un solo script**. El script crea lo que no viaja en un .bak: los logins con el mismo SID, la auditoría con el mismo GUID, re-vincula la llave maestra para que el cifrado funcione en otra PC y crea Extended Events y el Job. Lo probamos en una instancia limpia de SQL Server 2022."

**[Diapositiva 15 — Conclusiones] (17:20 – 18:00)**
> "En resumen: **rendimiento** (99 % menos lecturas), **seguridad** (4 roles y 0 datos personales en texto plano), **continuidad** (RPO 15 min, RTO 1 h, restauración probada) y **decisiones** (sabemos qué ruta pierde dinero y cuándo reforzar la flota).
> Recomendamos reajustar la tarifa de Tarapoto–Chiclayo y, como siguiente paso, Always On con una réplica en Chiclayo. **Muchas gracias. Quedamos atentos a sus preguntas.**"

### Preguntas probables del docente — Jhon Gustavo
| Pregunta | Respuesta técnica |
|---|---|
| ¿Por qué claves subrogadas y no los IDs de la OLTP? | Aíslan el DWH de los cambios o la reutilización de IDs operacionales, permiten historial (SCD Tipo 2), integran fuentes con claves distintas y los JOIN sobre `INT` son más rápidos. La clave de negocio queda como `UNIQUE` para el `MERGE`. |
| ¿Cuál es el grano de la tabla de hechos? | **Una fila por encomienda transportada.** Por eso hay que prorratear el costo del viaje: el costo pertenece a un grano superior. |
| ¿Qué es una métrica aditiva? | Una que se puede sumar por **todas** las dimensiones (ingreso, peso, costo, margen). Un porcentaje de margen **no** es aditivo: se recalcula como `SUM(margen)/SUM(ingreso)`. |
| ¿Cuál es la diferencia entre `ROLLUP` y `CUBE`? | `ROLLUP(a,b,c)` genera subtotales **jerárquicos**: (a,b,c), (a,b), (a), (). `CUBE(a,b)` genera **todas** las combinaciones: (a,b), (a), (b), (). `GROUPING()` distingue un NULL de subtotal de un NULL real. |
| ¿Cuál es la diferencia entre `RANK`, `DENSE_RANK` y `ROW_NUMBER`? | Con empates, `RANK` deja huecos (1,1,3), `DENSE_RANK` no deja huecos (1,1,2) y `ROW_NUMBER` siempre numera de forma única (1,2,3). |
| ¿Qué hace el `MERGE` del ETL? | Compara origen y destino por la clave de negocio: `WHEN MATCHED AND cambió → UPDATE` (SCD Tipo 1), `WHEN NOT MATCHED BY TARGET → INSERT`. Con `OUTPUT $action` contamos las inserciones y actualizaciones para la bitácora. |
| ¿Por qué SCD Tipo 1? | Los atributos (marca, distancia) casi no cambian y no tienen valor histórico. Si se necesitara saber a qué agencia pertenecía un vehículo en el pasado, usaríamos Tipo 2 con `fecha_inicio/fecha_fin`. |
| ¿Para qué sirve el miembro "Desconocido" con SK −1? | Para no perder hechos si una dimensión llega incompleta: el ingreso se reporta como "N/D" en vez de descartarse. En nuestra carga hubo 0 casos. |

---

## 7. Preguntas transversales (cualquier integrante debe poder responder)

| Pregunta | Respuesta |
|---|---|
| ¿Qué es OLTP frente a OLAP? | **OLTP**: muchas transacciones cortas, normalizado (3FN), optimizado para escribir. **OLAP**: pocas consultas grandes, desnormalizado (estrella), optimizado para leer y agregar. |
| ¿Por qué tres bases separadas? | Las cargas analíticas pesadas no deben bloquear la operación (OLTP ≠ DWH), y la base DR prueba la restauración sin tocar producción. |
| ¿Por qué entregan un .bak y no los scripts? | Así lo pidió el docente: se restaura en < 1 min con `00_Restaurar_Proyecto.sql`. Los scripts 01–06 se entregan como código fuente y son **idempotentes**. |
| ¿Por qué el .bak de entrega no está cifrado? | Un .bak cifrado solo se restaura donde exista su certificado. Los datos personales igual viajan cifrados con AES_256 y la DMK pide contraseña. El respaldo cifrado se demuestra en el bloque E. |
| ¿Qué cambia en Windows frente a Linux? | Nada en el T-SQL. Las rutas `C:\AkilFlow\...` se crean con `xp_create_subdir` bajo la cuenta del servicio. Para usar los logins SQL hay que activar el modo de autenticación **mixto**: lo hace `00_Preparar_Logins_Modo_Mixto.sql` (requiere un reinicio del servicio). |
| ¿Cómo entro con un rol si el login dice *Login failed (18456)*? | Falta el modo mixto o el reinicio, o el login quedó bloqueado por contraseñas erróneas. `00_Preparar_Logins_Modo_Mixto.sql` arregla las tres cosas. |

---

## 8. Plan de contingencia durante la exposición

| Problema | Acción inmediata | Responsable |
|---|---|---|
| SSMS se cuelga o la demo da error | "Les mostramos la evidencia capturada" → diapositiva con la captura (anexo) | Expositor de turno |
| La conexión del rol falla al momento (*Login failed*, certificado) | Ejecutar el mismo archivo desde la pestaña de **administrador**: se convierte solo en el rol (`EXECUTE AS LOGIN`) y da el mismo resultado | Amy / Jhon Gustavo |
| El resumen de un rol muestra `✘ REVISAR` | Se ejecutó con otro login o sin preparar: verificar la barra inferior y ejecutar `00_Preparar_Logins_Modo_Mixto.sql` | Jhon Gustavo |
| Se agotan los 3:30 del bloque | Saltar a la frase de transición; el detalle está en el informe | Expositor de turno |
| Un integrante no se presenta | Rodrigo ↔ Jhon Gustavo y Andre ↔ Amy se cubren mutuamente (ensayar el bloque del compañero) | — |
| El docente interrumpe con una pregunta | Responder en ≤ 30 s y retomar ("...como decía, ...") | Expositor de turno |

**Ensayos recomendados:** 2 ensayos completos con cronómetro, al menos uno con la vestimenta formal y la laptop real.

---

## 9. Demostración con cada rol (si el docente lo pide, o después de exponer)

Todos los archivos están en `00_ENTREGA_Restaurar/02_Consultas_Por_Fase/`. Antes de empezar: `00_Preparar_Logins_Modo_Mixto.sql`, que debe decir **OK**.

**Ingresar:** *Conectar → Motor de base de datos → **Autenticación de SQL Server*** → login y contraseña → marcar *Certificado de servidor de confianza* → abrir el archivo → **F5**.

| Rol | Inicio de sesión | Contraseña | Archivo | Debe terminar en |
|---|---|---|---|---|
| Operador | `login_operador` | `Akil#Operador2026` | `02_Rol_Operador.sql` | 14 de 14 correctas |
| Supervisor | `login_supervisor` | `Akil#Supervisor2026` | `03_Rol_Supervisor.sql` | 12 de 12 correctas |
| Auditor | `login_auditor` | `Akil#Auditor2026` | `04_Rol_Auditor.sql` | 9 de 9 correctas |
| Contador | `login_contador` | `Akil#Contador2026` | `05_Rol_Contador.sql` | 9 de 9 correctas |
| Analista BI | `login_analista_bi` | `Akil#AnalistaBI2026` | `06_Rol_Analista_BI.sql` | 8 de 8 correctas |

**Qué decir de cada uno (una frase):**
- **Operador:** "Registra y cambia estados, pero no borra (229), no toca precios (230), no ve personal ni finanzas (229) y no abre la llave (15151)."
- **Supervisor:** "Lee todo y ve datos descifrados, planifica flota y viajes, pero nunca borra (229) ni altera tablas (1088)."
- **Auditor:** "Lo lee todo, pero los datos personales solo en binario; no descifra (15151), no ejecuta SP y no escribe (229)."
- **Contador:** "Ve montos y márgenes; las columnas personales le dan 230 y el personal 229."
- **Analista BI:** "Vista BI y estrella sí; staging, ETL y escritura no (229); a la base operativa ni entra (916)."

**Prueba a mano (si el docente quiere escribir él mismo),** en *Nueva consulta* con la conexión del rol:

```sql
SELECT SUSER_NAME() AS login, USER_NAME() AS usuario;            -- ¿quién soy?
DELETE FROM dbo.encomiendas WHERE encomienda_id = -1;            -- Msg 229 en todos los roles
UPDATE dbo.encomiendas SET precio_envio = 0 WHERE encomienda_id = -1;  -- operador / supervisor: Msg 230
SELECT TOP 5 remitente_cif FROM dbo.encomiendas;                 -- contador: Msg 230 · auditor: binario
EXEC dbo.usp_consultar_encomienda 'AK20261125PEND01';            -- operador / supervisor: descifrado · auditor / contador: Msg 229
```

**Después:** con la conexión de administrador, `16_Intentos_Denegados.sql` muestra todo lo que se intentó sin permiso, con login, tabla, hora y sentencia.

**Resto de evidencias (conexión de administrador, Ctrl + T, F5):** `01` tablas · `07` matriz de permisos y REVOKE · `08` cifrado · `09` índices · `10` auditoría · `11` Extended Events · `12` backups FULL/DIFF/LOG cifrados con ruta y tamaño · `13` restauración DRP · `14` ETL · `15` OLAP. El detalle está en `MANUAL_DE_USO.md` y en el README de la carpeta.
