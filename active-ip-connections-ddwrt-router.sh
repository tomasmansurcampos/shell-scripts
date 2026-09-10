#!/bin/sh

# Detección de versión (kernels modernos usan nf_conntrack)
CONNTRACK="/proc/net/ip_conntrack"
[ -f "/proc/net/nf_conntrack" ] && CONNTRACK="/proc/net/nf_conntrack"

# Lectura y conteo en una sola pasada para minimizar carga de I/O y CPU
awk '
/^tcp/ {t++}
/^udp/ {u++}
END {
    print "Actual TCP connections:\t\t" (t+0)
    print "Actual UDP connections:\t\t" (u+0)
    print "Actual total IP connections:\t" (t+u)
}' "$CONNTRACK"

# Asignación de variables con soporte para fallback e inhibición de errores
MAX_IP=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_max 2>/dev/null || cat /proc/sys/net/netfilter/nf_conntrack_max 2>/dev/null)
TCP_TIMEOUT=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_tcp_timeout_established 2>/dev/null || cat /proc/sys/net/netfilter/nf_conntrack_tcp_timeout_established 2>/dev/null)
UDP_TIMEOUT=$(cat /proc/sys/net/ipv4/netfilter/ip_conntrack_udp_timeout_stream 2>/dev/null || cat /proc/sys/net/netfilter/nf_conntrack_udp_timeout_stream 2>/dev/null)

# Impresión de las variables de configuración con valor por defecto si fallan
echo -e "Max IP connections:\t\t${MAX_IP:-N/A}"
echo -e "TCP Timeout (established):\t${TCP_TIMEOUT:-N/A}"
echo -e "UDP Timeout (stream):\t\t${UDP_TIMEOUT:-N/A}"
