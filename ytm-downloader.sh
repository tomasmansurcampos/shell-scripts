#!/bin/bash

# Terminar la ejecución si ocurre un error o se usa una variable no definida
set -euo pipefail

_yt_d() {
    local MUSIC_GOLD=0
    local URL=""

    # 1. Analizar argumentos pasados al script
    while [[ $# -gt 0 ]]; do
        case "$1" in
            -musicgold)
                MUSIC_GOLD=1
                shift
                ;;
            *)
                if [[ -z "$URL" ]]; then
                    URL="$1"
                else
                    echo "Error: Argumento no reconocido -> $1"
                    echo "Uso: $0 [-musicgold] <URL>"
                    exit 1
                fi
                shift
                ;;
        esac
    done

    if [[ -z "$URL" ]]; then
        echo "Error: Debes proporcionar una URL de YouTube Music."
        echo "Uso: $0 [-musicgold] <URL>"
        exit 1
    fi

    # 2. Limpieza de URL (Remover telemetría o parámetros adicionales)
    # Elimina todo desde el primer '&' hasta el final de la cadena.
    URL="${URL%%&*}"
    echo "URL procesada: $URL"

    # 3. Verificación de dependencias
    local DEPENDENCIAS=("yt-dlp" "ffmpeg" "deno")
    
    if [[ "$MUSIC_GOLD" -eq 1 ]]; then
        DEPENDENCIAS+=("music-gold.sh")
    fi

    for cmd in "${DEPENDENCIAS[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo "Error: '$cmd' no está instalado o no se encuentra en el PATH."
            exit 1
        fi
    done

    echo "Dependencias correctas. Iniciando proceso..."

    # 4. Determinar plantilla de salida según el tipo de enlace
    local OUTPUT_TMPL=""
    if [[ "$URL" == *"list="* ]] || [[ "$URL" == *"playlist"* ]]; then
        echo "Modo: Álbum / Playlist"
        OUTPUT_TMPL="%(artist)s - %(playlist_title|Album)s/%(playlist_index)02d - %(title)s.%(ext)s"
    else
        echo "Modo: Track individual"
        OUTPUT_TMPL="%(artist)s - Sencillos/%(title)s.%(ext)s"
    fi

    # 5. Configurar argumentos base de yt-dlp usando un array de Bash
    local YT_DLP_ARGS=(
        --cookies-from-browser chrome
        --extract-audio
        --audio-format flac
        --audio-quality 0
        --embed-thumbnail
        --embed-metadata
        -o "$OUTPUT_TMPL"
    )

    # 6. Si se activó -musicgold, inyectar el comando post-procesamiento
    if [[ "$MUSIC_GOLD" -eq 1 ]]; then
        echo "Modo Alquimia: Activado (-musicgold)"
        YT_DLP_ARGS+=(
            --exec "bash -c 'cd \"\$(dirname \"\$1\")\" && music-gold.sh \"\$(basename \"\$1\")\" && rm -f \"\$(basename \"\$1\")\"' _ {}"
        )
    fi

    # 7. Ejecutar herramienta
    yt-dlp "${YT_DLP_ARGS[@]}" "$URL"

    # 8. Mensaje final
    echo "Descarga y procesamiento finalizados con éxito."
}

_yt_d "$@"
