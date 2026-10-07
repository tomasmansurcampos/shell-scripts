#!/bin/bash

# ==========================================
# CHEQUEO DE DEPENDENCIAS
# ==========================================
chequear_dependencias()
{
    local herramientas=("sox_ng" "soxi_ng" "ffmpeg" "ffprobe" "metaflac" "bc" "flac")
    local falta_algo=0

    echo -e "\n\e[36m 🔍 Revisando el rack de equipos antes de darle al REC... \e[0m"

    for cmd in "${herramientas[@]}"; do
        if ! command -v "$cmd" &> /dev/null; then
            echo -e "\e[31m ❌ Falta una herramienta en el sistema: \e[1;33m$cmd\e[0m"
            falta_algo=1
        fi
    done

    if [[ $falta_algo -eq 1 ]]; then
        echo -e "\n\e[1;41m 🛑 Faltan dependencias 🛑 \e[0m"
        echo -e "\e[31m El script necesita esas herramientas para que la magia suceda.\e[0m"
        echo -e "\e[33m Saliendo sin tocar ni instalar nada... ¡Instalalas y volvé a probar! 🏃‍♂️💨\e[0m\n"
        exit 1
    else
        echo -e "\e[32m ✅ Todo ruteado y en orden. 🎛️\e[0m\n"
    fi
}

ENTRADA="$1"
if [[ -z "$ENTRADA" ]]; then
    echo -e "\e[31m ❌ Error: No se proporcionó ningún archivo ni carpeta. \e[0m"
    exit 1
fi

chequear_dependencias

# ==========================================
# CONSTANTES GLOBALES
# ==========================================

### --- Frecuencia en Hertz de C5, 440*(2**(3/12)) = 523.2511306011972 ---
###
### python3 -c "print(440 * (2**(3/12)))"
### 523.2511306011972
###
### echo "scale=33; 440 * e( (3/12) * l(2) )" | bc -l
### 523.25113060119726935569998704660940

C5=523.25113060119726935569998704660940

### --- formato raw que sox_ng usa internamente ---
RAW_FORMAT="-t raw -b 32 -e floating-point -c 2"

### --- formato wav de alta resolucion para la exportacion final de sox_ng ---
WAV_FORMAT_48="-t wav -b 24 -e signed-integer -r 48000 -c 2"

### --- opciones de sox_ng para mostrar detalles del proceso ---
SOX_ng_GLOBAL_SETTINGS="--single-threaded -V6 -S" # --multi-threaded --buffer 131072 -V6 -S

### --- headroom real para evitar intersample peaks durante el efecto rate ---
GAIN_STAGE="gain -h"

### --- efecto rate y las mejores opciones posibles fieles a la onda original de sonido ---
RATE_EFFECT_48="rate -u -n -t -p 50 -b 95 48k"

### --- norm final, en -0.2 dBFS es casi imposible generar ISP para cualquier DAC ---
FINAL_NORM="norm -0.01"

### --- dither shibata A1 para 24 bits ---
DITHERING="dither -f shibata-A1 -p 24"

echo -e "\e[32m✅ Se hará alquimia musical con Fase Lineal. \e[0m\n"

# ==========================================
# FUNCIONES DE PROCESAMIENTO
# ==========================================

verificar_integridad()
{
    local ext="${ARCHIVO##*.}"
    ext="${ext,,}" # Convertir a minúsculas
    local LOG_ERROR="$DIR_NAME/tracks_corruptos.log"

    echo -e "\n\e[36m 🩺 Chequeando salud del archivo: $(basename "$ARCHIVO") \e[0m"

    if [[ "$ext" == "flac" ]]; then
        # Chequeo nativo y exacto para FLAC
        if ! flac -s -t "$ARCHIVO" 2>/dev/null; then
            echo -e "\e[31m ❌ Archivo FLAC corrupto o dañado. Se saltea este track.\e[0m"
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR FLAC: $(basename "$ARCHIVO")" >> "$LOG_ERROR"
            return 1
        fi
    else
        # Chequeo universal con FFmpeg para WAV, AIFF, etc.
        if ! ffmpeg -v error -i "$ARCHIVO" -f null - 2>/dev/null; then
            echo -e "\e[31m ❌ Archivo corrupto detectado. Se saltea este track.\e[0m"
            echo "[$(date +'%Y-%m-%d %H:%M:%S')] ERROR AUDIO: $(basename "$ARCHIVO")" >> "$LOG_ERROR"
            return 1
        fi
    fi

    echo -e "\e[32m ✅ Archivo sano. Listo para procesar.\e[0m"
    return 0
}

