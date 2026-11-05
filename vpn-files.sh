#!/bin/bash

# Verificar cantidad de argumentos
if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
    echo "Uso: $0 [OPCION] [ARCHIVO.conf/.ovpn | NOMBRE_CONEXION]"
    echo "Opciones:"
    echo "  --instalar    Importa la VPN y desactiva el inicio automático."
    echo "  --conectar    Importa, conecta y aplica kill switch dinámico."
    echo "  --desconectar Desconecta la VPN (o todas si no se especifica), limpia firewall y reinicia red."
    echo "  --borrar      Elimina la VPN de NetworkManager y reinicia servicios."
    exit 1
fi

ACCION=$1
ARCHIVO=$2

# Validar argumento y extraer nombre base eliminando extensiones .conf o .ovpn
if [ -n "$ARCHIVO" ]; then
    NOMBRE_CONN=$(basename "$ARCHIVO" | sed -E 's/\.(conf|ovpn)$//')
elif [ "$ACCION" != "--desconectar" ]; then
    echo "Error: La opción $ACCION requiere especificar un archivo o nombre de conexión."
    exit 1
fi

# Función para determinar si el archivo es WireGuard u OpenVPN
detectar_tipo_vpn() {
    local config_file="$1"
    if grep -qiE "^\[Interface\]" "$config_file" && grep -qiE "^\[Peer\]" "$config_file"; then
        echo "wireguard"
    elif grep -qiE "^client" "$config_file" || grep -qiE "^dev tun" "$config_file"; then
        echo "openvpn"
    else
        echo "desconocido"
    fi
}

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
        
        TIPO_VPN=$(detectar_tipo_vpn "$ARCHIVO")
        if [ "$TIPO_VPN" = "desconocido" ]; then
            echo "Error: No se pudo determinar el formato del archivo (WireGuard u OpenVPN)."
            exit 1
        fi

        echo "Importando '$ARCHIVO' como tipo $TIPO_VPN a NetworkManager..."
        sudo nmcli connection import type "$TIPO_VPN" file "$ARCHIVO"
        
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
    sudo systemctl restart dnscrypt-proxy.service dnscrypt-proxy.socket
    sudo systemctl restart systemd-timesyncd.service
    if command -v conntrack >/dev/null 2>&1; then
        sudo conntrack -F >/dev/null 2>&1
    fi
}

# Aplica reglas nftables dinámicas evaluando protocolo y remotes
activar_killswitch() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        TIPO_VPN=$(detectar_tipo_vpn "$config_file")
        REGLAS_ENDPOINT=""

        if [ "$TIPO_VPN" = "wireguard" ]; then
            IFACE="wg*"
            PROTO="udp"
            local endpoint=$(grep -iE "^Endpoint" "$config_file" | awk -F'=' '{print $2}' | tr -d ' ')
            local ip=$(echo "$endpoint" | cut -d':' -f1)
            local puerto=$(echo "$endpoint" | cut -d':' -f2)
            REGLAS_ENDPOINT="        ip daddr $ip udp dport $puerto accept"

        elif [ "$TIPO_VPN" = "openvpn" ]; then
            IFACE="tun*"
            
            # Detectar protocolo (tcp o udp) ignorando mayúsculas
            PROTO=$(grep -iE "^proto " "$config_file" | awk '{print $2}' | tr -d ' ' | tr '[:upper:]' '[:lower:]')
            [ -z "$PROTO" ] && PROTO="udp" # Fallback por defecto en OpenVPN

            # Procesar todos los remotes (ej. ProtonVPN declara múltiples puertos)
            while read -r line; do
                [ -z "$line" ] && continue
                local ip_remote=$(echo "$line" | awk '{print $2}')
                local puerto_remote=$(echo "$line" | awk '{print $3}')
                [ -z "$puerto_remote" ] && puerto_remote="1194"
                REGLAS_ENDPOINT+="        ip daddr $ip_remote $PROTO dport $puerto_remote accept"$'\n'
            done <<< "$(grep -iE "^remote " "$config_file")"
        fi

        if [ -n "$REGLAS_ENDPOINT" ]; then
            echo "Aplicando Kill-Switch nftables para $TIPO_VPN ($PROTO) sobre interfaz $IFACE..."
            
            sudo nft -f - <<EOF
flush ruleset
table inet killswitch {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        iifname "$IFACE" accept
        ct state established,related accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy drop;
        oifname "lo" accept
        oifname "$IFACE" accept
$REGLAS_ENDPOINT
        ip daddr 192.168.100.0/24 accept
    }
}
EOF
        else
            echo "Error: No se pudo extraer la IP o puerto del archivo de configuración."
            exit 1
        fi
    fi
}

desactivar_killswitch() {
    echo "Limpiando reglas de killswitch..."
    sudo nft flush ruleset
}

case $ACCION in
    --instalar)
        instalar_vpn
        ;;
        
    --conectar)
        instalar_vpn
        echo "Conectando a la VPN '$NOMBRE_CONN'..."
        sudo nmcli connection up "$NOMBRE_CONN"
        activar_killswitch "$ARCHIVO"
        reiniciar_servicios_red
        echo "Conectado exitosamente."
        ;;
        
    --desconectar)
        if [ -z "$ARCHIVO" ]; then
            echo "Buscando conexiones activas ajenas a Wi-Fi/Ethernet..."
            CONEXIONES_AJENAS=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2 !~ /802-11-wireless|802-3-ethernet|ethernet|wifi|loopback/ {print $1}')
            
            if [ -z "$CONEXIONES_AJENAS" ]; then
                echo "No se detectaron conexiones VPN activas."
            else
                while IFS= read -r conn; do
                    echo "Desconectando interfaz: $conn"
                    sudo nmcli connection down "$conn" 2>/dev/null
                done <<< "$CONEXIONES_AJENAS"
            fi
        else
            echo "Desconectando la VPN '$NOMBRE_CONN'..."
            sudo nmcli connection down "$NOMBRE_CONN" 2>/dev/null
        fi

        desactivar_killswitch
        reiniciar_servicios_red
        echo "Red domiciliaria restaurada exitosamente."
        ;;
        
    --borrar)
        echo "Borrando la conexión '$NOMBRE_CONN'..."
        if conexion_existe; then
            sudo nmcli connection down "$NOMBRE_CONN" 2>/dev/null
            desactivar_killswitch
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
