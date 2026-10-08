#!/bin/bash

### Este script Bash configura un dispositivo de almacenamiento externo
### utilizando Btrfs y LUKS, nombrando el volumen dinámicamente 
### según el hardware y su capacidad de almacenamiento.

# 1. Validación del argumento de entrada
if [ -z "$1" ]; then
    echo "Error: Se requiere especificar el dispositivo."
    echo "Uso: $0 /dev/sdX"
    exit 1
fi

DEVICE=$1
PARTITION="${DEVICE}1"

# 2. Validación de dispositivo de bloques
if [ ! -b "$DEVICE" ]; then
    echo "Error: $DEVICE no existe o no es un dispositivo de bloques válido."
    exit 1
fi

# 3. Detección de hardware, modelo y capacidad
BASENAME=$(basename "$DEVICE")
ROTA=$(cat /sys/block/"$BASENAME"/queue/rotational 2>/dev/null)
REMOVABLE=$(cat /sys/block/"$BASENAME"/removable 2>/dev/null)

# Extraer el modelo y limpiar espacios
RAW_MODEL=$(lsblk -d -n -o MODEL "$DEVICE" 2>/dev/null)
CLEAN_MODEL=$(echo "$RAW_MODEL" | tr -d ' ')

# Extraer capacidad en bytes y formatear a sufijo (GB o TB)
BYTES=$(lsblk -b -d -n -o SIZE "$DEVICE" 2>/dev/null)
SIZE_SUFFIX=$(LC_ALL=C awk -v b="$BYTES" 'BEGIN {
    gb = b / 1073741824
    if (gb >= 1000) {
        tb = b / 1099511627776
        printf "%.1fTB", tb
    } else {
        printf "%dG", gb
    }
}')

# Configuración según el tipo de hardware
if [ "$ROTA" -eq 1 ] && [ "$REMOVABLE" -eq 0 ]; then
    TYPE="HDD (Mecánico)"
    OPTS="defaults,autodefrag,compress=zstd,noatime"
    BASE_LABEL=${CLEAN_MODEL:-"HDD_BAK"}
else
    TYPE="Pendrive/SSD (Flash)"
    OPTS="defaults,compress=zstd,noatime"
    BASE_LABEL=${CLEAN_MODEL:-"Pendrive_BAK"}
fi

# Ensamblar etiqueta final (Modelo + Capacidad)
LABEL="${BASE_LABEL}-${SIZE_SUFFIX}"

# Generar identificador para el mapper y montaje (en minúsculas)
MAPPER=$(echo "$LABEL" | tr '[:upper:]' '[:lower:]')
MOUNT_DIR="/mnt/$MAPPER"

# 4. Advertencia y confirmación del usuario
echo "======================================================================"
echo "ATENCIÓN: EL SIGUIENTE PROCESO ES IRREVERSIBLE"
echo "======================================================================"
echo "Dispositivo destino : $DEVICE ($TYPE)"
echo "Modelo detectado    : ${RAW_MODEL:-Desconocido}"
echo "Capacidad detectada : $SIZE_SUFFIX"
echo "Se eliminará TODA la información y tabla de particiones actual."
echo ""
echo "Configuración técnica a aplicar:"
echo "- Etiqueta Btrfs  : $LABEL"
echo "- Nodo LUKS       : /dev/mapper/$MAPPER"
echo "- Opciones Btrfs  : $OPTS"
echo "======================================================================"
read -p "¿Confirma que desea continuar y formatear $DEVICE? (Yes/No): " CONFIRM

if [ "$CONFIRM" != "Yes" ] && [ "$CONFIRM" != "yes" ]; then
    echo "Operación cancelada. No se han realizado cambios."
    exit 0
fi

# 5. Ejecución del particionado, cifrado y formato
echo "[*] Desmontando posibles particiones previas..."
sudo umount "${DEVICE}"* 2>/dev/null

echo "[*] Mostrando estado inicial del disco:"
lsblk "$DEVICE"

echo "[*] Creando tabla de particiones GPT..."
sudo parted -s "$DEVICE" mklabel gpt || exit 1
sudo parted -s "$DEVICE" mkpart primary btrfs 0% 100% || exit 1

# Esperar al sistema operativo para que registre el nuevo nodo de bloque
sleep 2

echo "[*] Aplicando cifrado LUKS a $PARTITION..."
sudo cryptsetup luksFormat "$PARTITION" || exit 1

echo "[*] Abriendo contenedor LUKS..."
sudo cryptsetup open "$PARTITION" "$MAPPER" || exit 1

echo "[*] Aplicando formato de sistema de archivos Btrfs..."
sudo mkfs.btrfs -L "$LABEL" /dev/mapper/"$MAPPER" || exit 1

echo "[*] Creando directorio y montando sistema de archivos..."
sudo mkdir -p "$MOUNT_DIR"
sudo mount -o "$OPTS" /dev/mapper/"$MAPPER" "$MOUNT_DIR" || exit 1

echo "[*] Asignando permisos al usuario 'tomas'..."
sudo chown -R tomas:tomas "$MOUNT_DIR"

echo "[*] Proceso finalizado correctamente."
lsblk -f "$DEVICE"

echo ""
echo "======================================================================"
echo "IMPORTANTE: Antes de retirar físicamente el dispositivo, ejecute los"
echo "siguientes comandos de forma secuencial para evitar corrupción de datos:"
echo ""
echo "  sudo umount $MOUNT_DIR"
echo "  sudo cryptsetup close $MAPPER"
echo "======================================================================"