# Estructura de Diapositivas — AkilFlow (14 slides · 18 min)

**Estilo visual sugerido** (Canva / PowerPoint / Gamma)
- **Paleta:** azul petróleo `#0B3C5D` (fondo de portada y títulos) · blanco `#FFFFFF` · gris `#F2F4F7` (fondos) · acento ámbar `#F2A541` (cifras clave) · rojo `#C0392B` (errores/riesgos) · verde `#2E8B57` (logros).
- **Tipografía:** títulos *Montserrat Bold*; cuerpo *Inter* o *Segoe UI*; código *Cascadia Code / Consolas*.
- **Regla de oro:** máximo **15 palabras de texto corrido** por diapositiva; el resto son cifras, íconos, diagramas y capturas de SSMS.
- **Pie fijo:** `Grupo 6 · Base de Datos 2 · NRC 39572` + número de diapositiva.
- Las capturas de SSMS deben tomarse con zoom al 150 % y recortarse solo a la zona relevante (resultado o mensaje de error).

---

### Diapositiva 1 — Portada · *Rodrigo* · 0:00
- **Título:** AkilFlow
- **Subtítulo:** Plataforma de datos segura, resiliente y analítica para Transportes Akil S.A.C.
- **Visual:** fondo de un camión en una carretera de la selva alta (imagen libre de derechos) con una capa azul al 80 %; logo de la Universidad Continental.
- **Texto inferior:** Base de Datos 2 · NRC 39572 · Mg. Oscar Añazco Durand · Grupo 6 · 5 nombres en una fila.

### Diapositiva 2 — Transportes Akil en cifras · *Rodrigo* · 0:30
- **Visual principal:** mapa esquemático del norte del Perú con 6 puntos (JAE, CIX, BGR, CHA, MOY, TPP) unidos por 10 líneas (rutas).
- **4 tarjetas KPI** (número grande en ámbar):
  `6 agencias` · `10 rutas` · `8 camiones / 58.5 t` · `+3 200 encomiendas/año`
- **Franja inferior roja, "Hoy":** 📄 Excel y cuadernos · 🔓 DNI expuestos · 💾 sin backups · ❓ rutas sin rentabilidad conocida.

### Diapositiva 3 — Organigramas · *Rodrigo* · 1:30
- **Izquierda (60 %):** organigrama general (Gerencia General → Operaciones / Administración y Finanzas / Comercial / **TI** resaltado).
- **Derecha (40 %):** organigrama de TI con la caja **DBA en rojo** y la etiqueta "Puesto propuesto".
- *Fuente:* exportar los diagramas Mermaid del informe (§2.2 y §2.3) en mermaid.live → PNG.

### Diapositiva 4 — Decálogo del DBA · *Rodrigo* · 2:15
- **Visual:** cuadrícula de 2 × 5 con un ícono y 2–3 palabras por función:
  1 Modelo de datos · 2 Rendimiento · 3 RBAC · 4 Cifrado PII · 5 Auditoría · 6 Monitoreo · 7 Backups/DRP · 8 Integridad · 9 BI · 10 Automatización
- **Franja inferior:** "Cada función = 1 script + 1 KPI" con 3 ejemplos: `0 consultas > 2 s` · `100 % PII cifrada` · `RPO 15 min`.

### Diapositiva 5 — Modelo OLTP en 3FN · *Andre* · 3:30
- **Visual principal:** diagrama ER de las 7 tablas (informe §3.1), con `rutas` resaltada.
- **Lateral derecho, 3 cifras:** `7 tablas` · `53 restricciones` · `6 485 encomiendas`
- **Callout:** "rutas separada → elimina una dependencia transitiva (3FN)".

### Diapositiva 6 — Índices: 189 → 2 lecturas · *Andre* · 4:45
- **Visual principal:** 3 columnas, cada una con una captura del plan de SSMS:
  | 🔴 ANTES | 🟠 INTERMEDIO | 🟢 DESPUÉS |
  |---|---|---|
  | Clustered Index Scan | Index Seek + Key Lookup | Index Seek (covering) |
  | **189** lecturas | **32** lecturas | **2** lecturas |
- **Gráfico de barras horizontal** con las 3 cifras y la etiqueta **"−99 %"** en verde, grande.
- **Pie:** `CREATE INDEX ... (estado, fecha_registro) INCLUDE (codigo_rastreo, peso_kg, precio_envio)`

### Diapositiva 7 — Seguridad en 2 capas + 4 roles · *Amy* · 7:00
- **Visual superior:** flujo `LOGIN (instancia)` → `USER (base)` → `ROL` → `objetos` (informe §4.1).
- **Visual inferior:** matriz semáforo de 4 columnas (Operador, Supervisor, Auditor, Contador) × 5 filas (SELECT, INSERT, UPDATE, DELETE, Ver PII) con ✅ / ⚠️ / ⛔.
- **Captura** del mensaje rojo `Msg 229 ... DELETE permission was denied`.