error_salida()
{
    echo -e "\n\e[1;41m  ⚠️  ¡Epa! Hubo un problema técnico  ⚠️  \e[0m"
    echo -e "\e[31m ❌ No se pudo completar la reafinación de: $FILE_NAME \e[0m"
    
    echo -e "\e[33m 🧹 Intentando limpiar archivos temporales antes de salir... \e[0m"
    rm -vf "$TEMP_WAV"
    
    echo -e "\e[31m 👋 Proceso abortado para este track. Pasando al siguiente si hay... \e[0m\n"
    return 1
}

limpieza_inicial()
{
    echo -e "\n\e[33m 🔎 Borrando archivos temporales y previos 🔎\e[0m"
    rm -vrf "$TEMP_WAV"
    echo -e "\e[33m ✅ Limpieza inicial completada. 🗑️\e[0m\n"
}

reafinacion_y_resampleo_absoluto()
{
    echo -e "\n\e[45m 🙏 Iniciando Reafinación y Resampleo Máster 🙏...\e[0m"
    
    local SR_ORIGINAL=$(soxi_ng -r "$ARCHIVO")

    echo -e "\n\e[1;34m=========================================================\e[0m"
    echo -e "\e[1;36m 🎵 PROCESANDO: $ARCHIVO (Sample Rate: ${SR_ORIGINAL}Hz) 🎵\e[0m"
    echo -e "\e[1;34m=========================================================\e[0m"
    
    local DYNAMIC_MAGIC_TRICK=$(echo "scale=15; ($SR_ORIGINAL * 528) / $C5" | bc)
    local DYNAMIC_RAW_TRICK="-t raw -b 32 -e floating-point -c 2 -r $DYNAMIC_MAGIC_TRICK"
    
    echo -e "\e[36m ℹ️ Sample Rate Original: ${SR_ORIGINAL}Hz -> Frecuencia Mágica: ${DYNAMIC_MAGIC_TRICK}Hz \e[0m"
    
    # ==========================================
	# PIPELINE SOX_ng (DEBUG vs PERFORMANCE)
	# ==========================================
	
	### Siempre usar DEBUG, nunca hay que usar PERFORMANCE.
	
    ### Con un archivo de audio pesado o de larga duracion,
    ### el PERFORMANCE mode puede generar microcortes en la CPU por uso excesivo de RAM/SWAP.
    ### Por defecto se hace el DEBUG mode.
	DEBUG_MODE="${DEBUG_MODE:-1}"  # 1 = debug legible, 0 = pipeline rápido

    ### En PERFORMANCE mode hace así:
    ### Convierte el archivo de audio original a formato RAW de 32 bits floating-point
    ### porque internamente SOX_ng trabaja en ese formato, y lo pasamos como pipe
    ### al segundo comando SOX_ng que hará la alquimia musical,
    ### y luego lo exporta a un .wav de 24 bits fixed con las mejores opciones de efecto rate,
    ### luego normalizacion y finalmente un dither moderno preciso para ese wav de 24 bits.

	### Para prevenir microcortes de CPU o uso excesivo de RAM,
	### incluso tambien para evitar que todo el sistema no reaccione por cortes de I/O en CPU y RAM,
	### es mejor siempre sacrificar I/O de escritura al disco antes que hacer colapsar al sistema.
	if [[ "$DEBUG_MODE" -eq 1 ]]; then
		echo -e "\e[33m 🧪 DEBUG MODE activado → usando archivo intermedio RAW\e[0m"
		
		TEMP_RAW="${FILE_NAME}_TEMP.raw"

		# Etapa 1: decode + float raw
		echo -e "\e[36m [1/2] Generando RAW intermedio...\e[0m"
		sox_ng $SOX_ng_GLOBAL_SETTINGS "$ARCHIVO" $RAW_FORMAT "$TEMP_RAW" \
		    || { error_salida; return 1; }

		# Etapa 2: DSP + resample + export
		echo -e "\e[36m [2/2] Procesando RAW → WAV final...\e[0m"
		sox_ng $SOX_ng_GLOBAL_SETTINGS $DYNAMIC_RAW_TRICK "$TEMP_RAW" $WAV_FORMAT_48 "$TEMP_WAV" \
		    $GAIN_STAGE \
		    $RATE_EFFECT_48 \
		    $FINAL_NORM \
		    $DITHERING \
		    || { error_salida; return 1; }

		# Limpieza RAW intermedio
		rm -vf "$TEMP_RAW"

	else
		echo -e "\e[32m 🚀 PERFORMANCE MODE → pipeline en RAM\e[0m"

        date -u >> sox_ng_stage1.log
        date -u >> sox_ng_stage2.log

		sox_ng $SOX_ng_GLOBAL_SETTINGS "$ARCHIVO" $RAW_FORMAT - 2>>sox_ng_stage1.log | \
		sox_ng $SOX_ng_GLOBAL_SETTINGS $DYNAMIC_RAW_TRICK - $WAV_FORMAT_48 "$TEMP_WAV" \
		    $GAIN_STAGE \
		    $RATE_EFFECT_48 \
		    $FINAL_NORM \
		    $DITHERING \
		    2>>sox_ng_stage2.log || { error_salida; return 1; }
	fi

    echo -e "\n\e[45m ✅✅✅ Reafinacion musical realizada exitosamente ... ✅✅✅ \e[0m"
}

