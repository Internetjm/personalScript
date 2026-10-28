#!/bin/bash

BHTTP_HOME="/opt/bhttp"
BHTTP_BUNDLE="/usr/local/lib/bhttp-bundle"
BHTTP_INSTALLER="${BHTTP_HOME}/bhttp-install.sh"
BHTTP_PROBE="${BHTTP_HOME}/bhttp-probe.sh"
BHTTP_SERVICE="bhttp.service"
BHTTP_CONFIG="/etc/bhttp-panel.conf"
BHTTP_PORT="8888"
BHTTP_SSH_PORT="22"

if [ "$(id -u)" -ne 0 ]; then
    echo "Este menú debe ejecutarse como root."
    read -n 1 -s -r -p "Presione una tecla para continuar"
    exit 1
fi

load_config() {
    if [ -r "${BHTTP_CONFIG}" ]; then
        # shellcheck disable=SC1090
        source "${BHTTP_CONFIG}"
    fi
}

save_config() {
    cat > "${BHTTP_CONFIG}" <<EOF
BHTTP_PORT="${BHTTP_PORT}"
BHTTP_SSH_PORT="${BHTTP_SSH_PORT}"
EOF
    chmod 600 "${BHTTP_CONFIG}"
}

pause_menu() {
    echo
    read -n 1 -s -r -p "Presione una tecla para continuar"
    if declare -F menu >/dev/null 2>&1; then menu; fi
}

copy_bundle_from_project() {
    local project_bundle
    project_bundle="$(cd "$(dirname "${BASH_SOURCE[0]}")/../bhttp" 2>/dev/null && pwd)"
    if [ -f "${project_bundle}/bhttp-install.sh" ]; then
        mkdir -p "${BHTTP_BUNDLE}"
        install -m 0755 "${project_bundle}/bhttp-install.sh" "${BHTTP_BUNDLE}/bhttp-install.sh"
        install -m 0755 "${project_bundle}/bhttp-probe.sh" "${BHTTP_BUNDLE}/bhttp-probe.sh"
        install -m 0755 "${project_bundle}/bhttp-activar.sh" "${BHTTP_BUNDLE}/bhttp-activar.sh"
    fi
}

ensure_bundle() {
    copy_bundle_from_project
    if [ ! -f "${BHTTP_BUNDLE}/bhttp-install.sh" ]; then
        echo "No se encontró el paquete BHTTP en ${BHTTP_BUNDLE}."
        echo "Actualiza el panel para descargar scripts/bhttp."
        return 1
    fi
    mkdir -p "${BHTTP_HOME}"
    install -m 0755 "${BHTTP_BUNDLE}/bhttp-install.sh" "${BHTTP_INSTALLER}"
    install -m 0755 "${BHTTP_BUNDLE}/bhttp-probe.sh" "${BHTTP_PROBE}"
    install -m 0755 "${BHTTP_BUNDLE}/bhttp-activar.sh" "${BHTTP_HOME}/bhttp-activar.sh"
}

install_bhttp() {
    ensure_bundle || return 1
    load_config
    read -r -p "Puerto BHTTP [${BHTTP_PORT}]: " selected_port
    [ -n "${selected_port}" ] && BHTTP_PORT="${selected_port}"
    read -r -p "Puerto SSH backend [${BHTTP_SSH_PORT}]: " selected_ssh_port
    [ -n "${selected_ssh_port}" ] && BHTTP_SSH_PORT="${selected_ssh_port}"
    if systemctl is-active --quiet "${BHTTP_SERVICE}"; then
        "${BHTTP_INSTALLER}" --desinstalar || return 1
    fi
    "${BHTTP_INSTALLER}" --puerto "${BHTTP_PORT}" --ssh-puerto "${BHTTP_SSH_PORT}" || return 1
    save_config
}

create_bhttp_user() {
    ensure_bundle || return 1
    read -r -p "Usuario SSH para BHTTP: " bhttp_user
    [ -n "${bhttp_user}" ] || return 1
    read -r -s -p "Clave (Enter para generar): " bhttp_pass
    echo
    if [ -n "${bhttp_pass}" ]; then
        "${BHTTP_INSTALLER}" --crear-usuario "${bhttp_user}" --clave "${bhttp_pass}"
    else
        "${BHTTP_INSTALLER}" --crear-usuario "${bhttp_user}"
    fi
}

uninstall_bhttp() {
    if [ -x "${BHTTP_INSTALLER}" ]; then
        "${BHTTP_INSTALLER}" --desinstalar || return 1
    else
        systemctl disable --now "${BHTTP_SERVICE}" 2>/dev/null || true
    fi
    rm -rf -- "${BHTTP_HOME}" "${BHTTP_CONFIG}"
    echo "BHTTP fue desinstalado."
}

load_config
while true; do
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "             BHTTP SERVER"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if systemctl is-active --quiet "${BHTTP_SERVICE}"; then
        echo "Estado: ACTIVO"
    else
        echo "Estado: INACTIVO"
    fi
    echo "Puerto: ${BHTTP_PORT} | SSH backend: ${BHTTP_SSH_PORT}"
    echo
    echo "[1] Instalar / actualizar y activar"
    echo "[2] Activar"
    echo "[3] Desactivar"
    echo "[4] Reiniciar"
    echo "[5] Ver estado y logs"
    echo "[6] Diagnóstico BHTTP"
    echo "[7] Crear usuario SSH"
    echo "[8] Desinstalar"
    echo "[ENTER] Regresar"
    read -r -p "Seleccione una opción: " option
    case "${option}" in
        1) install_bhttp; pause_menu ;;
        2) systemctl enable --now "${BHTTP_SERVICE}"; echo "BHTTP activado."; pause_menu ;;
        3) systemctl disable --now "${BHTTP_SERVICE}"; echo "BHTTP desactivado."; pause_menu ;;
        4) systemctl restart "${BHTTP_SERVICE}"; echo "BHTTP reiniciado."; pause_menu ;;
        5) systemctl status "${BHTTP_SERVICE}" --no-pager --full || true; journalctl -u "${BHTTP_SERVICE}" -n 30 --no-pager || true; pause_menu ;;
        6) load_config; "${BHTTP_PROBE}" 127.0.0.1 "${BHTTP_PORT}" --no-tls; pause_menu ;;
        7) create_bhttp_user; pause_menu ;;
        8)
            read -r -p "¿Desinstalar BHTTP completamente? [s/N]: " confirm
            case "${confirm}" in [sS]) uninstall_bhttp ;; *) echo "Cancelado." ;; esac
            pause_menu
            ;;
        *)
            if [ -z "${option}" ]; then
                if declare -F menu >/dev/null 2>&1; then menu; fi
                exit 0
            fi
            ;;
    esac
done
