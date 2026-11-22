
#!/usr/bin/env bash

set -Eeuo pipefail

# ============================================================
# SANEAR-AUDIO
# Normalización y conversión de audio lossless a FLAC.
# ============================================================

readonly OUT_DIR_NAME="flac-sanos"
readonly COMPRESSION_LEVEL=8

SUPPORTED_EXTS=(
    flac wav ape m4a alac wv tta tak
)

# ============================================================
# DEPENDENCIAS
# ============================================================

for cmd in ffmpeg ffprobe jq mktemp base64 sed find ln; do
    if ! command -v "$cmd" >/dev/null 2>&1; then
        printf 'ERROR: Falta la dependencia: %s\n' "$cmd" >&2
        exit 1
    fi
done

# ============================================================
# ARGUMENTOS
# ============================================================

if [[ $# -ne 1 ]]; then
    echo "Uso: $0 <archivo o directorio>"
    exit 1
fi

INPUT="${1%/}"
[[ -z "$INPUT" ]] && INPUT="/"

if [[ ! -e "$INPUT" ]]; then
    echo "ERROR: La ruta no existe."
    exit 1
fi

if [[ ! -f "$INPUT" && ! -d "$INPUT" ]]; then
    echo "ERROR: La ruta no es un archivo ni un directorio."
    exit 1
fi

# ============================================================
# VALIDACIÓN DE EXTENSIONES Y CÓDECS
# ============================================================

is_supported() {
    local ext="${1,,}"
    local item

    for item in "${SUPPORTED_EXTS[@]}"; do
        [[ "$ext" == "$item" ]] && return 0
    done

    return 1
}

is_lossless_codec() {
    case "$1" in
        flac|ape|alac|wavpack|tta|tak|shorten|wmalossless|mlp|truehd)
            return 0
            ;;
        pcm_s*|pcm_u*|pcm_f*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ============================================================
# EXTRACCIÓN DE NÚMEROS
# ============================================================

extract_number() {
    local value="$1"

    if [[ "$value" =~ ([0-9]+) ]]; then
        printf '%d' "$((10#${BASH_REMATCH[1]}))"
    fi
}

extract_total() {
    local value="$1"

    if [[ "$value" =~ [0-9]+[[:space:]]*/[[:space:]]*([0-9]+) ]]; then
        printf '%d' "$((10#${BASH_REMATCH[1]}))"

    elif [[ "$value" =~ [0-9]+[[:space:]]+(of|de)[[:space:]]+([0-9]+) ]]; then
        printf '%d' "$((10#${BASH_REMATCH[2]}))"
    fi
}

# ============================================================
# NORMALIZACIÓN DE NOMBRES
# ============================================================

sanitize_filename() {
    local name="$1"

    name="$(
        printf '%s' "$name" |
        sed -E '
            s/[[:cntrl:]]/ /g
            s#[/\\]#-#g
            s/[:*?"<>|]/_/g
            s/[[:space:]]+/ /g
            s/^[ .]+//
            s/[ .]+$//
        '
    )"

    [[ -z "$name" ]] && name="audio"

    printf '%s' "$name"
}

# ============================================================
# LECTURA DE METADATOS
# ============================================================

read_metadata() {
    local file="$1"
    local metadata

    declare -gA TAGS=()

    metadata="$(
        ffprobe \
            -v error \
            -show_format \
            -show_streams \
            -of json \
            "$file"
    )" || return 1

    # IMPORTANTE:
    # Se leen exclusivamente:
    # 1. Metadatos generales del archivo.
    # 2. Metadatos del primer stream de audio.
    #
    # Se ignoran los metadatos de imágenes y portadas.

    while IFS=$'\t' read -r key encoded; do
        [[ -z "$key" ]] && continue

        TAGS["$key"]="$(printf '%s' "$encoded" | base64 -d)"
    done < <(
        jq -r '
            (
                (.format.tags // {})
                +
                (
                    [
                        .streams[]?
                        | select(.codec_type == "audio")
                        | (.tags // {})
                    ][0] // {}
                )
            )
            | to_entries[]
            | [
                (
                    .key
                    | ascii_downcase
                    | gsub("[^a-z0-9]"; "")
                ),
                (.value | tostring | @base64)
            ]
            | @tsv
        ' <<< "$metadata"
    )
}

get_tag() {
    local key

    for key in "$@"; do
        if [[ -n "${TAGS[$key]:-}" ]]; then
            printf '%s' "${TAGS[$key]}"
            return 0
        fi
    done

    return 1
}

# ============================================================
# GENERACIÓN DEL NOMBRE DEL ARCHIVO
# ============================================================

generate_filename() {
    local original_name="$1"

    local title=""
    local track_raw=""
    local disc_raw=""
    local total_raw=""

    local track_number=""
    local disc_number=""
    local total_discs=""

    title="$(get_tag \
        title songtitle tracktitle tracketittle || true)"

    track_raw="$(get_tag \
        tracknumber track trackno tracknum trackid || true)"

    disc_raw="$(get_tag \
        discnumber disknumber disc disk cdnumber cd || true)"

    total_raw="$(get_tag \
        totaldiscs totaldisks disctotal disktotal || true)"

    track_number="$(extract_number "$track_raw" || true)"
    disc_number="$(extract_number "$disc_raw" || true)"
    total_discs="$(extract_number "$total_raw" || true)"

    if [[ -z "$total_discs" ]]; then
        total_discs="$(extract_total "$disc_raw" || true)"
    fi

    # Sin título o número de pista:
    # conservar el nombre original.

    if [[ -z "$title" || -z "$track_number" ]]; then
        printf '%s.flac' "$(sanitize_filename "$original_name")"
        return 0
    fi

    title="$(sanitize_filename "$title")"

    local track_int=$((10#$track_number))
    local disc_int=1
    local multi_disc=0

    if [[ -n "$disc_number" ]]; then
        disc_int=$((10#$disc_number))
    fi

    if [[ -n "$total_discs" ]] && (( total_discs > 1 )); then
        multi_disc=1
    elif (( disc_int > 1 )); then
        multi_disc=1
    fi

    local track_fmt
    local disc_fmt

    printf -v track_fmt '%02d' "$track_int"

    if (( multi_disc )); then

        printf -v disc_fmt '%02d' "$disc_int"

        printf '%s-%s. %s.flac' \
            "$disc_fmt" \
            "$track_fmt" \
            "$title"

    else

        printf '%s. %s.flac' \
            "$track_fmt" \
            "$title"

    fi
}

# ============================================================
# DETECCIÓN DE PORTADA INCRUSTADA
# ============================================================

find_embedded_cover() {
    local file="$1"

    ffprobe \
        -v error \
        -show_streams \
        -of json \
        "$file" |
    jq -r '
        [
            .streams[]?
            | select((.disposition.attached_pic // 0) == 1)
            | .index
        ][0] // empty
    '
}

# ============================================================
# BÚSQUEDA DE PORTADA EXTERNA
# ============================================================

find_external_cover() {
    local directory="$1"
    local image
    local basename_lower

    shopt -s nullglob nocaseglob

    local -a images=(
        "$directory"/*.jpg
        "$directory"/*.jpeg
        "$directory"/*.png
    )

    shopt -u nullglob nocaseglob

    (( ${#images[@]} > 0 )) || return 0

    # Priorizar portadas habituales.

    for image in "${images[@]}"; do
        basename_lower="${image##*/}"
        basename_lower="${basename_lower,,}"

        case "$basename_lower" in
            cover.jpg|cover.jpeg|cover.png|\
            folder.jpg|folder.jpeg|folder.png|\
            front.jpg|front.jpeg|front.png)
                printf '%s' "$image"
                return 0
                ;;
        esac
    done

    # Si no hay una portada identificable,
    # utilizar la primera imagen encontrada.

    printf '%s' "${images[0]}"
}

# ============================================================
# PROCESAMIENTO DE ARCHIVOS
# ============================================================

process_file() {
    local file="$1"
    local out_dir="$2"

    local filename
    local file_dir
    local ext
    local original_name

    local audio_codec
    local output_name
    local output_file
    local temp_file

    local cover_index
    local external_cover=""

    filename="${file##*/}"
    file_dir="${file%/*}"
    [[ "$file_dir" == "$file" ]] && file_dir="."

    ext="${filename##*.}"
    original_name="${filename%.*}"

    if ! is_supported "$ext"; then
        return 0
    fi

    echo
    echo "============================================================"
    echo "Procesando: $filename"
    echo "============================================================"

    # Verificar lectura del archivo.

    if ! ffprobe -v error "$file" >/dev/null 2>&1; then
        echo "ERROR: Archivo ilegible."
        return 1
    fi

    # Identificar el códec original.

    audio_codec="$(
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries stream=codec_name \
            -of default=noprint_wrappers=1:nokey=1 \
            "$file"
    )" || return 1

    if ! is_lossless_codec "$audio_codec"; then
        echo "OMITIDO: Códec no reconocido como lossless: $audio_codec"
        return 0
    fi

    echo "Códec original: $audio_codec"

    # Leer metadatos.

    if ! read_metadata "$file"; then
        echo "ERROR: No se pudieron leer los metadatos."
        return 1
    fi

    # Generar nombre normalizado.

    output_name="$(generate_filename "$original_name")"
    output_file="$out_dir/$output_name"

    echo "Archivo original: $filename"
    echo "Archivo final:    $output_name"

    # Evitar sobrescrituras.

    if [[ -e "$output_file" ]]; then
        echo "OMITIDO: El destino ya existe."
        return 0
    fi

    # Buscar portada incrustada.

    cover_index="$(find_embedded_cover "$file")" || return 1

    # Crear archivo temporal único.

    temp_file="$(mktemp "$out_dir/.flac-sano.XXXXXX.flac")" || return 1

    # Preparar comando FFmpeg.

    local -a cmd=(
        ffmpeg
        -nostdin
        -hide_banner
        -loglevel warning
        -y
        -i "$file"

        -map 0:a:0
        -map_metadata 0
        -map_metadata:s:a:0 0:s:a:0
        -map_chapters 0

        -c:a flac
        -compression_level "$COMPRESSION_LEVEL"
    )

    if [[ -n "$cover_index" ]]; then

        echo "Portada: incrustada (se conserva sin recodificar)"

        cmd+=(
            -map "0:$cover_index"
            -c:v copy
            -disposition:v:0 attached_pic
            -map_metadata:s:v:0 -1
        )

    else

        # Buscar portada externa.

        external_cover="$(find_external_cover "$file_dir")"

        if [[ -n "$external_cover" ]]; then

            echo "Portada externa: ${external_cover##*/}"

            cmd+=(
                -i "$external_cover"
                -map 1:v:0
                -c:v copy
                -disposition:v:0 attached_pic
            )

        else

            echo "Portada: no encontrada"

        fi
    fi

    # Formato de salida.

    cmd+=(
        -f flac
        "$temp_file"
    )

    echo "Codificando FLAC nivel $COMPRESSION_LEVEL..."

    # Ejecutar conversión.

    if ! "${cmd[@]}"; then
        echo "ERROR: Falló la conversión."
        rm -f -- "$temp_file"
        return 1
    fi

    # Verificar que el archivo sea FLAC válido.

    local result_codec

    result_codec="$(
        ffprobe \
            -v error \
            -select_streams a:0 \
            -show_entries stream=codec_name \
            -of default=noprint_wrappers=1:nokey=1 \
            "$temp_file"
    )" || result_codec=""

    if [[ "$result_codec" != "flac" ]]; then
        echo "ERROR: El archivo generado no es un FLAC válido."
        rm -f -- "$temp_file"
        return 1
    fi

    # Publicar mediante enlace duro:
    # operación atómica que no sobrescribe destinos existentes.

    if ! ln -- "$temp_file" "$output_file"; then
        echo "ERROR: No se pudo publicar el archivo final."
        rm -f -- "$temp_file"
        return 1
    fi

    rm -f -- "$temp_file"

    echo "OK: Archivo generado correctamente."

    return 0
}

# ============================================================
# EJECUCIÓN PRINCIPAL
# ============================================================

if [[ -f "$INPUT" ]]; then

    DIR="${INPUT%/*}"
    [[ "$DIR" == "$INPUT" ]] && DIR="."

    OUT_DIR="$DIR/$OUT_DIR_NAME"

    mkdir -p -- "$OUT_DIR"

    failed=0

    process_file "$INPUT" "$OUT_DIR" || failed=1

else

    OUT_DIR="$INPUT/$OUT_DIR_NAME"

    mkdir -p -- "$OUT_DIR"

    failed=0

    while IFS= read -r -d '' file; do
        process_file "$file" "$OUT_DIR" || failed=$((failed + 1))
    done < <(
        find "$INPUT" -maxdepth 1 -type f -print0
    )

fi

# ============================================================
# RESULTADO
# ============================================================

echo
echo "============================================================"
echo "Proceso finalizado."
echo "Material saneado: $OUT_DIR"
echo "Errores: $failed"
echo "============================================================"

(( failed == 0 )) || exit 1