exportar_musica_metadatos_a_FLAC()
{
    echo -e "\n\e[45m 🔎 Insertando metadatos y analizando arte de tapa... \e[0m"

    TEMP_COVER="${DIR_NAME}/temp_gold_cover.jpg"
    COVER_READY=0

    HAS_VIDEO=$(ffprobe -v error -show_streams -select_streams v "$ARCHIVO")

    if [[ -n "$HAS_VIDEO" ]]; then
        echo -e "\e[32m ✅ El original ya tiene carátula. Estandarizándola para máxima compatibilidad... \e[0m"
        ffmpeg -hide_banner -loglevel error -i "$ARCHIVO" -map 0:v:0 \
               -vf "scale=1024:1024:force_original_aspect_ratio=decrease" \
               -pix_fmt yuv420p -q:v 2 "$TEMP_COVER" -y
        [[ -f "$TEMP_COVER" ]] && COVER_READY=1
    else
        echo -e "\e[33m ℹ️ El original no tiene foto. Buscando en la carpeta '$DIR_NAME'... \e[0m"
        
        POSIBLES_NOMBRES=("cover" "front" "folder" "album" "poster")
        PORTADA=""

        for nombre in "${POSIBLES_NOMBRES[@]}"; do
            PORTADA=$(find "$DIR_NAME" -maxdepth 1 -iname "*$nombre*" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)
            [[ -n "$PORTADA" ]] && break
        done

        if [[ -z "$PORTADA" ]]; then
            PORTADA=$(find "$DIR_NAME" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)
        fi

        if [[ -z "$PORTADA" ]]; then
            for subcarpeta in "Covers" "Booklet" "covers" "booklet"; do
                if [[ -d "$DIR_NAME/$subcarpeta" ]]; then
                    echo -e "\e[36m 🕵️ Buscando en subcarpeta '$subcarpeta'... \e[0m"
                    for nombre in "${POSIBLES_NOMBRES[@]}"; do
                        PORTADA=$(find "$DIR_NAME/$subcarpeta" -maxdepth 1 -iname "*$nombre*" \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)
                        [[ -n "$PORTADA" ]] && break
                    done
                    
                    if [[ -z "$PORTADA" ]]; then
                        PORTADA=$(find "$DIR_NAME/$subcarpeta" -maxdepth 1 \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" \) | head -n 1)
                    fi
                    [[ -n "$PORTADA" ]] && break
                fi
            done
        fi

        if [[ -n "$PORTADA" ]]; then
            echo -e "\e[36m ⚙️ Preparando imagen encontrada: '$(basename "$PORTADA")'... \e[0m"
            ffmpeg -hide_banner -loglevel error -i "$PORTADA" \
                   -vf "scale=1024:1024:force_original_aspect_ratio=decrease" \
                   -pix_fmt yuv420p -q:v 2 "$TEMP_COVER" -y
            [[ -f "$TEMP_COVER" ]] && COVER_READY=1
        fi
    fi

    local FFMPEG_STATUS=0

    echo -e "\e[32m 🎵 Armando FLAC base con audio y metadatos de texto... \e[0m"
    
    # armamos el flac final con nivel de compresion 8 para ahorrar maximo espacio posible.
    ffmpeg -hide_banner -loglevel error -i "$TEMP_WAV" -i "$ARCHIVO" \
           -map 0:a -map_metadata 1 \
           -c:a flac -compression_level 8 \
           "$TRACK_FINAL" -y
           
    FFMPEG_STATUS=$?

    if [[ $FFMPEG_STATUS -eq 0 ]]; then
        if [[ $COVER_READY -eq 1 ]]; then
            echo -e "\e[32m 📸 Incrustando carátula al track GOLD (Modo Dios con metaflac)... \e[0m"
            
            # removemos todo rastro de caratula.
            metaflac --remove --block-type=PICTURE --dont-use-padding "$TRACK_FINAL"
            metaflac --remove-tag=COVERART --dont-use-padding "$TRACK_FINAL"
            
            # agregamos la caratula de forma correcta.
            metaflac --import-picture-from="$TEMP_COVER" "$TRACK_FINAL"
            
            rm -vf "$TEMP_COVER"
        else
            echo -e "\e[33m ⚠️ No se encontró foto. FLAC generado sin carátula. \e[0m"
        fi
        
        echo -e "\e[32m ✅ ¡Archivo \e[1;36m'$(basename "$TRACK_FINAL")'\e[0m\e[32m creado con éxito en G33! \e[0m"
    else
        echo -e "\e[31m ❌ Error en la conversión final de FFmpeg. \e[0m"
        error_salida
        return 1
    fi
}

limpieza_final()
{
    echo -e "\n\e[33m 🔎 Borrando archivos temporales de forma segura 🔎\e[0m"
    rm -vf "$TEMP_WAV"
    echo -e "\e[33m ✅ Archivos temporales eliminados con éxito. 🗑️\e[0m"
}

exito()
{
    echo -e "\n\e[32m ✨ ¡Proceso de reafinación completado con éxito! ✨\e[0m"
    echo -e "\e[32m 💎 ¡'$(basename "$TRACK_FINAL")' listo para brillar en G33! 💎\e[0m\n"
}

# ==========================================
# FUNCIÓN MAESTRA (Ejecuta la secuencia por archivo)
# ==========================================
procesar_archivo()
{
    local ARCHIVO="$1"
    local DIR_NAME=$(dirname "$ARCHIVO")
    local FILE_NAME="${ARCHIVO%.*}"
    
    local TEMP_WAV="${FILE_NAME}_TEMP_GOLD.wav"

    local DIR_G33="$DIR_NAME/G33"
    mkdir -vp "$DIR_G33"
    
    local TRACK_FINAL="$DIR_G33/$(basename "$FILE_NAME")_GOLD_.flac"

    # Filtro de seguridad inicial
    verificar_integridad || return 1

	# Para limpiar archivos temporales anteriores por las dudas.
    limpieza_inicial
    
    # La Alquimia a 528Hz.
    reafinacion_y_resampleo_absoluto || return 1
    
    # El archivo GOLD .wav de 24/48, es convertido a .flac nivel 8 24/48,
    # y se trata de ponerle caratula a ese flac.
    exportar_musica_metadatos_a_FLAC || return 1
    
    # Para limpiar archivos temporales.
    limpieza_final
    
    # Yey.
    exito
}

# ==========================================
# LÓGICA PRINCIPAL: ¿ES ARCHIVO O CARPETA?
# ==========================================

if [[ -f "$ENTRADA" ]]; then
    procesar_archivo "$ENTRADA"

elif [[ -d "$ENTRADA" ]]; then
    echo -e "\n\e[44m 📂 Modo Carpeta activado. Buscando archivos de audio en '$ENTRADA'...\e[0m"
    
    shopt -s nullglob
    for audio_file in "$ENTRADA"/*.{flac,wav,aiff,FLAC,WAV,AIFF}; do
        if [[ "$audio_file" != *"_GOLD_p0.flac" && "$audio_file" != *"_GOLD_p25.flac" && "$audio_file" != *"_GOLD_p50.flac" ]]; then
            procesar_archivo "$audio_file"
        fi
    done
    shopt -u nullglob
    
    echo -e "\n\e[1;32m 🎉 ¡Toda la carpeta fue barrida y procesada con éxito! 🎉\e[0m\n"

else
    echo -e "\e[31m ❌ Error: '$ENTRADA' no es un archivo ni un directorio válido. \e[0m"
    exit 1
fi

### sox_ng -V6 -S -n -t wav -b 24 -e signed-integer -r 48000 -c 2 440.wav synth 3600 sine 440 norm -15
### sox_ng -V6 -S -n -t wav -b 24 -e signed-integer -r 48000 -c 2 528.wav synth 3600 sine 528 norm -15
### sox_ng -V6 -S -n -t wav -b 24 -e signed-integer -r 48000 -c 2 C5_sine_mdecs_.wav synth 3600 sine 523.25113060119726935569998704660940 norm -15


