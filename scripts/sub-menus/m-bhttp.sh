#!/bin/bash

BHTTP_HOME="/opt/bhttp"
BHTTP_BUNDLE="/usr/local/lib/bhttp-bundle"
BHTTP_INSTALLER="${BHTTP_HOME}/bhttp-install.sh"
BHTTP_PROBE="${BHTTP_HOME}/bhttp-probe.sh"
BHTTP_SERVICE="bhttp.service"
BHTTP_CONFIG="/etc/bhttp-panel.conf"
BHTTP_PORT="8888"
BHTTP_SSH_PORT="22"
C1=$'\033[1;94m'; CY=$'\033[1;36m'; WH=$'\033[1;37m'; GN=$'\033[1;32m'; RD=$'\033[1;31m'; BGC=$'\033[48;5;33m'; NC=$'\033[0m'

bhttp_title() {
    echo -e "${C1}╭══════════════════════════════════════════════════════════╮${NC}"
    printf "${C1}│${BGC}${WH}%*s${NC}${C1}│${NC}\n" 56 "                •  BHTTP SERVER  •"
    echo -e "${C1}╰══════════════════════════════════════════════════════════╯${NC}"
}

detect_ssh_port() {
    if ! command -v ss >/dev/null 2>&1; then
        return 1
    fi
    ss -lntpH 2>/dev/null \
        | awk '$0 ~ /sshd/ {print $4}' \
        | grep -oE '[0-9]+$' \
        | sort -n -u \
        | head -n 1
}

ssh_backend_listening() {
    if command -v ss >/dev/null 2>&1; then
        ss -lntH 2>/dev/null \
            | awk '{print $4}' \
            | grep -qE ":${1//./\\.}$"
    else
        netstat -lnt 2>/dev/null \
            | awk '{print $4}' \
            | grep -qE ":${1//./\\.}$"
    fi
}

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
    if command -v menu >/dev/null 2>&1; then exec menu; fi
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
    if ! ssh_backend_listening "${BHTTP_SSH_PORT}"; then
        detected_ssh_port="$(detect_ssh_port || true)"
        if [ -n "${detected_ssh_port}" ]; then
            echo "SSH no escucha en ${BHTTP_SSH_PORT}; detecté sshd en ${detected_ssh_port}."
            read -r -p "¿Usar ${detected_ssh_port} como backend BHTTP? [S/n]: " use_detected
            case "${use_detected}" in
                [nN]*) ;;
                *) BHTTP_SSH_PORT="${detected_ssh_port}" ;;
            esac
        else
            echo "Advertencia: no se detectó SSH escuchando en ${BHTTP_SSH_PORT}."
            echo "BHTTP puede arrancar, pero la verificación del túnel fallará."
        fi
    fi
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
    bhttp_title
    echo -e "${C1}╭══════════════════════════════════════════════════════════╮${NC}"
    if systemctl is-active --quiet "${BHTTP_SERVICE}"; then
        echo -e " ${WH}Estado : ${GN}● ACTIVO${NC}"
    else
        echo -e " ${WH}Estado : ${RD}● INACTIVO${NC}"
    fi
    echo -e " ${WH}Puerto : ${CY}${BHTTP_PORT}${NC}  ${WH}| SSH backend : ${CY}${BHTTP_SSH_PORT}${NC}"
    echo -e "${C1}╰══════════════════════════════════════════════════════════╯${NC}"
    echo
    echo -e "${C1}╭══════════════════════════════════════════════════════════╮${NC}"
    printf "${C1}│${BGC}${WH}%*s${NC}${C1}│${NC}\n" 56 "                •  OPCIONES BHTTP  •"
    echo -e "${C1}╰══════════════════════════════════════════════════════════╯${NC}"
    echo -e "${C1}│${NC} ${CY}[1]${NC} Instalar / actualizar y activar   ${CY}[5]${NC} Ver estado/logs ${C1}│${NC}"
    echo -e "${C1}│${NC} ${CY}[2]${NC} Activar                           ${CY}[6]${NC} Diagnóstico    ${C1}│${NC}"
    echo -e "${C1}│${NC} ${CY}[3]${NC} Desactivar                        ${CY}[7]${NC} Crear usuario  ${C1}│${NC}"
    echo -e "${C1}│${NC} ${CY}[4]${NC} Reiniciar                         ${CY}[8]${NC} Desinstalar    ${C1}│${NC}"
    echo -e "${C1}│${NC} ${CY}[ENTER]${NC} Regresar                                         ${C1}│${NC}"
    echo -e "${C1}╰══════════════════════════════════════════════════════════╯${NC}"
    read -r -p " Seleccione una opción: " option
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
                if command -v menu >/dev/null 2>&1; then exec menu; fi
                exit 0
            fi
            ;;
    esac
done
