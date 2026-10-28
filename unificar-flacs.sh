#!/bin/bash

# Comprobar si hay archivos .flac en el directorio
if ! ls *.flac >/dev/null 2>&1; then
    echo "Error: No se encontraron archivos .flac en el directorio actual."
    exit 1
fi

# Eliminar list.txt si ya existe
> list.txt

# Obtener el primer archivo para extraer metadatos base
FIRST_FILE=$(ls -1v *.flac | head -n 1)

# Extraer metadatos con ffprobe
ARTIST=$(ffprobe -v quiet -show_entries format_tags=artist -of default=noprint_wrappers=1:nokey=1 "$FIRST_FILE")
ALBUM=$(ffprobe -v quiet -show_entries format_tags=album -of default=noprint_wrappers=1:nokey=1 "$FIRST_FILE")
DATE=$(ffprobe -v quiet -show_entries format_tags=date -of default=noprint_wrappers=1:nokey=1 "$FIRST_FILE")

# Si el tag date está vacío, intentar buscar por year
if [ -z "$DATE" ]; then
    DATE=$(ffprobe -v quiet -show_entries format_tags=year -of default=noprint_wrappers=1:nokey=1 "$FIRST_FILE")
fi

TOTAL_TRACKS=$(ls -1v *.flac | wc -l)

# Manejar la imagen de portada
COVER_IMG=""
TEMP_COVER="temp_cover_extracted.jpg"

# Intentar extraer la portada embebida del primer archivo .flac
ffmpeg -y -i "$FIRST_FILE" -an -vframes 1 "$TEMP_COVER" >/dev/null 2>&1

if [ -s "$TEMP_COVER" ]; then
    COVER_IMG="$TEMP_COVER"
else
    rm -f "$TEMP_COVER"
    # Buscar la primera imagen disponible en el directorio (sin importar mayúsculas/minúsculas)
    LOCAL_IMG=$(ls -1 *.[jJ][pP][gG] *.[jJ][pP][eE][gG] *.[pP][nN][gG] 2>/dev/null | head -n 1)
    if [ -n "$LOCAL_IMG" ]; then
        COVER_IMG="$LOCAL_IMG"
    fi
fi

# Generar la lista de archivos para concatenar ordenada numéricamente
ls -1v *.flac | while read -r file; do
    safe_name=$(echo "$file" | sed "s/'/'\\\\''/g")
    echo "file '$safe_name'" >> list.txt
done

# Construir y ejecutar el comando ffmpeg final mapeando metadatos e imagen
if [ -n "$COVER_IMG" ]; then
    ffmpeg -f concat -safe 0 -i list.txt -i "$COVER_IMG" \
        -map 0:a -map 1:v \
        -c:a flac -c:v copy -disposition:v attached_pic \
        -metadata artist="$ARTIST" \
        -metadata album="$ALBUM" \
        -metadata date="$DATE" \
        -metadata track="1/$TOTAL_TRACKS" \
        salida_completa.flac
else
    ffmpeg -f concat -safe 0 -i list.txt \
        -map 0:a \
        -c:a flac \
        -metadata artist="$ARTIST" \
        -metadata album="$ALBUM" \
        -metadata date="$DATE" \
        -metadata track="1/$TOTAL_TRACKS" \
        salida_completa.flac
fi

# Limpiar archivos temporales en disco
rm -f list.txt "$TEMP_COVER"

echo "Unificación finalizada: salida_completa.flac"
