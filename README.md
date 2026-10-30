# Shell Scripts & Systems Automation Toolbox

Colección de scripts en Bash orientados a la administración de sistemas Linux, ingeniería de redes, seguridad operativa, automatización de tareas y procesamiento digital. Diseñados para optimizar flujos de trabajo en entornos de Soporte IT N2, NOC y SysAdmin.

## Visión General de Módulos

### 🌐 Redes, Routers y VPN (NOC / Network Engineering)
- `vpn-wg-files.sh`: Gestión y generación automatizada de archivos de configuración e interfaces WireGuard.
- `OpenWrt/openwrt-radio-5G-configuration.sh`: Automatización de parámetros de radio e interfaces de 5 GHz en dispositivos con OpenWrt.
- `active-ip-connections-ddwrt-router.sh`: Inspección y trazado en tiempo real de conexiones IP activas en routers DD-WRT.
- `restore-archer-c7.sh`: Script de recuperación automatizada (*disaster recovery*) de firmware para TP-Link Archer C7.

### 🛡️ Ciberseguridad y Cifrado
- `build.sh`: Empaquetador de archivos y directorios en ejecutables autoseguros cifrados en AES-256-CBC mediante OpenSSL y `tar`.
- `nmap-dns-brute.sh`: Scripting de reconocimiento y fuerza bruta DNS utilizando el motor de Nmap.
- `ads-blocker.sh`: Módulo de filtrado y bloqueo de dominios maliciosos/publicidad a nivel de sistema/DNS.

### ⚙️ Automatización de Sistema y Compilación
- `fwupd.sh`: Automatización para el diagnóstico y actualización de firmware en componentes de hardware mediante `fwupd`.
- `make-device-as-backup.sh`: Aprovisionamiento automatizado de unidades externas para respaldos de sistema.
- `musl-cc.sh`: Configuración de entornos de compilación cruzada (*cross-compilation*) y estática con `musl-gcc`.
- `gnu-c-reference.sh`: Utilidad CLI para consulta rápida de referencias del estándar GNU C en terminal.

### 🎛️ Procesamiento Multimedia y DSP
- `ytm-downloader.sh`: Descarga, extracción y etiquetado estructurado de audio FLAC desde YouTube Music via `yt-dlp`.
- `sanear_audio.sh` / `unificar-flacs.sh` / `music-gold.sh`: Manipulación masiva, procesamiento de señales digitales (DSP), retitulado y unificación de archivos FLAC/audio sin pérdida.

## Competencias Técnicas Clave

| Dominio | Herramientas y Tecnologías |
| :--- | :--- |
| **Networking & Telco** | OpenWrt, DD-WRT, WireGuard, Protocolos TCP/IP, SSH, Nmap |
| **Seguridad de Datos** | Cifrado simétrico OpenSSL (AES-256), DNS filtering, hardening CLI |
| **Administración Linux** | Bash Avanzado, `fwupd`, gestión de procesos, almacenamiento y tar/gzip |
| **Toolchains & Audio** | Compilación estática C (`musl`), FFmpeg, SoX, tratamiento de metadatos |

## Ejecución

1. Clonar repositorio:
```bash
git clone [https://github.com/tomasmansurcampos/shell-scripts.git](https://github.com/tomasmansurcampos/shell-scripts.git)
cd shell-scripts
```
