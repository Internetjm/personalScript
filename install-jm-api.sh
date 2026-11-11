#!/bin/bash
# Instala JM API en el VPS (ejecutar como root, en la carpeta donde esta jm_api.py)
set -e
[ "$(id -u)" = 0 ] || { echo "Ejecuta como root"; exit 1; }
PORT="${1:-8085}"
install -m 755 "$(dirname "$0")/jm_api.py" /usr/local/bin/jm_api.py
mkdir -p /etc/jm-api/accounts
[ -s /etc/jm-api/api.key ] || { head -c 32 /dev/urandom | base64 | tr -d '/+=\n' > /etc/jm-api/api.key; }
chmod 600 /etc/jm-api/api.key
cat > /etc/systemd/system/jm-api.service <<UNIT
[Unit]
Description=JM API (crear y renovar cuentas 24h)
After=network.target

[Service]
Environment=JM_API_PORT=$PORT
# Opcional: solo permitir la IP de tu backend, ej: Environment=JM_API_ALLOW=1.2.3.4
ExecStart=/usr/bin/python3 /usr/local/bin/jm_api.py serve
Restart=always
User=root

[Install]
WantedBy=multi-user.target
UNIT
echo '*/5 * * * * root /usr/bin/python3 /usr/local/bin/jm_api.py reap >/dev/null 2>&1' > /etc/cron.d/jm-api-reap
systemctl daemon-reload
systemctl enable --now jm-api
command -v ufw >/dev/null && ufw allow "$PORT"/tcp >/dev/null 2>&1 || true
echo "Listo. Puerto: $PORT"
echo "API KEY: $(cat /etc/jm-api/api.key)"


