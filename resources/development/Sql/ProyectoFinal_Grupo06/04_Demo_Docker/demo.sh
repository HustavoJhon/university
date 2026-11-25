#!/usr/bin/env bash
# =============================================================================
#  AkilFlow · BD2 Grupo 6 · Demo por fases en Docker
#  Uso:  ./demo.sh <comando>       (./demo.sh ayuda  para ver la lista)
# =============================================================================
set -euo pipefail

CONTENEDOR="${CONTENEDOR:-akilflow-prueba}"
PUERTO="${PUERTO:-14333}"
SA_PASS='Akil#Sa.Prueba2026'
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BAK_DIR="$(cd "$DIR/../00_ENTREGA_Restaurar" && pwd)"
SQLCMD=/opt/mssql-tools18/bin/sqlcmd
RUTA_BACKUPS=/var/opt/mssql/akil/Backups

azul()  { printf '\n\033[1;34m%s\033[0m\n' "$*"; }
verde() { printf '\033[1;32m%s\033[0m\n' "$*"; }

# ejecutar <archivo.sql> <login> <password> <base>
ejecutar() {
  local archivo="$1" login="$2" pass="$3" base="$4"
  azul "▶ $archivo   (conectado como: $login · base: $base)"
  docker exec "$CONTENEDOR" mkdir -p /tmp/demo
  docker cp "$DIR/$archivo" "$CONTENEDOR:/tmp/demo/$archivo" >/dev/null
  # -I = QUOTED_IDENTIFIER ON (como SSMS) · -W quita espacios · -s separador de columnas
  docker exec "$CONTENEDOR" "$SQLCMD" -C -I -S localhost -U "$login" -P "$pass" -d "$base" \
         -W -s '|' -i "/tmp/demo/$archivo" || true
}

fase() {
  case "$1" in
    00) ejecutar 00_Restaurar_Docker.sql          sa                "$SA_PASS"              master ;;
    01) ejecutar 01_Ver_Bases_y_Tablas.sql        sa                "$SA_PASS"              master ;;
    02) ejecutar 02_Rol_Operador.sql              login_operador    'Akil#Operador2026'     AkilFlowOperaciones ;;
    03) ejecutar 03_Rol_Supervisor.sql            login_supervisor  'Akil#Supervisor2026'   AkilFlowOperaciones ;;
    04) ejecutar 04_Rol_Auditor.sql               login_auditor     'Akil#Auditor2026'      AkilFlowOperaciones ;;
    05) ejecutar 05_Rol_Contador.sql              login_contador    'Akil#Contador2026'     AkilFlowOperaciones ;;
    06) ejecutar 06_Rol_Analista_BI.sql           login_analista_bi 'Akil#AnalistaBI2026'   dwh_AkilFlow ;;
    07) ejecutar 07_Matriz_Permisos_y_REVOKE.sql  sa                "$SA_PASS"              master ;;
    08) ejecutar 08_Cifrado_AES256.sql            sa                "$SA_PASS"              master ;;
    09) ejecutar 09_Indices_Plan_Ejecucion.sql    sa                "$SA_PASS"              master ;;
    10) ejecutar 10_Auditoria.sql                 sa                "$SA_PASS"              master ;;
    11) ejecutar 11_Extended_Events.sql           sa                "$SA_PASS"              master ;;
    12) ejecutar 12_Backups_FULL_DIFF_LOG.sql     sa                "$SA_PASS"              master ;;
    13) ejecutar 13_Restaurar_DRP.sql             sa                "$SA_PASS"              master ;;
    14) ejecutar 14_ETL_Incremental.sql           sa                "$SA_PASS"              master ;;
    15) ejecutar 15_Consultas_OLAP.sql            sa                "$SA_PASS"              master ;;
    *)  echo "Fase desconocida: $1"; exit 1 ;;
  esac
}

