#!/bin/bash
set -e

_ALFA="$1"
_OMEGA="$2"

if [ -z "$_ALFA" ] || [ -z "$_OMEGA" ]; then
    echo "Error de uso. Sintaxis: $0 <archivo_o_directorio_origen> <script_destino.sh>"
    exit 1
fi

if [ ! -e "$_ALFA" ]; then
    echo "Error: El origen '$_ALFA' no existe."
    exit 1
fi

_ALFA_NAME=$(basename "$_ALFA")
_ALFA_DIR=$(cd "$(dirname "$_ALFA")" && pwd)

echo "Procesando '$_ALFA_NAME'..."

cat << 'EOF' > "$_OMEGA"
#!/bin/bash
set -e

echo "Di la palabra:"

if openssl enc -d -aes-256-cbc -pbkdf2 -iter 100000 -a << 'DATA_EOF' | tar -xzf - 2>/dev/null
EOF

tar -czf - -C "$_ALFA_DIR" "$_ALFA_NAME" | openssl enc -aes-256-cbc -pbkdf2 -iter 100000 -a >> "$_OMEGA"

cat << EOF >> "$_OMEGA"
DATA_EOF
then
    echo "Éxito."
else
    echo "Error: Palabra incorrecta o datos corruptos."
    exit 1
fi
EOF

chmod +x "$_OMEGA"
echo "Script '$_OMEGA' generado con éxito."