### Diapositiva 8 — Cifrado AES_256 · *Amy* · 9:15
- **Visual izquierdo:** pirámide de 4 niveles → SMK → DMK → Certificado → **Symmetric Key AES_256**.
- **Visual derecho:** "antes / después" de la misma fila:
  `Luis Cruz Llontop | 40112648` → `0x000E4F5613C6B84F…`
- **3 viñetas cortas:** Validación round-trip ✔ · Texto plano eliminado + REBUILD ✔ · Auditor: Msg 15151 ✔

### Diapositiva 9 — SQL Server Audit · *Jessica* · 10:30
- **Visual:** diagrama Server Audit (master) ← Database Audit Specification → archivo `.sqlaudit`.
- **Captura** de `sys.fn_get_audit_file` con la fila `DL | succeeded = 0 | usr_operador` resaltada con un recuadro rojo.
- **Lema:** "Incluso el intento queda registrado → no repudio".

### Diapositiva 10 — Extended Events > 2 s · *Jessica* · 12:15
- **Visual:** cronómetro con "2 s = 2 000 000 µs".
- **Mini tabla:** `SELECT COUNT(*)` → ❌ no se captura · `WAITFOR 3 s` → ✅ capturado (3.00 s).
- **Código (3 líneas):** `WHERE [duration] > (2000000) AND database_name = 'AkilFlowOperaciones'`

### Diapositiva 11 — Plan DRP · *Jessica* · 12:45
- **Visual superior:** línea de tiempo `FULL (dom)` → `DIFF (diario)` → `LOG (15 min)` con un candado 🔒 AES_256 en cada uno.
- **Visual central:** flecha de restauración `FULL NORECOVERY → DIFF NORECOVERY → LOG RECOVERY → ONLINE ✅`.
- **3 tarjetas:** **3-2-1** (3 copias · 2 medios · 1 off-site) · **RPO 15 min** · **RTO 60 min**
- **Evidencia:** `6 487 = 6 487 filas · CHECKDB 0 errores · descifrado OK`.

### Diapositiva 12 — Data Warehouse y ETL · *Jhon Gustavo* · 14:30
- **Visual:** esquema estrella (fact al centro, 5 dimensiones alrededor, etiquetas `*_sk`).
- **Flujo inferior:** `OLTP → Staging (limpieza + prorrateo) → MERGE → Estrella → Power BI` con el reloj "Job 02:00".
- **Tarjeta de conciliación:** `Staging 6 451 = Fact 6 451 · S/ 325 059.90 = S/ 325 059.90 · Δ 0`

### Diapositiva 13 — Lo que dicen los datos (OLAP) · *Jhon Gustavo* · 16:15
- **Gráfico 1 (barras):** margen % por ruta en 2026 → TPP-CIX en rojo (−3.5 %), BGR/JAE en verde (> 50 %).
- **Gráfico 2 (línea):** ingresos mensuales 2025–2026 con picos marcados: "Café +47 %" (may) y "Navidad +71 %" (dic).
- **Etiquetas de técnica:** `ROLLUP` · `CUBE` · `LAG` · `SUM() OVER` · `RANK` · `NTILE`
- **Candado:** Rol_Analista_BI → Staging ⛔ Msg 229.

### Diapositiva 14 — Conclusiones · *Jhon Gustavo* · 17:15
- **4 íconos grandes con su cifra:**
  ⚡ Rendimiento **−99 %** lecturas · 🔐 Seguridad **4 roles / 0 PII visible** · 🛟 Continuidad **RPO 15 min · RTO 1 h** · 📊 Decisiones **ruta TPP-CIX con margen negativo detectada**
- **Siguiente paso:** Always On con réplica en Chiclayo · TDE · Columnstore.
- **Cierre:** "¡Gracias! ¿Preguntas?" + 5 nombres.

---

## Anexo — Capturas de respaldo (plan B)
Tomar una captura de cada uno de estos resultados y guardarlas en una diapositiva oculta al final:
1. Script 01 · FASE 4 y FASE 6: plan gráfico + pestaña Mensajes (189 y 2).
2. Script 02 · FASE 7: mensajes Msg 229 / 230 / 15151.
3. Script 03 · FASE 2.1: bitácora de auditoría; FASE 3.2: eventos XE; FASE 4.8: `backupset` con `aes_256`; FASE 6: conteos y descifrado en DR.
4. Script 04 · FASE 7.1: conciliación; FASE 8: `etl_log`.
5. Script 05 · Q1 (ROLLUP), Q4 (ranking de rutas), prueba del Rol_Analista_BI.
