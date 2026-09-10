#!/bin/bash
set -e

gnu_c_reference_() {
  # 1. Instalar dependencias con privilegios de superusuario
  sudo apt update
  sudo apt install -y git texinfo texlive

  # 2. Crear y acceder a un directorio temporal aislado
  local WORK_DIR
  WORK_DIR=$(mktemp -d)
  
  # 3. Registrar la limpieza automática al salir del script
  trap 'rm -rf "$WORK_DIR"' EXIT
  
  cd "$WORK_DIR"

  # 4. Clonar solo la versión más reciente del repositorio directamente en la carpeta actual
  git clone --depth 1 https://git.savannah.gnu.org/git/c-intro-and-ref.git .

  # 5. Compilar el archivo de origen al formato PDF
  texi2pdf c.texi

  # 6. Copiar el PDF resultante al directorio del usuario
  cp c.pdf "$HOME/c-manual.pdf"
}

gnu_c_reference_
