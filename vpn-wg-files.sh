#!/bin/bash

# Verificar cantidad de argumentos
if [ "$#" -ne 2 ]; then
    echo "Uso: $0 [OPCION] [ARCHIVO.conf | NOMBRE_CONEXION]"
    echo "Opciones:"
    echo "  --instalar    Importa la VPN y desactiva el inicio automático."
    echo "  --conectar    Importa, conecta y reinicia DNS/NTP/Conntrack."
    echo "  --desconectar Desconecta la VPN y reinicia DNS/NTP/Conntrack."
    echo "  --borrar      Elimina la VPN de NetworkManager y reinicia servicios."
    exit 1
fi

ACCION=$1
ARCHIVO=$2
# Extraer el nombre de la conexión (sin la ruta y sin la extensión .conf)
NOMBRE_CONN=$(basename "$ARCHIVO" .conf)

# Función para comprobar si la conexión ya está en NetworkManager
conexion_existe() {
    nmcli connection show "$NOMBRE_CONN" > /dev/null 2>&1
}

# Función para instalar (importar, quitar autoconnect y desconectar)
instalar_vpn() {
    if ! conexion_existe; then
        if [ ! -f "$ARCHIVO" ]; then
            echo "Error: El archivo '$ARCHIVO' no existe en este directorio."
            exit 1
        fi
        echo "Importando '$ARCHIVO' a NetworkManager..."
        sudo nmcli connection import type wireguard file "$ARCHIVO"
        
        echo "Desactivando inicio automático para '$NOMBRE_CONN'..."
        sudo nmcli connection modify "$NOMBRE_CONN" connection.autoconnect no

        echo "Desconectando la interfaz para dejarla en estado inactivo..."
        sudo nmcli connection down "$NOMBRE_CONN" > /dev/null 2>&1
    else
        echo "El perfil '$NOMBRE_CONN' ya está instalado en NetworkManager."
    fi
}

# Función para reiniciar servicios críticos tras cambios en el ruteo
reiniciar_servicios_red() {
    echo "Aplicando medidas de privacidad (DNS, NTP y limpieza de sockets)..."
    
    # Reiniciar DNSCrypt para recalcular servidores DNS por latencia
    sudo systemctl restart dnscrypt-proxy.service dnscrypt-proxy.socket

    # Reiniciar NTP para resolver pool de hora desde la nueva IP de salida
    sudo systemctl restart systemd-timesyncd.service

    # Vaciar la tabla de seguimiento de conexiones del kernel (evita fugas de sockets previos)
    if command -v conntrack >/dev/null 2>&1; then
        sudo conntrack -F >/dev/null 2>&1
    fi
}

case $ACCION in
    --instalar)
        instalar_vpn
        ;;
        
    --conectar)
        instalar_vpn
        echo "Conectando a la VPN '$NOMBRE_CONN'..."
        sudo nmcli connection up "$NOMBRE_CONN"
        reiniciar_servicios_red
        echo "Conectado exitosamente."
        ;;
        
    --desconectar)
        echo "Desconectando la VPN '$NOMBRE_CONN'..."
        sudo nmcli connection down "$NOMBRE_CONN"
        reiniciar_servicios_red
        echo "Desconectado exitosamente."
        ;;
        
    --borrar)
        echo "Borrando la conexión '$NOMBRE_CONN'..."
        if conexion_existe; then
            sudo nmcli connection down "$NOMBRE_CONN" 2>/dev/null
            sudo nmcli connection delete "$NOMBRE_CONN"
            reiniciar_servicios_red
            echo "Conexión eliminada del sistema."
        else
            echo "Error: La conexión '$NOMBRE_CONN' no existe en NetworkManager."
        fi
        ;;
        
    *)
        echo "Opción no válida: $ACCION"
        echo "Usa --instalar, --conectar, --desconectar o --borrar."
        exit 1
        ;;
esac
