const pptxgen = require("pptxgenjs");
const React = require("react");
const ReactDOMServer = require("react-dom/server");
const sharp = require("sharp");
const fa = require("react-icons/fa");
const { applyTheme } = require(process.env.APPLY_THEME || "./apply_theme.js");

const OUT = process.argv[2];

const THEME = {
  name: "AkilFlow",
  headFontFace: "Cambria",
  bodyFontFace: "Calibri",
  colors: {
    dk1: "1D2733", lt1: "FFFFFF", dk2: "0B3C5D", lt2: "EEF3F7",
    accent1: "0B3C5D", accent2: "E39B2D", accent3: "C0392B", accent4: "2E8B57",
    accent5: "5B7A93", accent6: "8FA9BF", hlink: "0B3C5D", folHlink: "5B7A93",
  },
};
const HEX = THEME.colors;

const pres = new pptxgen();
pres.layout = "LAYOUT_WIDE"; // 13.33 x 7.5
pres.author = "Grupo 6 - Base de Datos 2";
pres.title = "AkilFlow - Transportes Akil S.A.C.";
pres.theme = { headFontFace: THEME.headFontFace, bodyFontFace: THEME.bodyFontFace };
const C = pres.SchemeColor;

// ---------- Layouts ----------
pres.defineSlideMaster({
  title: "AK_PORTADA",
  background: { color: C.text2 },
  objects: [
    { placeholder: { options: { name: "title", type: "title", x: 0.8, y: 2.0, w: 11.7, h: 1.4, fontFace: THEME.headFontFace, fontSize: 60, bold: true, color: C.background1, align: "left", valign: "bottom", margin: 0 }, text: "" } },
    { placeholder: { options: { name: "body", type: "body", x: 0.8, y: 3.55, w: 10.5, h: 0.9, fontSize: 22, color: C.background2, align: "left", valign: "top", margin: 0 }, text: "" } },
  ],
});
pres.defineSlideMaster({
  title: "AK_CONTENIDO",
  background: { color: C.background1 },
  margin: [0.5, 0.6, 0.6, 0.6],
  objects: [
    { placeholder: { options: { name: "title", type: "title", x: 0.6, y: 0.35, w: 9.6, h: 0.85, fontFace: THEME.headFontFace, fontSize: 32, bold: true, color: C.text2, align: "left", valign: "middle", margin: 0 }, text: "" } },
    { text: { text: "Transportes Akil S.A.C. · Grupo 6 · Base de Datos 2 · NRC 39572", options: { x: 0.6, y: 7.05, w: 8, h: 0.3, fontSize: 10, color: C.accent5, margin: 0 } } },
  ],
  slideNumber: { x: 12.2, y: 7.05, w: 0.5, h: 0.3, fontSize: 10, color: C.accent5, align: "right" },
});
pres.defineSlideMaster({
  title: "AK_CIERRE",
  background: { color: C.text2 },
  objects: [
    { placeholder: { options: { name: "title", type: "title", x: 0.6, y: 0.4, w: 12.1, h: 0.9, fontFace: THEME.headFontFace, fontSize: 34, bold: true, color: C.background1, align: "left", valign: "middle", margin: 0 }, text: "" } },
  ],
  slideNumber: { x: 12.2, y: 7.05, w: 0.5, h: 0.3, fontSize: 10, color: C.accent6, align: "right" },
});

// ---------- Helpers ----------
async function icon(Comp, hex, size = 256) {
  const svg = ReactDOMServer.renderToStaticMarkup(React.createElement(Comp, { color: "#" + hex, size: String(size) }));
  const buf = await sharp(Buffer.from(svg)).png().toBuffer();
  return "image/png;base64," + buf.toString("base64");
}
async function iconCircle(slide, Comp, x, y, d, fill, fg, name) {
  slide.addShape(pres.shapes.OVAL, { x, y, w: d, h: d, fill: { color: fill }, line: { type: "none" }, objectName: name + "_circulo" });
  const pad = d * 0.25;
  slide.addImage({ data: await icon(Comp, fg), x: x + pad, y: y + pad, w: d - 2 * pad, h: d - 2 * pad, objectName: name + "_icono" });
}
function chip(slide, text) {
  slide.addText(text, { x: 10.45, y: 0.52, w: 2.28, h: 0.5, shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.25, fill: { color: C.background2 }, color: C.text2, fontSize: 12, bold: true, align: "center", valign: "middle", margin: 0, isTextBox: true, objectName: "expositor" });
}
function card(slide, x, y, w, h, name, fill) {
  slide.addShape(pres.shapes.ROUNDED_RECTANGLE, { x, y, w, h, rectRadius: 0.08, fill: { color: fill || C.background2 }, line: { type: "none" }, objectName: name });
}
function txt(slide, text, opts) {
  slide.addText(text, Object.assign({ isTextBox: true, margin: 0, fontSize: 14, color: C.text1, valign: "top" }, opts));
}
function box(slide, text, x, y, w, h, fill, color, name, fs = 12, bold = true) {
  slide.addText(text, { x, y, w, h, shape: pres.shapes.ROUNDED_RECTANGLE, rectRadius: 0.06, fill: { color: fill }, line: { type: "none" }, color, fontSize: fs, bold, align: "center", valign: "middle", margin: 3, isTextBox: true, objectName: name });
}
function arrow(slide, x1, y1, x2, y2, color, name) {
  slide.addShape(pres.shapes.LINE, { x: Math.min(x1, x2), y: Math.min(y1, y2), w: Math.abs(x2 - x1) || 0.001, h: Math.abs(y2 - y1) || 0.001, flipH: x2 < x1, flipV: y2 < y1, line: { color: color || C.accent5, width: 1.75, endArrowType: "triangle" }, objectName: name });
}

