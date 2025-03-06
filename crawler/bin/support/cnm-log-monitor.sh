#!/bin/bash

# Verificar si se pasó un argumento
if [ -z "$1" ]; then
    echo "Uso: $0 '<texto_a_buscar>'"
    exit 1
fi

SEARCH_TEXT="$1"

# Escapar caracteres especiales en el texto de búsqueda (para el grep)
SEARCH_TEXT_ESC=$(printf '%q' "$1")

# Lista de archivos a procesar
LOG_FILES=("/var/log/crawler_debug.log")

# Función para manejar el proceso encontrado
reiniciar_proceso() {
    local PROCESS_NAME="$1"
    local PID="$2"
    echo "cnm-log-monitor.sh STOP $PROCESS_NAME PID=$PID TEXT FOUND = '$SEARCH_TEXT'"
    
    # Reiniciar el proceso
    kill -9 "$PID"
    logger -p user.notice "cnm-log-monitor.sh STOP $PROCESS_NAME PID=$PID TEXT FOUND = '$SEARCH_TEXT'"
}

# Función para procesar un archivo de log
procesar_log() {
    local LOG_FILE="$1"
    
    # Obtener la hora actual y la hora hace 30 minutos
    local CURRENT_HOUR=$(date +"%H")
    local CURRENT_MINUTE=$(date +"%M")
    
    # Determinar el intervalo de búsqueda
    if [ "$CURRENT_MINUTE" -eq "00" ]; then
        local START_HOUR=$(date -d "1 hour ago" +"%H")
        local START_MIN=30
    else
        local START_HOUR=$CURRENT_HOUR
        local START_MIN=00
    fi
    
    # Construir el patrón de tiempo para grep
    local TIME_PATTERN1=$(date +"%b %e $START_HOUR:$START_MIN")
    local TIME_PATTERN2=$(date +"%b %e $CURRENT_HOUR:$CURRENT_MINUTE")
    
    #echo "Procesando $LOG_FILE - Buscando líneas entre $TIME_PATTERN1:00 y $TIME_PATTERN2:59 con texto '$SEARCH_TEXT'"
	 echo "cnm-log-monitor.sh Parsing $LOG_FILE between $TIME_PATTERN1:00 and $TIME_PATTERN2:59 with text '$SEARCH_TEXT'"
    logger -p user.notice "cnm-log-monitor.sh Parsing $LOG_FILE between $TIME_PATTERN1:00 and $TIME_PATTERN2:59 with text '$SEARCH_TEXT'"

    # Buscar la primera línea con el texto especificado en el rango de tiempo
    local MATCHED_LINE=$(grep -E "$TIME_PATTERN1|$TIME_PATTERN2" "$LOG_FILE" | grep -w "$SEARCH_TEXT_ESC" | head -n 1)
    
    if [[ -n "$MATCHED_LINE" ]]; then
        if [[ "$MATCHED_LINE" =~ \[([^\]]+)\]\[([0-9]+)\] ]]; then
			   reiniciar_proceso "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    fi
}

# Procesar cada archivo de la lista
for LOG_FILE in "${LOG_FILES[@]}"; do
    [ -f "$LOG_FILE" ] && procesar_log "$LOG_FILE"
done

