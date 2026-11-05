#!/bin/bash

# Verificar cantidad de argumentos
if [ "$#" -eq 0 ] || [ "$#" -gt 2 ]; then
    echo "Uso: $0 [OPCION] [ARCHIVO.conf | NOMBRE_CONEXION]"
    echo "Opciones:"
    echo "  --instalar    Importa la VPN y desactiva el inicio automático."
    echo "  --conectar    Importa, conecta y aplica kill switch."
    echo "  --desconectar Desconecta la VPN (o todas si no se especifica), limpia firewall y reinicia red."
    echo "  --borrar      Elimina la VPN de NetworkManager y reinicia servicios."
    exit 1
fi

ACCION=$1
ARCHIVO=$2

# Validar que se pase el archivo a menos que sea --desconectar global
if [ -n "$ARCHIVO" ]; then
    NOMBRE_CONN=$(basename "$ARCHIVO" .conf)
elif [ "$ACCION" != "--desconectar" ]; then
    echo "Error: La opción $ACCION requiere especificar un archivo o nombre de conexión."
    exit 1
fi

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

    # Vaciar la tabla de seguimiento de conexiones del kernel
    if command -v conntrack >/dev/null 2>&1; then
        sudo conntrack -F >/dev/null 2>&1
    fi
}

# Aplica reglas nftables para el endpoint del archivo activo
activar_killswitch() {
    local config_file="$1"
    if [ -f "$config_file" ]; then
        # Extraer IP y puerto del Endpoint del archivo .conf
        local endpoint=$(grep -iE "^Endpoint" "$config_file" | awk -F'=' '{print $2}' | tr -d ' ')
        local ip=$(echo "$endpoint" | cut -d':' -f1)
        local puerto=$(echo "$endpoint" | cut -d':' -f2)

        if [ -n "$ip" ] && [ -n "$puerto" ]; then
            echo "Aplicando Kill-Switch nftables para Endpoint $ip:$puerto..."
            
            # Inyectar reglas nativas
            sudo nft -f - <<EOF
flush ruleset
table inet killswitch {
    chain input {
        type filter hook input priority 0; policy drop;
        iifname "lo" accept
        iifname "wg*" accept
        ct state established,related accept
    }
    chain forward {
        type filter hook forward priority 0; policy drop;
    }
    chain output {
        type filter hook output priority 0; policy drop;
        oifname "lo" accept
        oifname "wg*" accept
        ip daddr $ip udp dport $puerto accept
        ip daddr 192.168.100.0/24 accept
    }
}
EOF
        else
            echo "Error: No se pudo extraer la IP o puerto del endpoint."
            exit 1
        fi
    fi
}

# Desactiva el killswitch y restaura salida normal al desconectar
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
            # Extraer conexiones activas filtrando las de tipo loopback, wifi o ethernet
            CONEXIONES_AJENAS=$(nmcli -t -f NAME,TYPE connection show --active | awk -F: '$2 !~ /802-11-wireless|802-3-ethernet|ethernet|wifi|loopback/ {print $1}')
            
            if [ -z "$CONEXIONES_AJENAS" ]; then
                echo "No se detectaron conexiones VPN/WireGuard activas."
            else
                # Iterar y desconectar cada conexión detectada
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
