

# JM SCRIPT

Script de administración para VPS Linux con herramientas de acceso SSH/VPN, Xray, WebSocket, UDP y gestión de usuarios. Incluye los protocolos HCR y BHTTP integrados en el menú principal.

## Requisitos

- VPS Linux de 64 bits (`x86_64` recomendado; ARM64 puede usar `box64`).
- Ubuntu/Debian con `systemd`.
- Acceso `root` o `sudo`.
- Dominio apuntando al VPS si se utilizarán servicios TLS.
- Puertos necesarios libres en el firewall y en el proveedor del VPS.

## Instalación

Desde el VPS, descarga el instalador principal y ejecútalo como `root`:

```bash
sudo -i
wget -O /root/jm-script.sh https://raw.githubusercontent.com/Internetjm/personalScript/main/jm-script.sh
chmod +x /root/jm-script.sh
bash /root/jm-script.sh
```

El instalador configura las dependencias, SSH/OVPN, Xray, WebSocket, UDP y el menú de administración. Al finalizar, el menú queda disponible con:

```bash
menu
```

También puede instalarse desde una copia local del repositorio:

```bash
git clone https://github.com/Internetjm/personalScript.git
cd personalScript
chmod +x jm-script.sh
sudo bash jm-script.sh
```

## Menú principal

El menú permite administrar usuarios SSH, Xray, VLESS, VMess, Trojan, WebSocket, UDP, certificados, respaldos y servicios del VPS.

Opciones incorporadas:

- `14`: HCR Server.
- `15`: BHTTP Server.
- `66`: desinstalación general del script.

## HCR Server

HCR usa por defecto el puerto `8880`, transporte `plain` y backend SSH en `127.0.0.1:22`.

Instalación directa:

```bash
cd /ruta/al/proyecto/scripts/hcr
sudo bash install.sh --port 8880 --transport plain
```

Transportes disponibles: `plain`, `tls` y `auto`.

Ejemplo TLS:

```bash
sudo bash install.sh --port 8880 --transport tls
```

Desinstalación del servicio:

```bash
sudo bash install.sh --uninstall
```

La administración habitual se realiza desde la opción `14` del menú, donde se puede instalar, activar, desactivar, reiniciar, consultar el estado y revisar los logs.

## BHTTP Server

BHTTP utiliza por defecto el puerto `8888` y conecta con SSH en el puerto `22`.

Instalación directa:

```bash
cd /ruta/al/proyecto/scripts/bhttp
sudo bash bhttp-install.sh --puerto 8888
```

Si SSH escucha en otro puerto:

```bash
sudo bash bhttp-install.sh --puerto 8888 --ssh-puerto 22
```

Desinstalación:

```bash
sudo bash bhttp-install.sh --desinstalar
```

La opción `15` del menú permite instalar/actualizar, activar, desactivar, reiniciar, consultar estado y logs, ejecutar diagnóstico y crear usuarios SSH para BHTTP.

## Actualización

Para actualizar los componentes descargados por el menú, utiliza la opción de actualización disponible en el menú principal. También puedes volver a descargar el instalador principal:

```bash
wget -O /root/jm-script.sh https://raw.githubusercontent.com/Internetjm/personalScript/main/jm-script.sh
chmod +x /root/jm-script.sh
bash /root/jm-script.sh
```

## Notas de seguridad

- Revisa los puertos expuestos antes de poner el VPS en producción.
- Usa certificados válidos cuando habilites HCR con `tls` o `auto`.
- Cambia las credenciales predeterminadas y utiliza claves SSH cuando sea posible.
- Realiza un respaldo antes de reinstalar o desinstalar servicios.

## Licencia y componentes externos

JM SCRIPT reúne scripts propios y componentes externos necesarios para los servicios VPN. Las dependencias de terceros conservan sus respectivas licencias y condiciones de uso.
