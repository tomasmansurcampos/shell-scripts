#!/bin/bash
set -euo pipefail

ads_blocker()
{
    local HOSTS_FILE="/etc/hosts"
    local ORIGINAL_BACKUP="/etc/hosts.original"
    local TEMP_BLOCK
    local TEMP_CLEAN
    local TEMP_FINAL

    TEMP_BLOCK=$(mktemp)
    TEMP_CLEAN=$(mktemp)
    TEMP_FINAL=$(mktemp)

    # TRAP: Limpieza automática de todos los archivos temporales
    trap "rm -f \"$TEMP_BLOCK\" \"$TEMP_CLEAN\" \"$TEMP_FINAL\"" EXIT

    local URLS=(
        "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists-legacy@latest/hosts/light-compressed.txt"
        "https://cdn.jsdelivr.net/gh/hagezi/dns-blocklists-legacy@latest/hosts/tif-compressed.txt"
        "https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling/hosts"
        "https://someonewhocares.org/hosts/zero/hosts"
    )

    echo "Descargando listas..."
    for url in "${URLS[@]}"; do
        # -f falla silenciosamente en errores HTTP (404, 500) evitando descargar HTML residual
        if ! curl -sLf "$url" >> "$TEMP_BLOCK"; then
            echo "Error crítico: Falló la descarga de $url. Abortando sin modificar el sistema." >&2
            exit 1
        fi
        echo "" >> "$TEMP_BLOCK"
    done

    echo "Procesando datos y eliminando duplicados..."
    # Limpieza avanzada: Ignora las entradas localhost de las listas descargadas para no 
    # duplicar ni romper las configuraciones nativas del /etc/hosts original.
    awk '
        # Ignorar comentarios y líneas vacías
        /^[[:space:]]*#/ || !NF { next }
        # Ignorar entradas locales de red (ya presentes en el hosts original)
        $2 ~ /^(localhost|broadcasthost|local|ip6-.*)$/ { next }
        # Normalizar IPs hacia 0.0.0.0 (más eficiente) y eliminar dominios duplicados
        $1 == "0.0.0.0" || $1 == "127.0.0.1" {
            if (!vistos[$2]++) print "0.0.0.0", $2
        }
    ' "$TEMP_BLOCK" > "$TEMP_CLEAN"

    if [[ ! -s "$TEMP_CLEAN" ]]; then
        echo "Error: Las listas procesadas están vacías. Posible fallo de red. Abortando." >&2
        exit 1
    fi

    # Preservar una única copia inmutable del hosts de instalación
    if [[ ! -f "$ORIGINAL_BACKUP" ]]; then
        echo "Creando backup base en $ORIGINAL_BACKUP..."
        sudo cp -a "$HOSTS_FILE" "$ORIGINAL_BACKUP"
    fi

    echo "Construyendo el nuevo archivo hosts..."
    # Se construye en un temporal para evitar problemas de concurrencia y permisos
    cat "$ORIGINAL_BACKUP" > "$TEMP_FINAL"
    echo -e "\n# --- INICIO BLOCKLIST ---" >> "$TEMP_FINAL"
    cat "$TEMP_CLEAN" >> "$TEMP_FINAL"

    echo "Aplicando actualización de manera atómica..."
    # Uso correcto de sudo para sobrescribir archivos del sistema
    sudo cp "$TEMP_FINAL" "$HOSTS_FILE"
    sudo chmod 644 "$HOSTS_FILE"

    echo "Archivo hosts actualizado y optimizado correctamente."
}

ads_blocker