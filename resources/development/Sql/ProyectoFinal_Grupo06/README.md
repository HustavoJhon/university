# Proyecto Final BD2 — Grupo 6 · Transportes Akil S.A.C. (AkilFlow)

Entrega por **restauración**: el docente no ejecuta los scripts uno por uno, restaura dos respaldos con un solo script.

## Cómo restaurar en el aula (SQL Server 2022)

1. Copiar `00_ENTREGA_Restaurar/AkilFlowOperaciones.bak` y `dwh_AkilFlow.bak` en `C:\AkilFlow\Entrega\`.
   Si sale *Operating system error 5 (Access is denied)*, usar la carpeta `Backup` de la instancia y cambiar la ruta del PASO 0.
2. Abrir `00_ENTREGA_Restaurar/00_Restaurar_Proyecto.sql` en SSMS (sysadmin) y presionar **F5**. Tarda menos de 1 minuto.
3. Para la exposición: `00_ENTREGA_Restaurar/01_Demo_En_Clase.sql`, ejecutado por bloques A–G.
4. Para demostrar cada fase por separado: `00_ENTREGA_Restaurar/02_Consultas_Por_Fase/` (archivos 01–15, ver su README).

Los `.bak` se generaron en SQL Server 2022 (16.0) y **no restauran en 2019**.

## Contenido

| Archivo | Uso |
|---|---|
| `00_ENTREGA_Restaurar/*.bak` | Respaldos de `AkilFlowOperaciones` (OLTP) y `dwh_AkilFlow` (DWH) |
| `00_ENTREGA_Restaurar/00_Restaurar_Proyecto.sql` | Restaura las 2 bases y recrea logins (mismo SID), auditoría (mismo GUID), DMK, Extended Events, certificado y Job |
| `00_ENTREGA_Restaurar/01_Demo_En_Clase.sql` | Demo en vivo: plan de ejecución, RBAC/REVOKE, cifrado, auditoría, XE, DRP, ETL, OLAP |
| `00_ENTREGA_Restaurar/02_Consultas_Por_Fase/` | 15 archivos SQL para SSMS: tablas, cada rol, matriz de permisos, cifrado, índices, auditoría, XE, backups FULL/DIFF/LOG, DRP, ETL, OLAP |
| `04_Demo_Docker/` | Las mismas fases para SQL Server en Docker (Linux/macOS) con `demo.sh` |
| `MANUAL_DE_USO.md` | Manual de uso y credenciales de cada rol |
| `01_Scripts_SQL_Limpios/01`–`05` | Código fuente T-SQL que construyó las bases (criterios 2 a 5) |
| `01_Scripts_SQL_Limpios/06_Generar_Backups_Entrega.sql` | Cómo se generaron los `.bak` (COPY_ONLY, CHECKSUM) |
| `02_Informe/Informe_Final_Grupo06.pdf` | Informe final, ordenado por los 5 criterios de la rúbrica |
| `03_Guion_Exposicion_18min.md` | Guion por integrante, demos y preguntas probables |
| `05_Presentacion/AkilFlow_Grupo06.pptx` | Diapositivas (15) con notas del orador; también en PDF |

## Regenerar

- **Bases y `.bak`**: ejecutar `01` → `06` con F5 en SQL Server 2022 Developer. Los `.bak` quedan en `C:\AkilFlow\Entrega\`.
- **Informe PDF**: `QUARTO_CHROMIUM=$(which chromium) quarto render 02_Informe/Informe_Final_Grupo06.qmd`, luego `python3 02_Informe/fix_svg.py 02_Informe/Informe_Final_Grupo06.html` e imprimir a PDF con `chromium --headless --no-pdf-header-footer --print-to-pdf=...`.
- **PPT**: `node 05_Presentacion/generar_pptx.js salida.pptx` (requiere `pptxgenjs`, `react-icons`, `sharp`).

Probado: scripts 01–06 en una instancia de SQL Server 2022 y restauración + demo en otra instancia **limpia**, sin errores inesperados.
