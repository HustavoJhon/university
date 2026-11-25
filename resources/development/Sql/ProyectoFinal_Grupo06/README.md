# Proyecto Final BD2 — Grupo 6 · Transportes Akil S.A.C. (AkilFlow)

| Archivo | Contenido |
|---|---|
| `01_Scripts_SQL_Limpios/01_OLTP_Estructura_Datos_Indices.sql` | Criterio 2 · OLTP 3FN, datos, índices y plan de ejecución |
| `01_Scripts_SQL_Limpios/02_Seguridad_RBAC_Cifrado.sql` | Criterio 3 · 4 logins/users/roles, GRANT/DENY, AES_256 |
| `01_Scripts_SQL_Limpios/03_Auditoria_ExtendedEvents_DRP.sql` | Criterio 4 · Audit, XE > 2 s, backups cifrados, restauración DR |
| `01_Scripts_SQL_Limpios/04_DWH_EsquemaEstrella_ETL.sql` | Criterio 5 · Staging, estrella con SK, ETL MERGE, Job |
| `01_Scripts_SQL_Limpios/05_Consultas_OLAP_BI.sql` | Criterio 5 · ROLLUP, CUBE, ventanas, vista BI, Rol_Analista_BI |
| `02_Informe_Final_Proyecto.md` | Informe técnico (Criterio 1 + análisis de los 5 criterios) |
| `03_Guion_Exposicion_18min.md` | Guion por integrante, demos SSMS y preguntas del docente |
| `04_Estructura_Diapositivas.md` | Contenido de las 14 diapositivas |
| `05_Presentacion/presentacion.html` | Presentación reveal.js (abrir en el navegador; `S` = notas del orador, `F` = pantalla completa) |
| `05_Presentacion/presentacion.pdf` | La misma presentación en PDF |
| `05_Presentacion/presentacion.qmd` | Fuente Quarto: `quarto render presentacion.qmd` |

## Cómo ejecutar (Windows)
1. SQL Server 2022 **Developer** (no Express) + SSMS, como `sysadmin`.
2. Abrir y ejecutar con F5, en orden: 01 → 02 → 03 → 04 → 05 (≈ 1 min en total).
3. Las carpetas `C:\AkilFlow\...` se crean solas. Sin unidad C: → Ctrl+H sobre `C:\AkilFlow\`.
4. Para conectarse con los logins SQL: activar autenticación **mixta** en la instancia.
5. Los scripts son idempotentes: se pueden volver a ejecutar desde el 01.
