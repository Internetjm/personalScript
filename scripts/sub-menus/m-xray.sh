#!/usr/bin/env bash

set -u

XRAY_SERVICE="xray.service"
XRAY_CONFIG="/etc/xray/config.json"
XRAY_INSTALLER_URL="https://github.com/XTLS/Xray-install/raw/main/install-release.sh"
XRAY_INSTALLER="/tmp/xray-install-release.sh"

pause_menu() {
    read -r -n 1 -s -p "Presione cualquier tecla para regresar al menú"
    echo
    if declare -F menu >/dev/null 2>&1; then
        menu
    fi
}

download_installer() {
    if ! command -v curl >/dev/null 2>&1; then
        echo "No se encontró curl. Instálalo con: apt-get update && apt-get install -y curl"
        return 1
    fi
    if ! curl -fL --retry 3 --connect-timeout 15 "${XRAY_INSTALLER_URL}" -o "${XRAY_INSTALLER}"; then
        echo "No se pudo descargar el instalador oficial desde GitHub."
        return 1
    fi
    chmod 700 "${XRAY_INSTALLER}"
}

ensure_base_config() {
    if [ -s "${XRAY_CONFIG}" ]; then
        return 0
    fi

    mkdir -p "$(dirname "${XRAY_CONFIG}")" /var/log/xray
    cat > "${XRAY_CONFIG}" <<'JSON'
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "api": {
    "tag": "api",
    "services": ["HandlerService", "LoggerService", "StatsService"]
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": { "address": "127.0.0.1" },
      "tag": "api"
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} }
  ]
}
JSON
    chmod 600 "${XRAY_CONFIG}"
}

install_xray() {
    if [ "$(id -u)" -ne 0 ]; then
        echo "Esta operación requiere root."
        return 1
    fi

    mkdir -p /etc/xray /var/log/xray
    if [ -s "${XRAY_CONFIG}" ]; then
        cp -a "${XRAY_CONFIG}" "${XRAY_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
    fi

    echo "Instalando o reparando Xray..."
    if ! download_installer || ! JSON_PATH=/etc/xray "${XRAY_INSTALLER}" install; then
        echo "No se pudo descargar o ejecutar el instalador oficial de Xray."
        rm -f "${XRAY_INSTALLER}"
        return 1
    fi
    rm -f "${XRAY_INSTALLER}"

    ensure_base_config
    if ! /usr/local/bin/xray run -test -config "${XRAY_CONFIG}"; then
        echo "La configuración de Xray no es válida. Revisa ${XRAY_CONFIG}."
        return 1
    fi

    systemctl daemon-reload
    systemctl enable --now "${XRAY_SERVICE}"
    echo "Xray quedó instalado y activo."
}

uninstall_xray() {
    read -r -p "¿Desinstalar Xray y conservar la configuración? [s/N]: " confirm
    case "${confirm}" in
        [sS][iI]|[sS])
            systemctl disable --now "${XRAY_SERVICE}" 2>/dev/null || true
            if download_installer; then
                "${XRAY_INSTALLER}" remove
                rm -f "${XRAY_INSTALLER}"
            fi
            echo "Xray fue desinstalado. Se conserva ${XRAY_CONFIG}."
            ;;
        *) echo "Operación cancelada." ;;
    esac
}

show_status() {
    systemctl status "${XRAY_SERVICE}" --no-pager --full || true
    echo
    echo "Configuración: ${XRAY_CONFIG}"
    if [ -s "${XRAY_CONFIG}" ] && command -v /usr/local/bin/xray >/dev/null 2>&1; then
        /usr/local/bin/xray run -test -config "${XRAY_CONFIG}" || true
    else
        echo "Configuración o binario no encontrado."
    fi
}

show_ports() {
    if command -v ss >/dev/null 2>&1; then
        ss -lntup 2>/dev/null | grep -Ei 'xray|:80 |:443 |:10085 ' || true
    else
        netstat -lntup 2>/dev/null | grep -Ei 'xray|:80 |:443 |:10085 ' || true
    fi
}

while true; do
    clear
    echo "             XRAY / V2RAY CORE"
    echo "----------------------------------------"
    echo "[1] Instalar o reparar Xray"
    echo "[2] Activar Xray"
    echo "[3] Desactivar Xray"
    echo "[4] Reiniciar Xray"
    echo "[5] Ver estado y validar configuración"
    echo "[6] Ver logs"
    echo "[7] Ver puertos Xray"
    echo "[8] Desinstalar Xray"
    echo "[0] Regresar"
    echo
    read -r -p "Seleccione una opción: " option
    case "${option}" in
        1) install_xray; pause_menu; break ;;
        2) systemctl enable --now "${XRAY_SERVICE}"; pause_menu; break ;;
        3) systemctl disable --now "${XRAY_SERVICE}"; pause_menu; break ;;
        4) systemctl restart "${XRAY_SERVICE}"; pause_menu; break ;;
        5) show_status; pause_menu; break ;;
        6) journalctl -u "${XRAY_SERVICE}" -n 80 --no-pager; pause_menu; break ;;
        7) show_ports; pause_menu; break ;;
        8) uninstall_xray; pause_menu; break ;;
        0) if declare -F menu >/dev/null 2>&1; then menu; fi; break ;;
        *) echo "Opción inválida."; sleep 1 ;;
    esac
done