(async () => {
  // ===== 1. PORTADA =====
  pres.addSection({ title: "Rodrigo · Empresa y DBA" });
  let s = pres.addSlide({ masterName: "AK_PORTADA", sectionTitle: "Rodrigo · Empresa y DBA" });
  s.addText("AkilFlow", { placeholder: "title" });
  s.addText("Plataforma de datos segura, resiliente y analítica para Transportes Akil S.A.C.", { placeholder: "body" });
  txt(s, "PROYECTO FINAL · BASE DE DATOS 2 · NRC 39572", { x: 0.8, y: 1.35, w: 9, h: 0.4, fontSize: 14, bold: true, color: C.accent2, charSpacing: 2 });
  txt(s, "Mg. Oscar Añazco Durand · Grupo 6 · Universidad Continental — Cusco", { x: 0.8, y: 4.55, w: 10, h: 0.4, fontSize: 16, color: C.background2 });
  const nombres = ["Rodrigo Sevillanos", "Andre Espinoza", "Amy Tumi", "Jessica Condemayta", "Jhon Gustavo Ccarita"];
  nombres.forEach((n, i) => {
    txt(s, n, { x: 0.8 + i * 2.38, y: 6.2, w: 2.3, h: 0.5, fontSize: 13, bold: true, color: C.background1 });
  });
  await iconCircle(s, fa.FaTruck, 10.9, 1.2, 1.6, C.accent2, HEX.dk2, "portada");
  s.addNotes("Rodrigo (0:00-0:30). Saludo y presentación del equipo. AkilFlow es la plataforma de datos que diseñamos para Transportes Akil: OLTP, seguridad, continuidad y BI en SQL Server 2022. La entregamos como dos respaldos .bak que se restauran con un solo script.");

  // ===== 2. EMPRESA =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Rodrigo · Empresa y DBA" });
  s.addText("Transportes Akil mueve el nororiente, pero a ciegas", { placeholder: "title" });
  chip(s, "Rodrigo");
  const kpis = [["6", "agencias"], ["10", "rutas troncales"], ["58.5 t", "flota de 8 unidades"], ["3 264", "encomiendas en 2025"]];
  kpis.forEach(([v, l], i) => {
    const x = 0.6 + i * 3.08;
    card(s, x, 1.5, 2.85, 1.75, "kpi_" + i);
    txt(s, v, { x: x + 0.2, y: 1.65, w: 2.5, h: 0.9, fontSize: 40, bold: true, color: C.text2, fontFace: THEME.headFontFace });
    txt(s, l, { x: x + 0.2, y: 2.6, w: 2.5, h: 0.45, fontSize: 14, color: C.accent5 });
  });
  txt(s, "Hoy: lo que no funciona", { x: 0.6, y: 3.6, w: 6, h: 0.4, fontSize: 20, bold: true, color: C.accent3 });
  const probs = [
    [fa.FaFileExcel, "Excel y cuadernos", "datos duplicados por agencia"],
    [fa.FaUnlock, "DNI y teléfonos expuestos", "riesgo ante la Ley N.° 29733"],
    [fa.FaHdd, "Sin respaldos", "un disco dañado borra el negocio"],
    [fa.FaQuestionCircle, "Rutas sin rentabilidad conocida", "precios decididos a ojo"],
  ];
  for (let i = 0; i < probs.length; i++) {
    const [ic, t, d] = probs[i];
    const x = 0.6 + (i % 2) * 6.15, y = 4.2 + Math.floor(i / 2) * 1.25;
    await iconCircle(s, ic, x, y, 0.8, C.accent3, "FFFFFF", "problema_" + i);
    txt(s, t, { x: x + 1.0, y: y + 0.02, w: 5, h: 0.4, fontSize: 16, bold: true });
    txt(s, d, { x: x + 1.0, y: y + 0.42, w: 5, h: 0.35, fontSize: 14, color: C.accent5 });
  }
  s.addNotes("Rodrigo (0:30-1:30). Empresa de carga y encomiendas con sede en Jaén y agencias en Chiclayo, Bagua Grande, Chachapoyas, Moyobamba y Tarapoto. Dos campañas fuertes: café (mayo-agosto) y Navidad. Los cuatro problemas que resolvemos: datos duplicados, PII expuesta, ningún respaldo y ninguna visibilidad de rentabilidad.");

  // ===== 3. ORGANIGRAMAS =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Rodrigo · Empresa y DBA" });
  s.addText("Proponemos un DBA dentro del Área de TI", { placeholder: "title" });
  chip(s, "Rodrigo");
  txt(s, "Organigrama general", { x: 0.6, y: 1.4, w: 6, h: 0.4, fontSize: 16, bold: true, color: C.accent5 });
  box(s, "Gerencia General", 2.35, 1.95, 2.7, 0.6, C.text2, "FFFFFF", "og_gg", 14);
  const gers = ["Operaciones", "Adm. y Finanzas", "Comercial", "TI"];
  gers.forEach((g, i) => {
    const x = 0.6 + i * 1.6;
    arrow(s, 3.7, 2.55, x + 0.72, 3.05, C.accent5, "og_l" + i);
    box(s, g, x, 3.05, 1.45, 0.65, g === "TI" ? C.accent2 : C.background2, g === "TI" ? HEX.dk2 : C.text2, "og_g" + i, 12);
  });
  txt(s, "Operaciones → Flota · Agencias (6 despachadores) · Despacho y rutas (4 conductores)", { x: 0.6, y: 4.05, w: 6.2, h: 0.7, fontSize: 13, color: C.accent5 });
  // TI
  txt(s, "Área de TI", { x: 7.2, y: 1.4, w: 5, h: 0.4, fontSize: 16, bold: true, color: C.accent5 });
  box(s, "Jefatura de TI", 8.85, 1.95, 2.5, 0.6, C.text2, "FFFFFF", "ti_jefe", 14);
  const ti = [["DBA\nPROPUESTO", C.accent3, "FFFFFF"], ["Desarrollo", C.background2, HEX.dk2], ["Infraestructura", C.background2, HEX.dk2], ["Seguridad de la Inf.", C.background2, HEX.dk2]];
  ti.forEach(([t, f, c], i) => {
    const x = 7.2 + i * 1.4;
    arrow(s, 10.1, 2.55, x + 0.62, 3.05, C.accent5, "ti_l" + i);
    box(s, t, x, 3.05, 1.28, 0.8, f, c, "ti_" + i, 11);
  });
  arrow(s, 7.84, 3.85, 7.84, 4.35, C.accent3, "ti_bi_l");
  box(s, "Analista de BI", 7.2, 4.35, 1.28, 0.6, C.background2, HEX.dk2, "ti_bi", 11);
  card(s, 0.6, 5.3, 12.1, 1.45, "ficha");
  txt(s, [
    { text: "Ficha del puesto: ", options: { bold: true, color: C.text2 } },
    { text: "DBA SQL Server · reporta al Jefe de TI · supervisa al Analista de BI · coordina con Seguridad e Infraestructura. Objetivo: datos disponibles (RTO ≤ 60 min), íntegros, confidenciales y útiles para decidir." },
  ], { x: 0.85, y: 5.45, w: 11.6, h: 1.15, fontSize: 15, valign: "middle" });
  s.addNotes("Rodrigo (1:30-2:15). La gerencia general tiene cuatro gerencias. TI depende directamente de la gerencia porque sirve a todas. Dentro de TI proponemos el puesto de DBA (en rojo), que supervisa al analista de BI y coordina con el oficial de seguridad.");

  // ===== 4. DECALOGO =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Rodrigo · Empresa y DBA" });
  s.addText("Decálogo del DBA: cada función con su KPI", { placeholder: "title" });
  chip(s, "Rodrigo");
  const dec = [
    [fa.FaProjectDiagram, "Modelo de datos", "53 restricciones"], [fa.FaTachometerAlt, "Rendimiento", "P95 < 1 s"],
    [fa.FaUserShield, "RBAC", "0 permisos directos"], [fa.FaLock, "Cifrado PII", "100 % cifrada"],
    [fa.FaClipboardList, "Auditoría", "100 % DML crítico"], [fa.FaHeartbeat, "Monitoreo", "consultas > 2 s"],
    [fa.FaLifeRing, "Backups / DRP", "RPO 15 · RTO 60 min"], [fa.FaCheckDouble, "Integridad", "0 errores CHECKDB"],
    [fa.FaChartBar, "Inteligencia BI", "Staging = Fact"], [fa.FaCogs, "Automatización", "Job ETL 02:00"],
  ];
  for (let i = 0; i < dec.length; i++) {
    const [ic, t, k] = dec[i];
    const col = i % 5, row = Math.floor(i / 5);
    const x = 0.6 + col * 2.46, y = 1.55 + row * 2.6;
    card(s, x, y, 2.26, 2.35, "dec_" + i);
    await iconCircle(s, ic, x + 0.73, y + 0.2, 0.8, C.text2, "FFFFFF", "dec_" + i);
    txt(s, `${i + 1}. ${t}`, { x: x + 0.1, y: y + 1.1, w: 2.06, h: 0.5, fontSize: 15, bold: true, align: "center" });
    txt(s, k, { x: x + 0.1, y: y + 1.6, w: 2.06, h: 0.5, fontSize: 13, color: C.accent2, bold: true, align: "center" });
  }
  s.addNotes("Rodrigo (2:15-3:30). Diez funciones estratégicas, cada una con un script del proyecto y un indicador medible. Destacar tres: rendimiento (189 a 2 lecturas), cifrado (100 % de PII cifrada) y DRP (RPO 15 min, RTO 60 min). Paso la palabra a Andre.");

  // ===== 5. OLTP =====
  pres.addSection({ title: "Andre · OLTP e índices" });
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Andre · OLTP e índices" });
  s.addText("Modelo OLTP en 3FN: 7 tablas, 53 restricciones", { placeholder: "title" });
  chip(s, "Andre");
  const T = { empresas: [0.6, 1.6], sucursales: [0.6, 3.4], usuarios_sistema: [0.6, 5.2], rutas: [3.6, 2.5], vehiculos: [3.6, 4.4], viajes: [6.0, 3.4], encomiendas: [8.4, 3.4] };
  const ed = [["empresas", "sucursales"], ["sucursales", "usuarios_sistema"], ["sucursales", "rutas"], ["empresas", "vehiculos"], ["rutas", "viajes"], ["vehiculos", "viajes"], ["viajes", "encomiendas"]];
  ed.forEach(([a, b], i) => {
    const [x1, y1] = T[a], [x2, y2] = T[b];
    arrow(s, x1 + 1.05 + (x2 > x1 ? 1.05 : 0), y1 + 0.35 + (y2 > y1 && x2 === x1 ? 0.35 : 0), x2 + (x2 > x1 ? 0 : 1.05), y2 + (x2 === x1 ? 0 : 0.35), C.accent5, "er_" + i);
  });
  Object.entries(T).forEach(([n, [x, y]]) => {
    box(s, n, x, y, 2.1, 0.7, n === "rutas" ? C.accent2 : n === "encomiendas" ? C.text2 : C.background2, n === "encomiendas" ? "FFFFFF" : HEX.dk2, "tabla_" + n, 13);
  });
  txt(s, "rutas separada: la distancia y la tarifa dependen de la ruta, no del viaje → sin dependencia transitiva (3FN)", { x: 3.6, y: 1.55, w: 4.6, h: 0.8, fontSize: 13, color: C.text1, italic: true });
  const st = [["697", "viajes"], ["6 487", "encomiendas"], ["16", "CHECK"], ["Msg 547", "peso negativo rechazado"]];
  st.forEach(([v, l], i) => {
    card(s, 10.8, 1.5 + i * 1.33, 1.9, 1.15, "dato_" + i);
    txt(s, v, { x: 10.9, y: 1.58 + i * 1.33, w: 1.7, h: 0.55, fontSize: 24, bold: true, color: C.text2, align: "center", fontFace: THEME.headFontFace });
    txt(s, l, { x: 10.9, y: 2.13 + i * 1.33, w: 1.7, h: 0.45, fontSize: 12, color: C.accent5, align: "center" });
  });
  s.addNotes("Andre (3:30-4:45). Siete tablas en tercera forma normal: 7 PK clúster, 10 FK, 9 UNIQUE, 16 CHECK y 11 DEFAULT. La tabla rutas se separó de viajes para eliminar la dependencia transitiva: la distancia y la tarifa dependen de la ruta. Los datos son determinísticos: 697 viajes y 6 487 encomiendas con la estacionalidad del café y la Navidad.");

  // ===== 6. INDICES =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Andre · OLTP e índices" });
  s.addText("Un índice covering baja la consulta de 189 a 2 lecturas", { placeholder: "title" });
  chip(s, "Andre");
  s.addChart(pres.charts.BAR, [{ name: "Lecturas lógicas", labels: ["ANTES · Clustered Scan", "INTERMEDIO · Seek + Key Lookup", "DESPUÉS · Seek covering"], values: [189, 32, 2] }], {
    x: 0.6, y: 1.45, w: 7.3, h: 4.4, barDir: "bar", chartColors: [HEX.accent3, HEX.accent2, HEX.accent4], valAxisHidden: true,
    catAxisLabelColor: HEX.dk1, catAxisLabelFontSize: 13, catAxisLabelFontFace: "+mn-lt", catAxisOrientation: "maxMin",
    showValue: true, dataLabelPosition: "outEnd", dataLabelFontSize: 16, dataLabelFontBold: true, dataLabelColor: HEX.dk1, dataLabelFontFace: "+mn-lt",
    valGridLine: { style: "none" }, catGridLine: { style: "none" }, showLegend: false, barGapWidthPct: 45,
    showTitle: true, title: "Lecturas lógicas (SET STATISTICS IO)", titleFontSize: 14, titleColor: HEX.dk2, titleFontFace: "+mn-lt",
  });
  card(s, 8.3, 1.5, 4.4, 2.0, "callout");
  txt(s, "−99 %", { x: 8.5, y: 1.6, w: 4, h: 1.0, fontSize: 54, bold: true, color: C.accent4, fontFace: THEME.headFontFace });
  txt(s, "de lecturas: el índice responde la consulta sin tocar la tabla", { x: 8.5, y: 2.65, w: 4, h: 0.75, fontSize: 14 });
  txt(s, [
    { text: "estado", options: { bold: true } }, { text: " primero (igualdad), " },
    { text: "fecha_registro", options: { bold: true } }, { text: " después (rango)", options: { breakLine: true } },
    { text: "INCLUDE", options: { bold: true } }, { text: " elimina el Key Lookup sin ensanchar la clave", options: { breakLine: true } },
    { text: "Índice filtrado", options: { bold: true } }, { text: ": solo 35 encomiendas pendientes" },
  ], { x: 8.3, y: 3.8, w: 4.4, h: 2.0, fontSize: 14, paraSpaceAfter: 6 });
  txt(s, "CREATE INDEX IX_encomiendas_estado_fecha ON encomiendas (estado, fecha_registro) INCLUDE (codigo_rastreo, peso_kg, precio_envio)", { x: 0.6, y: 6.1, w: 12.1, h: 0.6, fontSize: 12, fontFace: "Courier New", color: C.text2 });
  s.addNotes("Andre (4:45-7:00). DEMO bloque A con Ctrl+M: la consulta forzada al índice clúster hace Clustered Index Scan; la normal usa Index Seek. Antes 189 lecturas, con el índice simple 32 (Seek + Key Lookup) y con INCLUDE 2: menos 99 %. En la base restaurada, con filas más anchas por el cifrado, es 381 contra 2. Paso a Amy.");

  // ===== 7. SEGURIDAD 2 CAPAS =====
  pres.addSection({ title: "Amy · Seguridad y cifrado" });
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Amy · Seguridad y cifrado" });
  s.addText("Seguridad en 2 capas y 4 roles con mínimo privilegio", { placeholder: "title" });
  chip(s, "Amy");
  const capas = [["LOGIN", "instancia · ¿quién eres?"], ["USER", "base · ¿qué puedes hacer?"], ["ROL", "agrupa permisos"], ["OBJETOS", "tablas · vistas · SP"]];
  capas.forEach(([t, d], i) => {
    const x = 0.6 + i * 3.1;
    box(s, t, x, 1.5, 2.6, 0.65, i === 2 ? C.accent2 : C.text2, i === 2 ? HEX.dk2 : "FFFFFF", "capa_" + i, 16);
    txt(s, d, { x, y: 2.2, w: 2.6, h: 0.35, fontSize: 12, color: C.accent5, align: "center" });
    if (i < 3) arrow(s, x + 2.65, 1.83, x + 3.05, 1.83, C.accent5, "capa_flecha_" + i);
  });
  const filas = [
    ["", "Operador", "Supervisor", "Auditor", "Contador"],
    ["SELECT viajes", "✔", "✔", "✔", "✔"],
    ["Ver PII descifrada", "✔ vía SP", "✔ vía SP", "✘ binario", "✘ Msg 230"],
    ["INSERT encomienda", "solo SP", "solo SP", "✘ DENY", "✘ DENY"],
    ["UPDATE", "estado, viaje_id", "viajes, flota", "✘ DENY", "✘ DENY"],
    ["DELETE", "✘ Msg 229", "✘ Msg 229", "✘ DENY", "✘ DENY"],
  ];
  const rows = filas.map((r, ri) => r.map((c, ci) => ({
    text: c, options: {
      bold: ri === 0 || ci === 0, fontSize: 14, align: ci === 0 ? "left" : "center",
      color: ri === 0 ? "FFFFFF" : c.startsWith("✘") ? HEX.accent3 : c.startsWith("✔") ? HEX.accent4 : HEX.dk1,
      fill: { color: ri === 0 ? HEX.dk2 : ri % 2 ? "FFFFFF" : HEX.lt2 },
    },
  })));
  s.addTable(rows, { x: 0.6, y: 2.85, w: 8.4, colW: [2.4, 1.5, 1.5, 1.5, 1.5], rowH: 0.52, border: { type: "solid", pt: 0.5, color: "D5DDE6" }, fontFace: "Calibri" });
  card(s, 9.4, 2.85, 3.3, 3.12, "msg229", "FBEAEA");
  txt(s, "Msg 229", { x: 9.6, y: 3.0, w: 3, h: 0.7, fontSize: 32, bold: true, color: C.accent3, fontFace: THEME.headFontFace });
  txt(s, "The DELETE permission was denied on the object 'encomiendas'", { x: 9.6, y: 3.75, w: 2.9, h: 1.1, fontSize: 13, italic: true });
  txt(s, "DENY gana a cualquier GRANT heredado", { x: 9.6, y: 4.95, w: 2.9, h: 0.8, fontSize: 14, bold: true, color: C.text2 });
  s.addNotes("Amy (7:00-8:45). Capa 1 LOGIN en master, capa 2 USER en la base; los logins tienen SID fijo, por eso al restaurar no quedan usuarios huérfanos. Los permisos van solo a roles. DEMO bloque B: el operador registra por el SP, pero DELETE da Msg 229 y cambiar el precio da Msg 230 (permiso por columna).");

  // ===== 8. CIFRADO =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Amy · Seguridad y cifrado" });
  s.addText("AES_256: ningún dato personal queda en texto plano", { placeholder: "title" });
  chip(s, "Amy");
  const jer = [["Service Master Key", "instancia"], ["Database Master Key", "contraseña + SMK"], ["Certificado", "Cert_AkilFlow_Operaciones"], ["Symmetric Key AES_256", "SymKey_AkilFlow_Datos"]];
  jer.forEach(([t, d], i) => {
    const w = 3.0 + i * 0.6, x = 0.6 + (5.4 - w) / 2, y = 1.5 + i * 0.95;
    box(s, t + "\n" + d, x, y, w, 0.8, i === 3 ? C.accent2 : C.text2, i === 3 ? HEX.dk2 : "FFFFFF", "jer_" + i, 12);
  });
  txt(s, "remitente · documento · destinatario · teléfono → VARBINARY(256)", { x: 0.6, y: 5.4, w: 5.4, h: 0.5, fontSize: 13, align: "center", color: C.accent5 });
  card(s, 6.5, 1.5, 6.2, 1.55, "antes", "FBEAEA");
  txt(s, "ANTES", { x: 6.7, y: 1.6, w: 2, h: 0.35, fontSize: 13, bold: true, color: C.accent3 });
  txt(s, "Luis Cruz Llontop · 40112648", { x: 6.7, y: 2.0, w: 5.8, h: 0.6, fontSize: 22, fontFace: "Courier New" });
  card(s, 6.5, 3.25, 6.2, 1.55, "despues", "E8F4EC");
  txt(s, "DESPUÉS", { x: 6.7, y: 3.35, w: 2, h: 0.35, fontSize: 13, bold: true, color: C.accent4 });
  txt(s, "0x000E4F5613C6B84F…", { x: 6.7, y: 3.75, w: 5.8, h: 0.6, fontSize: 22, fontFace: "Courier New" });
  txt(s, [
    { text: "Validación round-trip en una transacción, DROP COLUMN y REBUILD", options: { bullet: true, breakLine: true } },
    { text: "Auditor: DecryptByKey → NULL y OPEN KEY → Msg 15151", options: { bullet: true, breakLine: true } },
    { text: "REVOKE retira un permiso; DENY lo prohíbe (demo en vivo)", options: { bullet: true } },
  ], { x: 6.5, y: 5.05, w: 6.2, h: 1.6, fontSize: 15, paraSpaceAfter: 6 });
  s.addNotes("Amy (8:45-10:30). Jerarquía SMK, DMK, certificado y llave simétrica AES_256. Se cifraron las cuatro columnas sensibles, se validó el descifrado dentro de una transacción, se eliminó el texto plano y se reconstruyó la tabla para purgar los bytes. DEMO B.6: el auditor ve NULL y Msg 15151. B.8: REVOKE de UPDATE(estado) y el operador recibe Msg 229. Paso a Jessica.");

  // ===== 9. AUDITORIA =====
  pres.addSection({ title: "Jessica · Auditoría y DRP" });
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Jessica · Auditoría y DRP" });
  s.addText("SQL Server Audit registra incluso el intento fallido", { placeholder: "title" });
  chip(s, "Jessica");
  box(s, "DATABASE AUDIT SPEC\nencomiendas · viajes · SP", 0.6, 1.5, 3.4, 0.95, C.background2, HEX.dk2, "aud_db", 13);
  box(s, "SERVER AUDIT\nAudit_AkilFlow (master)", 0.6, 2.9, 3.4, 0.95, C.text2, "FFFFFF", "aud_srv", 13);
  box(s, ".sqlaudit\n50 MB × 10", 0.6, 4.3, 3.4, 0.95, C.accent2, HEX.dk2, "aud_file", 13);
  arrow(s, 2.3, 2.47, 2.3, 2.88, C.accent5, "aud_a1");
  arrow(s, 2.3, 3.87, 2.3, 4.28, C.accent5, "aud_a2");
  const log = [
    ["action_id", "succeeded", "usuario_bd", "sentencia"],
    ["UP", "1", "dbo", "UPDATE ... SET viaje_id = ..."],
    ["DL", "1", "dbo", "DELETE ... 'AK20261125DEMO01'"],
    ["SL", "1", "usr_operador", "SELECT COUNT(*) ..."],
    ["DL", "0", "usr_operador", "DELETE ... 'AK20261125PEND02'"],
    ["SL", "1", "usr_auditor", "SELECT TOP (3) ... viajes"],
  ];
  s.addTable(log.map((r, ri) => r.map((c) => ({ text: c, options: {
    fontSize: 13, bold: ri === 0 || ri === 4, color: ri === 0 ? "FFFFFF" : ri === 4 ? HEX.accent3 : HEX.dk1,
    fill: { color: ri === 0 ? HEX.dk2 : ri === 4 ? "FBEAEA" : "FFFFFF" }, fontFace: ri === 0 ? "Calibri" : "Courier New" } }))),
    { x: 4.5, y: 1.5, w: 8.2, colW: [1.2, 1.3, 1.8, 3.9], rowH: 0.5, border: { type: "solid", pt: 0.5, color: "D5DDE6" } });
  await iconCircle(s, fa.FaBalanceScale, 4.5, 5.0, 0.95, C.accent3, "FFFFFF", "norepudio");
  txt(s, [{ text: "No repudio: ", options: { bold: true, color: C.accent3 } }, { text: "el DELETE denegado queda con fecha, usuario y sentencia exacta. Un trigger no registra intentos fallidos ni SELECT." }], { x: 5.7, y: 5.0, w: 7.0, h: 1.0, fontSize: 15, valign: "middle" });
  s.addNotes("Jessica (10:30-12:15). Dos niveles: el Server Audit en master define el archivo .sqlaudit; la especificación de la base define qué se registra. Como la especificación viaja en el .bak, creamos el Server Audit con el mismo GUID al restaurar. DEMO bloque C: antes/después del UPDATE y la fila DL con succeeded = 0.");

  // ===== 10. XE =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Jessica · Auditoría y DRP" });
  s.addText("Extended Events solo captura lo que tarda más de 2 s", { placeholder: "title" });
  chip(s, "Jessica");
  await iconCircle(s, fa.FaStopwatch, 0.9, 1.7, 1.8, C.text2, "FFFFFF", "cronometro");
  txt(s, "2 s = 2 000 000 µs", { x: 0.6, y: 3.7, w: 2.6, h: 0.5, fontSize: 18, bold: true, align: "center", color: C.text2 });
  txt(s, "WHERE [duration] > (2000000)\n  AND database_name = N'AkilFlowOperaciones'", { x: 3.6, y: 1.6, w: 9.1, h: 1.0, fontSize: 15, fontFace: "Courier New", color: C.text2 });
  const xe = [["SELECT COUNT(*) FROM viajes", "milisegundos", "No se captura", C.accent5], ["WAITFOR DELAY '00:00:03'", "3.00 s", "Capturada", C.accent4], ["Reporte de rutas + espera", "3.0 s", "Capturada", C.accent4]];
  xe.forEach(([q, d, r, col], i) => {
    const y = 2.9 + i * 0.95;
    card(s, 3.6, y, 9.1, 0.8, "xe_" + i);
    txt(s, q, { x: 3.8, y: y + 0.2, w: 4.9, h: 0.4, fontSize: 15, fontFace: "Courier New" });
    txt(s, d, { x: 8.8, y: y + 0.2, w: 1.6, h: 0.4, fontSize: 15, bold: true });
    txt(s, r, { x: 10.5, y: y + 0.2, w: 2.1, h: 0.4, fontSize: 15, bold: true, color: col });
  });
  txt(s, "El filtro se evalúa antes de escribir al .xel: costo mínimo frente al Profiler · STARTUP_STATE = ON", { x: 0.6, y: 6.0, w: 12.1, h: 0.5, fontSize: 15, color: C.accent5 });
  s.addNotes("Jessica (12:15-12:45). La duración se mide en microsegundos: 2 s son 2 millones. El predicado se evalúa antes de enviar el evento, así que las consultas rápidas no cuestan nada. DEMO bloque D: el COUNT no aparece y el WAITFOR de 3 s sí.");

  // ===== 11. DRP =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Jessica · Auditoría y DRP" });
  s.addText("Plan DRP: respaldos cifrados y restauración probada", { placeholder: "title" });
  chip(s, "Jessica");
  const chain = [["FULL", "domingo 00:00", "2.93 MB"], ["DIFF", "diario 23:00", "0.17 MB"], ["LOG", "cada 15 min", "0.05 MB"]];
  for (let i = 0; i < 3; i++) {
    const [t, f, m] = chain[i], x = 0.6 + i * 2.55;
    card(s, x, 1.5, 2.3, 1.6, "bk_" + i);
    await iconCircle(s, fa.FaLock, x + 0.15, 1.65, 0.6, C.accent2, HEX.dk2, "bk_" + i);
    txt(s, t, { x: x + 0.9, y: 1.68, w: 1.3, h: 0.5, fontSize: 22, bold: true, color: C.text2 });
    txt(s, f + "\n" + m + " · AES_256", { x: x + 0.15, y: 2.35, w: 2.1, h: 0.7, fontSize: 13, color: C.accent5 });
  }
  const rest = [["FULL\nNORECOVERY", C.background2, HEX.dk2], ["DIFF\nNORECOVERY", C.background2, HEX.dk2], ["LOG\nRECOVERY", C.background2, HEX.dk2], ["ONLINE", C.accent4, "FFFFFF"]];
  rest.forEach(([t, f, c], i) => {
    const x = 0.6 + i * 1.95;
    box(s, t, x, 3.5, 1.6, 0.85, f, c, "rest_" + i, 13);
    if (i < 3) arrow(s, x + 1.62, 3.92, x + 1.93, 3.92, C.accent5, "rest_a" + i);
  });
  txt(s, "AkilFlowOperaciones_DR: 6 487 = 6 487 filas · CHECKDB sin errores · la encomienda posterior al DIFF se recupera con el LOG y se descifra", { x: 0.6, y: 4.6, w: 7.5, h: 0.9, fontSize: 14 });
  const met = [["3-2-1", "3 copias · 2 medios · 1 fuera del sitio (Azure, inmutable)"], ["RPO 15 min", "≈ 6 encomiendas en el peor caso"], ["RTO 60 min", "restaurar, verificar y redirigir"]];
  met.forEach(([v, d], i) => {
    const y = 1.5 + i * 1.6;
    card(s, 8.5, y, 4.2, 1.4, "met_" + i, i === 0 ? HEX.dk2 : C.background2);
    txt(s, v, { x: 8.7, y: y + 0.1, w: 3.8, h: 0.6, fontSize: 28, bold: true, color: i === 0 ? C.accent2 : C.text2, fontFace: THEME.headFontFace });
    txt(s, d, { x: 8.7, y: y + 0.72, w: 3.8, h: 0.6, fontSize: 13, color: i === 0 ? C.background1 : C.text1 });
  });
  txt(s, "Certificados y DMK exportados a C:\\AkilFlow\\Keys: sin ellos un .bak cifrado no se restaura en otro servidor", { x: 0.6, y: 5.75, w: 7.5, h: 0.8, fontSize: 14, color: C.accent3, bold: true });
  s.addNotes("Jessica (12:45-14:30). RECOVERY FULL, cadena FULL, DIFF y LOG cifrados con AES_256 y certificado en master. DEMO bloque E: se restaura en AkilFlowOperaciones_DR con NORECOVERY, NORECOVERY y RECOVERY; las dos encomiendas posteriores al FULL y al DIFF aparecen y se descifran. RPO 15 min por los respaldos de log y RTO 60 min. Paso a Jhon.");

  // ===== 12. DWH =====
  pres.addSection({ title: "Jhon · DWH, OLAP y entrega" });
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Jhon · DWH, OLAP y entrega" });
  s.addText("Data Warehouse en estrella alimentado por un ETL MERGE", { placeholder: "title" });
  chip(s, "Jhon");
  box(s, "fact_encomiendas\n1 fila = 1 encomienda", 2.4, 3.05, 2.6, 1.0, C.text2, "FFFFFF", "fact", 13);
  const dims = [["dim_tiempo", 0.6, 1.6], ["dim_sucursal", 4.2, 1.6], ["dim_ruta", 0.6, 4.55], ["dim_vehiculo", 4.2, 4.55], ["dim_estado", 2.4, 5.55]];
  dims.forEach(([n, x, y], i) => {
    box(s, n + "\n*_sk", x, y, 2.6, 0.8, C.background2, HEX.dk2, "dim_" + i, 12);
    arrow(s, x + 1.3, y < 3 ? y + 0.8 : y, 3.7, y < 3 ? 3.05 : 4.05, C.accent5, "dim_a" + i);
  });
  const etl = ["OLTP", "Staging", "Reglas de calidad", "MERGE dims + hechos", "Power BI"];
  etl.forEach((e, i) => {
    const y = 1.55 + i * 0.78;
    box(s, e, 7.4, y, 2.4, 0.58, i === 2 ? C.accent3 : i === 3 ? C.accent2 : C.background2, i === 2 ? "FFFFFF" : HEX.dk2, "etl_" + i, 13);
    if (i < 4) arrow(s, 8.6, y + 0.58, 8.6, y + 0.78, C.accent5, "etl_a" + i);
  });
  txt(s, "etl_errores\n(cuarentena)", { x: 10.0, y: 3.1, w: 1.8, h: 0.6, fontSize: 12, color: C.accent3, bold: true });
  card(s, 7.4, 5.6, 5.3, 1.15, "conciliacion", "E8F4EC");
  txt(s, [{ text: "Staging 6 451 = Fact 6 451", options: { bold: true, breakLine: true } }, { text: "S/ 325 059.90 en ambos · 0 hechos huérfanos · Job diario 02:00" }], { x: 7.6, y: 5.7, w: 5.0, h: 0.95, fontSize: 14, valign: "middle" });
  s.addNotes("Jhon (14:30-15:30). Esquema estrella con claves subrogadas y un miembro desconocido. El grano es una encomienda. El ETL extrae a staging, aplica reglas de calidad y manda las filas malas a etl_errores, y luego hace MERGE de dimensiones y hechos en una transacción. DEMO bloque F: un viaje se completa y el ETL solo actualiza esas filas.");

  // ===== 13. OLAP =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Jhon · DWH, OLAP y entrega" });
  s.addText("La ruta que más factura pierde dinero", { placeholder: "title" });
  chip(s, "Jhon");
  const rutas = ["JAE-BGR", "BGR-JAE", "BGR-CHA", "MOY-TPP", "JAE-CHA", "BGR-MOY", "JAE-CIX", "CIX-JAE", "CIX-TPP", "TPP-CIX"];
  const margen = [59.42, 57.06, 53.68, 50.90, 46.49, 44.11, 27.20, 21.28, 5.95, -3.45];
  s.addChart(pres.charts.BAR, [{ name: "Margen 2026 (%)", labels: rutas, values: margen }], {
    x: 0.6, y: 1.4, w: 6.0, h: 5.4, barDir: "bar", catAxisOrientation: "maxMin", catAxisLabelPos: "low",
    chartColors: [HEX.accent4, HEX.accent4, HEX.accent4, HEX.accent4, HEX.accent4, HEX.accent4, HEX.accent5, HEX.accent5, HEX.accent2, HEX.accent3], invertedColors: [HEX.accent3],
    showValue: true, dataLabelPosition: "outEnd", dataLabelFormatCode: "0.0", dataLabelFontSize: 11, dataLabelColor: HEX.dk1, dataLabelFontFace: "+mn-lt",
    catAxisLabelColor: HEX.dk1, catAxisLabelFontSize: 12, catAxisLabelFontFace: "+mn-lt", valAxisHidden: true,
    valGridLine: { style: "none" }, catGridLine: { style: "none" }, showLegend: false, barGapWidthPct: 40,
    showTitle: true, title: "Margen por ruta 2026 (%) · RANK() OVER", titleFontSize: 13, titleColor: HEX.dk2, titleFontFace: "+mn-lt",
  });
  const meses = ["E-25", "F", "M", "A", "M", "J", "J", "A", "S", "O", "N", "D", "E-26", "F", "M", "A", "M", "J", "J", "A", "S", "O"];
  const ingresos = [12325.55, 10508.68, 12406.50, 11230.96, 16550.42, 15469.31, 16799.11, 16729.56, 11288.32, 12190.06, 10555.13, 18096.51, 14053.54, 11394.50, 13723.67, 13036.71, 17631.55, 17706.85, 18155.90, 17188.28, 12270.93, 15091.61];
  s.addChart(pres.charts.LINE, [{ name: "Ingresos (S/)", labels: meses, values: ingresos }], {
    x: 6.9, y: 1.4, w: 5.8, h: 3.4, chartColors: [HEX.dk2], lineSize: 2.5, lineDataSymbol: "circle", lineDataSymbolSize: 5,
    catAxisLabelColor: HEX.dk1, catAxisLabelFontSize: 10, catAxisLabelFontFace: "+mn-lt", valAxisLabelColor: HEX.dk1, valAxisLabelFontSize: 10, valAxisLabelFontFace: "+mn-lt", valAxisLabelFormatCode: "#,##0",
    valGridLine: { color: "E3E8EE", size: 0.5 }, catGridLine: { style: "none" }, showLegend: false,
    showTitle: true, title: "Ingresos mensuales (S/) · LAG / SUM() OVER", titleFontSize: 13, titleColor: HEX.dk2, titleFontFace: "+mn-lt",
  });
  card(s, 6.9, 5.0, 2.8, 1.1, "cafe");
  txt(s, [{ text: "+47 %", options: { bold: true, fontSize: 24, color: C.accent2, breakLine: true } }, { text: "mayo: campaña del café", options: { fontSize: 12 } }], { x: 7.05, y: 5.05, w: 2.5, h: 1.0 });
  card(s, 9.9, 5.0, 2.8, 1.1, "navidad");
  txt(s, [{ text: "+71 %", options: { bold: true, fontSize: 24, color: C.accent2, breakLine: true } }, { text: "diciembre: Navidad", options: { fontSize: 12 } }], { x: 10.05, y: 5.05, w: 2.5, h: 1.0 });
  txt(s, "ROLLUP · CUBE · DRILL-DOWN · SLICE · DICE · RANK · NTILE", { x: 6.9, y: 6.3, w: 5.8, h: 0.4, fontSize: 12, bold: true, color: C.accent5 });
  s.addNotes("Jhon (15:30-16:45). DEMO bloque G. Ranking con RANK: Tarapoto-Chiclayo factura cerca del 18 % pero tiene margen negativo (-3.5 % en 2026). Las rutas cortas de Bagua Grande y Jaén superan el 50 %. Con LAG se ven los picos del café (+47 %) y de Navidad (+71 %). Recomendación: reajustar la tarifa de TPP-CIX. El analista BI lee la vista, pero el staging da Msg 229.");

  // ===== 14. ENTREGA =====
  s = pres.addSlide({ masterName: "AK_CONTENIDO", sectionTitle: "Jhon · DWH, OLAP y entrega" });
  s.addText("Entrega: 2 respaldos y 1 script, listo en menos de 1 minuto", { placeholder: "title" });
  chip(s, "Jhon");
  const pasos = [
    [fa.FaDatabase, "1 · Copiar", "AkilFlowOperaciones.bak\ndwh_AkilFlow.bak\n→ C:\\AkilFlow\\Entrega"],
    [fa.FaPlay, "2 · F5", "00_Restaurar_Proyecto.sql\nrestaura y reconstruye\nlo que vive en master"],
    [fa.FaChalkboardTeacher, "3 · Demo", "01_Demo_En_Clase.sql\nbloques A a G\npor integrante"],
  ];
  for (let i = 0; i < 3; i++) {
    const [ic, t, d] = pasos[i], x = 0.6 + i * 4.1;
    card(s, x, 1.5, 3.8, 2.6, "paso_" + i);
    await iconCircle(s, ic, x + 0.25, 1.7, 0.9, C.text2, "FFFFFF", "paso_" + i);
    txt(s, t, { x: x + 1.35, y: 1.85, w: 2.3, h: 0.6, fontSize: 22, bold: true, color: C.text2 });
    txt(s, d, { x: x + 0.25, y: 2.8, w: 3.4, h: 1.2, fontSize: 14 });
  }
  txt(s, "Lo que el script reconstruye (no viaja en un .bak)", { x: 0.6, y: 4.4, w: 8, h: 0.45, fontSize: 18, bold: true, color: C.text2 });
  const rec = ["Logins con el mismo SID → 0 usuarios huérfanos", "Server Audit con el mismo GUID → la especificación se re-enlaza", "DMK re-vinculada a la SMK → AES_256 funciona en otro servidor", "Extended Events, certificado de respaldos y Job del ETL"];
  txt(s, rec.map((r, i) => ({ text: r, options: { bullet: true, breakLine: i < rec.length - 1 } })), { x: 0.6, y: 4.9, w: 8.0, h: 1.9, fontSize: 15, paraSpaceAfter: 5 });
  card(s, 9.0, 4.4, 3.7, 2.35, "probado", "E8F4EC");
  await iconCircle(s, fa.FaCheck, 9.2, 4.6, 0.7, C.accent4, "FFFFFF", "probado");
  txt(s, "Probado en una instancia limpia de SQL Server 2022: 2 bases ONLINE, descifrado, auditoría y XE activos", { x: 9.2, y: 5.4, w: 3.3, h: 1.25, fontSize: 13 });
  s.addNotes("Jhon (16:45-17:15). Como pidió el docente, no ejecutamos los scripts uno por uno: se copian los dos .bak y se presiona F5 en el script de restauración. Ese script crea lo que no viaja en un .bak: logins con el mismo SID, la auditoría con el mismo GUID, re-vincula la DMK y crea XE, certificado y Job. Lo probamos en una instancia limpia.");

  // ===== 15. CIERRE =====
  s = pres.addSlide({ masterName: "AK_CIERRE", sectionTitle: "Jhon · DWH, OLAP y entrega" });
  s.addText("Lo que AkilFlow le da a Transportes Akil", { placeholder: "title" });
  const fin = [
    [fa.FaTachometerAlt, "−99 %", "lecturas en la consulta de rastreo"],
    [fa.FaUserShield, "0", "datos personales legibles sin autorización"],
    [fa.FaLifeRing, "15 / 60 min", "RPO y RTO con restauración probada"],
    [fa.FaChartLine, "TPP-CIX", "ruta con margen negativo detectada"],
  ];
  for (let i = 0; i < 4; i++) {
    const [ic, v, d] = fin[i], x = 0.6 + i * 3.1;
    await iconCircle(s, ic, x, 1.7, 1.0, C.accent2, HEX.dk2, "fin_" + i);
    txt(s, v, { x, y: 2.9, w: 2.9, h: 0.8, fontSize: 32, bold: true, color: C.background1, fontFace: THEME.headFontFace });
    txt(s, d, { x, y: 3.7, w: 2.8, h: 0.8, fontSize: 15, color: C.background2 });
  }
  txt(s, "Siguiente paso: Always On con réplica en Chiclayo · TDE · índice columnstore en el Fact", { x: 0.6, y: 5.0, w: 12, h: 0.5, fontSize: 16, color: C.accent6 });
  txt(s, "¡Gracias! ¿Preguntas?", { x: 0.6, y: 5.75, w: 12, h: 0.9, fontSize: 36, bold: true, color: C.accent2, fontFace: THEME.headFontFace });
  s.addNotes("Jhon (17:15-18:00). Cierre con cuatro cifras: rendimiento, seguridad, continuidad y decisiones. Siguiente paso: Always On, TDE y columnstore. Abrir preguntas; cada integrante responde sobre su criterio.");

  await pres.writeFile({ fileName: OUT });
  await applyTheme(OUT, THEME);
  console.log("OK", OUT);
})();
