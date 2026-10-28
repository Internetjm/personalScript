#!/bin/bash

HCR_SERVICE="hcr-server.service"
HCR_HOME="/opt/hcr-server"
HCR_BUNDLE="/usr/local/lib/hcr-server"
HCR_PORT="8880"
HCR_TRANSPORT="plain"

if [ "$(id -u)" -ne 0 ]; then
    echo "Este menú debe ejecutarse como root."
    read -n 1 -s -r -p "Presione una tecla para continuar"
    exit 1
fi

pause_menu() {
    echo
    read -n 1 -s -r -p "Presione una tecla para continuar"
    if declare -F menu >/dev/null 2>&1; then
        menu
    fi
}

copy_bundle_from_project() {
    local project_bundle
    project_bundle="$(cd "$(dirname "${BASH_SOURCE[0]}")/../hcr" 2>/dev/null && pwd)"
    if [ -f "${project_bundle}/hcr-server" ] && [ -f "${project_bundle}/install.sh" ]; then
        mkdir -p "${HCR_BUNDLE}"
        install -m 0755 "${project_bundle}/hcr-server" "${HCR_BUNDLE}/hcr-server"
        install -m 0755 "${project_bundle}/install.sh" "${HCR_BUNDLE}/install.sh"
    fi
}

ensure_bundle() {
    copy_bundle_from_project
    if [ ! -f "${HCR_BUNDLE}/hcr-server" ] || [ ! -f "${HCR_BUNDLE}/install.sh" ]; then
        echo "No se encontró el paquete HCR en ${HCR_BUNDLE}."
        echo "Actualiza el panel para descargar scripts/hcr o copia allí hcr-server e install.sh."
        return 1
    fi
    mkdir -p "${HCR_HOME}"
    install -m 0755 "${HCR_BUNDLE}/hcr-server" "${HCR_HOME}/hcr-server"
    install -m 0755 "${HCR_BUNDLE}/install.sh" "${HCR_HOME}/install.sh"
}

install_hcr() {
    ensure_bundle || return 1
    "${HCR_HOME}/install.sh" --port "${HCR_PORT}" --transport "${HCR_TRANSPORT}"
}

uninstall_hcr() {
    if [ -x "${HCR_HOME}/install.sh" ]; then
        "${HCR_HOME}/install.sh" --uninstall || return 1
    else
        systemctl disable --now "${HCR_SERVICE}" 2>/dev/null || true
    fi
    rm -rf -- "${HCR_HOME}"
    echo "HCR fue desinstalado."
}

while true; do
    clear
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "             HCR SERVER"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    if systemctl is-active --quiet "${HCR_SERVICE}"; then
        echo "Estado: ACTIVO"
    else
        echo "Estado: INACTIVO"
    fi
    echo "Puerto: ${HCR_PORT} | Transporte: ${HCR_TRANSPORT}"
    echo
    echo "[1] Instalar / actualizar y activar"
    echo "[2] Activar"
    echo "[3] Desactivar"
    echo "[4] Reiniciar"
    echo "[5] Ver estado y logs"
    echo "[6] Desinstalar"
    echo "[ENTER] Regresar"
    read -r -p "Seleccione una opción: " option
    case "${option}" in
        1) install_hcr; pause_menu ;;
        2) systemctl enable --now "${HCR_SERVICE}"; echo "HCR activado."; pause_menu ;;
        3) systemctl disable --now "${HCR_SERVICE}"; echo "HCR desactivado."; pause_menu ;;
        4) systemctl restart "${HCR_SERVICE}"; echo "HCR reiniciado."; pause_menu ;;
        5) systemctl status "${HCR_SERVICE}" --no-pager --full || true; journalctl -u "${HCR_SERVICE}" -n 30 --no-pager || true; pause_menu ;;
        6)
            read -r -p "¿Desinstalar HCR completamente? [s/N]: " confirm
            case "${confirm}" in [sS]) uninstall_hcr ;; *) echo "Cancelado." ;; esac
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
