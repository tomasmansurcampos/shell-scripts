#!/bin/bash
set -euo pipefail

# Configuración de variables
FIRMWARE_FILE="${1:-}"
INTERFACE="eno1" # Modifique si su interfaz de red tiene otro nombre (ej. eth0)
TFTP_DIR="/srv/tftp"
CONFIG_FILE="/etc/default/tftpd-hpa"
NETPLAN_FILE="/etc/netplan/01-tftp-recovery.yaml"

# Validación de privilegios
if [[ "$EUID" -ne 0 ]]; then
  echo "Error: El script debe ejecutarse con privilegios de root (sudo)." >&2
  exit 1
fi

# Validación del archivo de firmware
if [[ -z "$FIRMWARE_FILE" ]] || [[ ! -f "$FIRMWARE_FILE" ]]; then
  echo "Error: Ruta de archivo de firmware no proporcionada o inválida." >&2
  echo "Uso: $0 /ruta/al/firmware.bin" >&2
  exit 1
fi

# Instalación de dependencias
apt-get update
apt-get install -y tftpd-hpa netplan.io

# Respaldo de configuración original si existe
if [[ -f "$CONFIG_FILE" ]]; then
  cp "$CONFIG_FILE" "${CONFIG_FILE}.original"
fi

# Configuración del servidor TFTP
cat <<EOF > "$CONFIG_FILE"
# /etc/default/tftpd-hpa
TFTP_USERNAME="tftp"
TFTP_DIRECTORY="$TFTP_DIR"
TFTP_ADDRESS="192.168.0.66:69"
TFTP_OPTIONS="-4 --secure -vvv"
EOF

# Preparación del directorio y archivo de recuperación
mkdir -p "$TFTP_DIR"
cp "$FIRMWARE_FILE" "$TFTP_DIR/ArcherC7v5_tp_recovery.bin"
chown -R tftp:tftp "$TFTP_DIR"
chmod 644 "$TFTP_DIR/ArcherC7v5_tp_recovery.bin"

# Configuración temporal de red vía Netplan
cat <<EOF > "$NETPLAN_FILE"
network:
  version: 2
  renderer: networkd
  ethernets:
    $INTERFACE:
      dhcp4: no
      addresses:
        - 192.168.0.66/24
EOF

netplan apply

# Activación del servicio
systemctl enable tftpd-hpa
systemctl restart tftpd-hpa

echo "Servidor TFTP en ejecución en 192.168.0.66. Conecte el Archer C7 al puerto $INTERFACE y enciéndalo presionando el botón Reset/WPS."
read -p "Presione Enter para detener el servidor y limpiar la configuración del sistema..." </dev/tty

# Proceso de restauración y limpieza
rm -f "$NETPLAN_FILE"
netplan apply

if [[ -f "${CONFIG_FILE}.original" ]]; then
  mv "${CONFIG_FILE}.original" "$CONFIG_FILE"
else
  rm -f "$CONFIG_FILE"
fi

rm -f "$TFTP_DIR/ArcherC7v5_tp_recovery.bin"

systemctl stop tftpd-hpa
systemctl disable tftpd-hpa

echo "Limpieza completada."