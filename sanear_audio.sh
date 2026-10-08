#!/bin/bash

if [ -z "$1" ]; then
    echo "Error: Se requiere un archivo o ruta de carpeta como argumento."
    exit 1
fi

INPUT="${1%/}"
OUT_DIR_NAME="flac-sanos"
SUPPORTED_EXTS=("flac" "wav" "ape" "m4a" "alac")

process_file() {
    local file="$1"
    local out_dir="$2"
    local file_dir=$(dirname "$file")
    local filename=$(basename "$file")
    local ext="${filename##*.}"
    local name="${filename%.*}"
    local out_file="$out_dir/$name.flac"

    # Verificar extensión soportada ignorando mayúsculas/minúsculas
    local is_supported=0
    for e in "${SUPPORTED_EXTS[@]}"; do
        if [ "${ext,,}" = "$e" ]; then
            is_supported=1
            break
        fi
    done

    if [ $is_supported -eq 0 ]; then
        return
    fi

    echo "Saneando y procesando: $filename"

    # Verificar existencia de cover incrustado (stream de video)
    local has_cover=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_type -of default=noprint_wrappers=1:nokey=1 "$file" < /dev/null)

    # -err_detect ignore_err y el comportamiento predeterminado de ffmpeg descartan los "invalid sync code" y basura inicial sin alterar los bits de audio válidos.
    local cmd=("ffmpeg" "-nostdin" "-y" "-err_detect" "ignore_err" "-i" "$file")

    if [ -n "$has_cover" ]; then
        # Extrae la portada original, la estandariza a png manteniendo la resolución nativa y mapea el audio.
        cmd+=("-map" "0:a:0" "-map" "0:v:0" "-c:a" "flac" "-compression_level" "8" "-c:v" "png" "-disposition:v:0" "attached_pic")
    else
        # Buscar cover externo en el mismo directorio si no hay uno incrustado
        shopt -s nullglob nocaseglob
        local ext_images=("$file_dir"/*.jpg "$file_dir"/*.jpeg "$file_dir"/*.png)
        shopt -u nullglob nocaseglob

        if [ ${#ext_images[@]} -gt 0 ]; then
            local cover_img="${ext_images[0]}"
            cmd+=("-i" "$cover_img" "-map" "0:a:0" "-map" "1:v:0" "-c:a" "flac" "-compression_level" "8" "-c:v" "png" "-disposition:v:0" "attached_pic")
        else
            # Procesar solo audio si no existe ninguna portada disponible
            cmd+=("-map" "0:a:0" "-c:a" "flac" "-compression_level" "8")
        fi
    fi

    # -map_metadata 0 conserva todas las etiquetas originales.
    # Al no especificar resampleo o formato, ffmpeg preserva el sample rate y bit depth originales del PCM.
    cmd+=("-map_metadata" "0" "$out_file")

    # Ejecutar en nivel quiet para evitar salida de mensajes y enfocarse en el saneamiento.
    "${cmd[@]}" -loglevel quiet < /dev/null
}

if [ -f "$INPUT" ]; then
    DIR="$(dirname "$INPUT")"
    OUT_DIR="$DIR/$OUT_DIR_NAME"
    mkdir -p "$OUT_DIR"
    process_file "$INPUT" "$OUT_DIR"
elif [ -d "$INPUT" ]; then
    OUT_DIR="$INPUT/$OUT_DIR_NAME"
    mkdir -p "$OUT_DIR"
    find "$INPUT" -maxdepth 1 -type f | while read -r f; do
        process_file "$f" "$OUT_DIR"
    done
else
    echo "Error: La ruta proporcionada no existe o es inválida."
    exit 1
fi

echo "Proceso finalizado. El material saneado se encuentra en: $OUT_DIR"