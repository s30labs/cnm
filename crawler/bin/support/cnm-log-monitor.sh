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
    local NUM_LINES=10000

    echo "cnm-log-monitor.sh Parsing last $NUM_LINES lines of $LOG_FILE with text '$SEARCH_TEXT'"
    logger -p user.notice "cnm-log-monitor.sh Parsing last $NUM_LINES lines of $LOG_FILE with text '$SEARCH_TEXT'"

    # Buscar la primera línea que contenga el texto literal
    local MATCHED_LINE=$(tail -n "$NUM_LINES" "$LOG_FILE" | grep -F "$SEARCH_TEXT" | head -n 1)

    echo "$MATCHED_LINE"

    if [[ -n "$MATCHED_LINE" ]]; then
        #echo "REINICIO PROCESO 0"
        if [[ "$MATCHED_LINE" =~ \[([^\]]+)\]\[([0-9]+)\] ]]; then
            #echo "REINICIO PROCESO 1"
            reiniciar_proceso "${BASH_REMATCH[1]}" "${BASH_REMATCH[2]}"
        fi
    fi
}

# Procesar cada archivo de la lista
for LOG_FILE in "${LOG_FILES[@]}"; do
    [ -f "$LOG_FILE" ] && procesar_log "$LOG_FILE"
done