case "${1:-ayuda}" in
  levantar)
    azul "Creando contenedor $CONTENEDOR (SQL Server 2022) en el puerto $PUERTO"
    docker run -d --name "$CONTENEDOR" -e ACCEPT_EULA=Y -e "MSSQL_SA_PASSWORD=$SA_PASS" \
      -e MSSQL_AGENT_ENABLED=true -e MSSQL_PID=Developer -p "$PUERTO:1433" \
      -v "$BAK_DIR:/bak:ro" mcr.microsoft.com/mssql/server:2022-latest
    printf 'Esperando a que SQL Server acepte conexiones'
    for _ in $(seq 1 60); do
      if docker exec "$CONTENEDOR" "$SQLCMD" -C -S localhost -U sa -P "$SA_PASS" -Q 'SELECT 1' >/dev/null 2>&1; then
        echo; verde "✔ Listo. Siguiente paso: ./demo.sh 00"; exit 0
      fi
      printf '.'; sleep 2
    done
    echo; echo "SQL Server no respondió en 2 min: revise  docker logs $CONTENEDOR"; exit 1 ;;

  [0-9][0-9]) fase "$1" ;;

  roles)  for f in 02 03 04 05 06 07; do fase "$f"; done ;;
  todo)   for f in 01 02 03 04 05 06 07 08 09 10 11 12 13 14 15; do fase "$f"; done ;;

  ver-backups)
    azul "Archivos en $RUTA_BACKUPS (dentro del contenedor $CONTENEDOR)"
    docker exec "$CONTENEDOR" ls -lh --time-style=+'%Y-%m-%d %H:%M:%S' "$RUTA_BACKUPS" ;;

  copiar-backups)
    DESTINO="$DIR/backups_generados"
    mkdir -p "$DESTINO"
    docker cp "$CONTENEDOR:$RUTA_BACKUPS/." "$DESTINO/"
    azul "Backups copiados a: $DESTINO"
    ls -lh "$DESTINO" ;;

  ver-archivos)
    azul "Todo lo que genera el proyecto en /var/opt/mssql/akil (auditoría, XE, backups, DR)"
    docker exec "$CONTENEDOR" find /var/opt/mssql/akil -type f -exec ls -lh {} \; ;;

  login-fallido)
    azul "Intento de inicio de sesión con contraseña incorrecta (queda en la auditoría, fase 10)"
    docker exec "$CONTENEDOR" "$SQLCMD" -C -S localhost -U login_operador -P 'ClaveIncorrecta' -Q 'SELECT 1' || true ;;

  consola)
    # ./demo.sh consola operador|supervisor|auditor|contador|analista|sa
    case "${2:-sa}" in
      operador)   L=login_operador    P='Akil#Operador2026'   B=AkilFlowOperaciones ;;
      supervisor) L=login_supervisor  P='Akil#Supervisor2026' B=AkilFlowOperaciones ;;
      auditor)    L=login_auditor     P='Akil#Auditor2026'    B=AkilFlowOperaciones ;;
      contador)   L=login_contador    P='Akil#Contador2026'   B=AkilFlowOperaciones ;;
      analista)   L=login_analista_bi P='Akil#AnalistaBI2026' B=dwh_AkilFlow ;;
      sa)         L=sa                P="$SA_PASS"            B=master ;;
      *) echo "Rol desconocido: $2"; exit 1 ;;
    esac
    azul "Consola SQL como $L (escriba la consulta, luego GO y Enter; para salir: exit)"
    docker exec -it "$CONTENEDOR" "$SQLCMD" -C -I -S localhost -U "$L" -P "$P" -d "$B" -W -s '|' ;;

  apagar)    docker stop "$CONTENEDOR" ;;
  encender)  docker start "$CONTENEDOR" ;;
  borrar)    docker rm -f "$CONTENEDOR" ;;

  *)
    cat <<EOF
AkilFlow · demo por fases (contenedor: $CONTENEDOR, puerto $PUERTO)

  ./demo.sh levantar        Crear el contenedor SQL Server 2022
  ./demo.sh 00              Restaurar los .bak (bases + logins + auditoría + XE + Job)
  ./demo.sh 01              Ver bases, tablas, datos y seguridad restaurada
  ./demo.sh 02 .. 06        Probar cada rol conectado con SU login
                            02 operador · 03 supervisor · 04 auditor · 05 contador · 06 analista BI
  ./demo.sh 07              Matriz de permisos de todos los roles + REVOKE vs DENY
  ./demo.sh 08              Cifrado AES_256
  ./demo.sh 09              Índices y plan de ejecución
  ./demo.sh 10              Auditoría (antes: ./demo.sh login-fallido)
  ./demo.sh 11              Extended Events (consultas > 2 s)
  ./demo.sh 12              Generar los 3 backups FULL / DIFF / LOG
  ./demo.sh 13              Restaurar FULL + DIFF + LOG en AkilFlowOperaciones_DR
  ./demo.sh 14              ETL incremental al Data Warehouse
  ./demo.sh 15              Consultas OLAP
  ./demo.sh roles | todo    Ejecutar 02-07 | 01-15 seguidas

  ./demo.sh ver-backups     Listar los archivos de backup dentro del contenedor
  ./demo.sh copiar-backups  Copiarlos a ./backups_generados en su PC
  ./demo.sh ver-archivos    Listar auditoría, XE, backups y DR
  ./demo.sh login-fallido   Provocar un inicio de sesión fallido
  ./demo.sh consola <rol>   Consola SQL interactiva (operador|supervisor|auditor|contador|analista|sa)
  ./demo.sh apagar | encender | borrar
EOF
    ;;
esac
