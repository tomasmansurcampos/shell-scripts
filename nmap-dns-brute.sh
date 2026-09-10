#!/bin/bash

# Validar que se haya proporcionado un dominio
if [ -z "$1" ]; then
  echo "Error: Dominio no especificado."
  echo "Uso: $0 <dominio> [hilos]"
  exit 1
fi

DOMAIN="$1"
# Asignar 5 hilos por defecto (según la documentación de nmap) si no se provee el parámetro $2
THREADS="${2:-5}"

dns_brute() {
  local target_domain="$1"
  local target_threads="$2"
  
  # Argumentos del script:
  # - dns-brute.domain: Define el dominio objetivo.
  # - dns-brute.threads: Define la cantidad de hilos.
  # - dns-brute.srv: Fuerza la búsqueda de registros SRV para mayor cobertura.
  local script_args="dns-brute.domain=${target_domain},dns-brute.threads=${target_threads},dns-brute.srv"

  # Ejecución de Nmap:
  # -sn: Deshabilita el escaneo de puertos (Ping Scan). Acelera el proceso ya que solo queremos enumeración DNS.
  nmap -sn --script dns-brute --script-args "${script_args}"
}

dns_brute "$DOMAIN" "$THREADS"
