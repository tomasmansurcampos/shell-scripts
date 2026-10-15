#!/bin/bash

# Terminar la ejecución si ocurre un error o se usa una variable no definida
set -euo pipefail

_yt_d() {
    local URL="${1:-}"

    if [[ -z "$URL" ]]; then
        echo "Error: Debes proporcionar una URL de YouTube Music."
        exit 1
    fi

    # 0. Verificación de dependencias
    local DEPENDENCIAS=("yt-dlp" "ffmpeg" "deno")
    for cmd in "${DEPENDENCIAS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: '$cmd' no está instalado o no se encuentra en el PATH."
            exit 1
        fi
    done

    echo "Dependencias correctas. Iniciando proceso..."

    # 1. Determinar plantilla de salida según el tipo de enlace
    local OUTPUT_TMPL=""
    if [[ "$URL" == *"list="* ]] || [[ "$URL" == *"playlist"* ]]; then
        echo "Modo: Álbum / Playlist"
        # Formato: Artista - Nombre del Album/01 - Cancion.flac
        OUTPUT_TMPL="%(artist)s - %(playlist_title|Album)s/%(playlist_index)02d - %(title)s.%(ext)s"
    else
        echo "Modo: Track individual"
        # Formato: Artista - Sencillos/Cancion.flac
        OUTPUT_TMPL="%(artist)s - Sencillos/%(title)s.%(ext)s"
    fi

    # 2. Ejecutar descarga e incrustación de metadatos
    yt-dlp \
        --cookies-from-browser chrome \
        --extract-audio \
        --audio-format flac \
        --audio-quality 0 \
        --embed-thumbnail \
        --embed-metadata \
        -o "$OUTPUT_TMPL" \
        "$URL"

    # 3. Mensaje de éxito
    echo "Descarga y procesamiento finalizados con éxito."
}

_yt_d "$@"