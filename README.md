# Shell Scripts & Systems Automation Toolbox

Colección de scripts y utilidades desarrollados en Bash y Shell para **GNU/Linux**, orientados a la administración de sistemas, automatización de tareas, networking, seguridad, almacenamiento, compilación y procesamiento multimedia.

El repositorio reúne herramientas independientes diseñadas para resolver tareas específicas, simplificar operaciones recurrentes y optimizar flujos de trabajo desde la terminal.

Incluye utilidades para administración de sistemas Linux, gestión de routers y conexiones VPN, diagnóstico de infraestructura, automatización de respaldos, procesamiento de audio digital y otras tareas de uso cotidiano y técnico.

## Áreas de aplicación

- **Linux System Administration:** mantenimiento, configuración y automatización de sistemas GNU/Linux.
- **Networking & Network Engineering:** administración de routers, conexiones IP, interfaces de red y VPN.
- **Security & Data Protection:** filtrado de dominios, reconocimiento DNS y cifrado de información.
- **Storage & Backup Management:** preparación de dispositivos de almacenamiento y sistemas de respaldo.
- **Software Development & Toolchains:** herramientas de compilación y entornos de desarrollo C.
- **Digital Audio Processing:** conversión, normalización, procesamiento y organización de archivos de audio.

## Catálogo de herramientas

### 🌐 Networking, Routers & VPN

| Script | Descripción |
|:---|:---|
| `vpn-wg-files.sh` | Gestión de conexiones WireGuard mediante NetworkManager. Permite importar, conectar, desconectar y eliminar perfiles VPN. |
| `OpenWrt/openwrt-radio-5G-configuration.sh` | Configuración de parámetros de radio e interfaces inalámbricas de 5 GHz en dispositivos OpenWrt. |
| `active-ip-connections-ddwrt-router.sh` | Consulta de conexiones TCP/UDP activas, límites de conntrack y tiempos de expiración en routers DD-WRT. |
| `restore-archer-c7.sh` | Preparación de un entorno de recuperación de firmware para TP-Link Archer C7 mediante TFTP y configuración de red. |

### 🛡️ Security & Data Protection

| Script | Descripción |
|:---|:---|
| `ads-blocker.sh` | Descarga, procesamiento e integración de listas de bloqueo de publicidad y dominios no deseados en `/etc/hosts`. |
| `build.sh` | Descifrado y extracción de un paquete de datos mediante OpenSSL (AES-256-CBC) y TAR, protegido por contraseña. |
| `nmap-dns-brute.sh` | Automatización de enumeración y descubrimiento de subdominios mediante el motor `dns-brute` de Nmap. |

### ⚙️ Linux System Administration & Storage

| Script | Descripción |
|:---|:---|
| `fwupd.sh` | Automatización de consultas, actualización de metadatos y actualización de firmware mediante fwupd y fwupdmgr. |
| `make-device-as-backup.sh` | Preparación de dispositivos de almacenamiento externos con Btrfs y cifrado LUKS. Detecta características del hardware y genera etiquetas dinámicas. |

### 💻 Development & Compilation Toolchains

| Script | Descripción |
|:---|:---|
| `musl-cc.sh` | Descarga de toolchains de compilación cruzada basadas en musl para diferentes arquitecturas y plataformas. |
| `gnu-c-reference.sh` | Utilidad de consulta de referencias y documentación GNU C desde la terminal. |

### 🎧 Digital Audio Processing & Multimedia

| Script | Descripción |
|:---|:---|
| `ytm-downloader.sh` | Descarga de contenido de YouTube Music mediante yt-dlp, con extracción y conversión de audio. Incluye integración opcional con music-gold.sh. |
| `music-gold.sh` | Procesamiento y optimización de archivos de audio mediante SoX, FFmpeg y herramientas FLAC. |
| `sanear_audio.sh` | Procesamiento y reconstrucción de archivos de audio, conversión a FLAC y tratamiento de carátulas. |
| `unificar-flacs.sh` | Unificación de pistas FLAC en un único archivo de audio, conservando metadatos y carátulas cuando están disponibles. |

## Tecnologías y herramientas

| Área | Tecnologías |
|:---|:---|
| **Shell Scripting** | Bash, POSIX Shell, GNU Coreutils, AWK, SED |
| **Networking** | TCP/IP, SSH, WireGuard, NetworkManager, OpenWrt, DD-WRT |
| **Network Diagnostics** | Nmap, conntrack, herramientas de diagnóstico de red |
| **Security** | OpenSSL, AES-256-CBC, LUKS, DNS filtering |
| **Linux Administration** | systemd, fwupd, APT, gestión de dispositivos y almacenamiento |
| **Filesystems & Backup** | Btrfs, TAR, compresión y cifrado |
| **Development Toolchains** | GCC, musl, cross-compilation, GNU C |
| **Audio & Multimedia** | FFmpeg, FFprobe, SoX, FLAC, yt-dlp, metaflac |

## Requisitos

Los requisitos dependen de cada script y de la funcionalidad que se quiera utilizar.

En general, se requiere:

- Una distribución GNU/Linux.
- Bash o un intérprete Shell compatible, según el script.
- Permisos de ejecución sobre los archivos.
- Herramientas externas específicas, como las indicadas en cada script.
- Privilegios de administrador (`sudo`) para operaciones que modifican configuraciones del sistema, firmware o dispositivos de almacenamiento.

Las dependencias adicionales deben verificarse individualmente antes de ejecutar cada herramienta.

## Instalación

Clonar el repositorio:

```bash
git clone https://github.com/tomasmansurcampos/shell-scripts.git
```

Ingresar al directorio:

```bash
cd shell-scripts
```

Conceder permisos de ejecución al script deseado:

```bash
chmod +x nombre-del-script.sh
```

## Ejecución

Los scripts son independientes y se ejecutan individualmente desde la terminal.

Ejemplo:

```bash
./nombre-del-script.sh
```

Algunas herramientas requieren argumentos adicionales.

Ejemplos:

```bash
# Enumeración DNS mediante Nmap
./nmap-dns-brute.sh example.com

# Preparación de un dispositivo de almacenamiento
sudo ./make-device-as-backup.sh /dev/sdX

# Gestión de perfiles WireGuard
./vpn-wg-files.sh --conectar nombre-conexion

# Descarga de contenido de YouTube Music
./ytm-downloader.sh "URL"
```

Consultar el código fuente y los argumentos requeridos antes de ejecutar cada script.

## Consideraciones de seguridad

- Revisar el código fuente antes de ejecutar cualquier script.
- Verificar las rutas y los dispositivos de destino antes de realizar operaciones sobre almacenamiento.
- Algunos scripts requieren privilegios de administrador y pueden modificar configuraciones del sistema.
- Las operaciones de preparación de dispositivos pueden implicar particionado, formateo y pérdida de datos existentes.
- Las herramientas de reconocimiento de red deben utilizarse únicamente sobre sistemas y dominios propios o con autorización.

## Filosofía del repositorio

Este proyecto funciona como una caja de herramientas personal (*toolbox*), en constante evolución, donde cada script aborda una necesidad concreta.

El objetivo es desarrollar soluciones prácticas mediante Shell Scripting, aprovechando las herramientas nativas del ecosistema GNU/Linux y automatizando procedimientos que, de otro modo, requerirían múltiples operaciones manuales.

---

**Autor:** [tomasmansurcampos](https://github.com/tomasmansurcampos)

**Repositorio:** [github.com/tomasmansurcampos/shell-scripts](https://github.com/t
