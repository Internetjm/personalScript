#!/bin/bash
# jmscript VPN Panel — By JM SCRIPT (versión local sin KEY)

BIBlue='\033[1;94m'
BGCOLOR='\033[1;44m'
NC='\033[0m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
purple='\033[1;95m'
BLUE='\033[1;34m'
ORANGE='\033[38;5;208m'
MAGENTA='\033[1;35m'

MYIP=$(cat /etc/xray/domain 2>/dev/null || hostname -I | awk '{print $1}')
UUID=$(cat /etc/xray/token 2>/dev/null || echo "N/A")

visual_repeat() {
    local char="$1" count="$2" out
    printf -v out '%*s' "$count" ''
    out=${out// /$char}
    printf '%s' "$out"
}

visual_service_state() {
    if [ "$(systemctl is-active "$1" 2>/dev/null)" = "active" ]; then
        printf "${GREEN}● ON${NC}"
    else
        printf "${RED}● OFF${NC}"
    fi
}

visual_length() {
    printf '%s' "$1" | sed $'s/\033\\[[0-9;]*[[:alpha:]]//g' | awk '{print length($0)}'
}

visual_center() {
    local text="$1" total="$2" visible left right
    visible=$(visual_length "$text")
    left=$(( (total - visible) / 2 ))
    right=$(( total - visible - left ))
    [ "$left" -lt 0 ] && left=0
    [ "$right" -lt 0 ] && right=0
    printf '%*s%s%*s' "$left" '' "$text" "$right" ''
}

show_panel() {
    clear
    local cols width inner line os_name since fecha
    cols=$(tput cols 2>/dev/null || echo 80)
    width=$((cols - 4))
    [ "$width" -gt 76 ] && width=76
    [ "$width" -lt 58 ] && width=58
    inner=$((width - 2))
    line=$(visual_repeat '═' "$inner")
    os_name=$(. /etc/os-release 2>/dev/null && echo "$PRETTY_NAME" || uname -s)
    since=$(uptime -p 2>/dev/null | sed 's/^up //' || echo "N/D")
    fecha=$(date '+%A, %d de %B de %Y' 2>/dev/null || date)
    ONLINE=$(who | grep -v "root" | wc -l 2>/dev/null || echo 0)

    local xray ws ssh proxy badvpn dropbear openvpn
    xray=$(visual_service_state xray)
    ws=$(visual_service_state ws)
    ssh=$(visual_service_state ssh-ws-internal)
    proxy=$(visual_service_state ws-proxy)
    badvpn=$(visual_service_state badvpn1)
    dropbear=$(visual_service_state dropbear_custom)
    openvpn=$(visual_service_state openvpn@server)

    echo -e " ${BIBlue}╭${line}╮${NC}"
    printf " ${BIBlue}│${NC}${BGCOLOR}%*s${NC}${BIBlue}│${NC}\n" "$inner" ""
    printf " ${BIBlue}│${NC}${BGCOLOR}%s${NC}${BIBlue}│${NC}\n" "$(visual_center "${WHITE}🔒  JM SCRIPT${CYAN}  VPN SERVER${WHITE}  ◈${NC}" "$inner")"
    printf " ${BIBlue}│${NC}${BGCOLOR}%s${NC}${BIBlue}│${NC}\n" "$(visual_center "${CYAN}╱╲╱╲  WORLD NET  ╱╲╱╲  HACKER TERMINAL${NC}" "$inner")"
    printf " ${BIBlue}│${NC}${BGCOLOR}%s${NC}${BIBlue}│${NC}\n" "$(visual_center "${CYAN}• • •   AUTOSCRIPT MULTIPORT FREE   • • •${NC}" "$inner")"
    echo -e " ${BIBlue}╰${line}╯${NC}"

    echo -e " ${BIBlue}╭${line}╮${NC}"
    printf " ${BIBlue}│${NC} ${CYAN}⚙ OS${NC}      ${CYAN}:${NC} %-22s ${CYAN}◎ IP VPS${NC} : ${purple}%-18s${NC} ${BIBlue}│${NC}\n" "$os_name" "$MYIP"
    printf " ${BIBlue}│${NC} ${CYAN}▦ FECHA${NC}   ${CYAN}:${NC} %-22s ${CYAN}♛ DOMINIO${NC} : ${purple}%-18s${NC} ${BIBlue}│${NC}\n" "$fecha" "$MYIP"
    printf " ${BIBlue}│${NC} ${CYAN}▶ ACTIVO${NC}  ${CYAN}:${NC} ${GREEN}%-22s${NC} ${CYAN}◈ UUID${NC}   : ${WHITE}%-18s${NC} ${BIBlue}│${NC}\n" "$since" "$UUID"
    echo -e " ${BIBlue}╰${line}╯${NC}"

    echo -e " ${BIBlue}╭─────╱╲────────${NC}${BGCOLOR}  ● STATUS SERVER ●  ${NC}${BIBlue}────────╱╲─────╮${NC}"
    printf " ${BIBlue}│${NC} ${WHITE}XRAY${NC}       ${CYAN}:${NC} %s ${WHITE}14016/23456${NC}  ${WHITE}SSH WS${NC}    ${CYAN}:${NC} %s ${WHITE}80,8080${NC} ${BIBlue}│${NC}\n" "$xray" "$ssh"
    printf " ${BIBlue}│${NC} ${WHITE}WS PROXY${NC}   ${CYAN}:${NC} %s ${WHITE}80,81+7${NC}   ${WHITE}DROPBEAR${NC} ${CYAN}:${NC} %s ${WHITE}69,109+2${NC} ${BIBlue}│${NC}\n" "$proxy" "$dropbear"
    printf " ${BIBlue}│${NC} ${WHITE}BADVPN${NC}     ${CYAN}:${NC} %s ${WHITE}7300${NC}      ${WHITE}OPENVPN${NC}  ${CYAN}:${NC} %s ${WHITE}1194${NC} ${BIBlue}│${NC}\n" "$badvpn" "$openvpn"
    printf " ${BIBlue}│${NC} ${WHITE}ONLINE${NC}     ${CYAN}:${NC} ${GREEN}● %-6s${NC}             ${WHITE}UDP CUSTOM${NC} ${CYAN}:${NC} ${GREEN}● ON${NC}      ${BIBlue}│${NC}\n" "$ONLINE"
    echo -e " ${BIBlue}╰────────────────────────────────────────────────────────╯${NC}"

    echo -e " ${BIBlue}╭──────╱╲──────${NC}${BGCOLOR}  ⭐ LISTA CUENTAS PREMIUM ⭐  ${NC}${BIBlue}──────╱╲──────╮${NC}"
    printf " ${BIBlue}│${NC} ${WHITE}SSH/OPVN${NC}       ${CYAN}=${NC} ${CYAN}%-4s${NC}  ACCOUNT     ${WHITE}VMESS/WS${NC}      ${CYAN}=${NC} ${CYAN}%-4s${NC}  ACCOUNT ${BIBlue}│${NC}\n" "$ONLINE" "$(grep -c '^#vmg ' /etc/xray/config.json 2>/dev/null || echo 0)"
    printf " ${BIBlue}│${NC} ${WHITE}VLESS/WS${NC}       ${CYAN}=${NC} ${CYAN}%-4s${NC}  ACCOUNT     ${WHITE}TROJAN/GRPC${NC}   ${CYAN}=${NC} ${CYAN}%-4s${NC}  ACCOUNT ${BIBlue}│${NC}\n" "$(grep -c '^#vlg ' /etc/xray/config.json 2>/dev/null || echo 0)" "$(grep -c '^#trg ' /etc/xray/config.json 2>/dev/null || echo 0)"
    printf " ${BIBlue}│${NC} ${WHITE}SHADOW-SOCK${NC}    ${CYAN}=${NC} ${CYAN}%-4s${NC}  ACCOUNT     ${WHITE}TOKEN${NC}         ${CYAN}=${NC} ${CYAN}%-4s${NC}  ACCOUNT ${BIBlue}│${NC}\n" "0" "$(grep -c '^### ' /etc/vmess/userQuota 2>/dev/null || echo 0)"
    echo -e " ${BIBlue}╰────────────────────────────────────────────────────────╯${NC}"

    echo -e " ${BIBlue}╭${line}╮${NC}"
    printf " ${BIBlue}│${NC}${BGCOLOR}%s${NC}${BIBlue}│${NC}\n" "$(visual_center "${WHITE}★  LISTA MENU  ★${NC}" "$inner")"
    printf " ${BIBlue}│${NC} ${CYAN}[01]${NC} ${WHITE}▣ SSH-WS${NC}       ${CYAN}[08]${NC} ${WHITE}▣ BOT PANEL${NC}                 ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[02]${NC} ${BLUE}✈ VMESS${NC}       ${CYAN}[09]${NC} ${YELLOW}♟ BOT NOTIFICAC.${NC}           ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[03]${NC} ${CYAN}◈ VLESS${NC}       ${CYAN}[10]${NC} ${YELLOW}♟ CAMBIAR DOMINIO${NC}          ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[04]${NC} ${ORANGE}◉ SHADOW-SOCK${NC} ${CYAN}[89]${NC} ${ORANGE}✎ EDITAR BANNER${NC}            ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[05]${NC} ${ORANGE}🔒 TROJAN${NC}     ${CYAN}[11]${NC} ${YELLOW}⚙ OTRAS OPCIONES${NC}           ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[06]${NC} ${WHITE}♙ MODO TOKEN${NC}  ${CYAN}[12]${NC} ${GREEN}⟳ REINICIAR VPS${NC}            ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[07]${NC} ${YELLOW}＄ BORRAR EXP${NC}  ${CYAN}[13]${NC} ${GREEN}⟳ RESET SERVICIOS${NC}          ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[14]${NC} ${CYAN}◉ HCR SERVER${NC}  ${CYAN}[16]${NC} ${CYAN}◎ VER PUERTOS${NC}              ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[15]${NC} ${CYAN}◉ BHTTP SERVER${NC} ${CYAN}[17]${NC} ${MAGENTA}⊗ XRAY CORE${NC}                ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[18]${NC} ${CYAN}◉ API BACKEND${NC}  ${CYAN}[89]${NC} ${ORANGE}▧ EDITAR BANNER${NC}            ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[24]${NC} ${GREEN}♧ SERVICIOS ON${NC} ${CYAN}[25]${NC} ${BLUE}⇧ INSTALAR SlowDNS${NC}         ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC} ${CYAN}[26]${NC} ${CYAN}⊗ INSTALAR UDP${NC} ${CYAN}[66]${NC} ${RED}▤ DESINSTALAR SCRIPT${NC}       ${BIBlue}│${NC}\n"
    printf " ${BIBlue}│${NC}${BGCOLOR}%s${NC}${BIBlue}│${NC}\n" "$(visual_center "${CYAN}JM SCRIPT VPN PANEL${NC}" "$inner")"
    echo -e " ${BIBlue}╰${line}╯${NC}"
    echo ""
}

crear_usuario() {
    echo ""
    read -p "  Nombre de usuario: " USUARIO
    read -p "  Contraseña: " PASS
    read -p "  Días de validez (0=ilimitado): " DIAS
    echo ""
    if id "$USUARIO" &>/dev/null; then
        echo -e "  ${RED}✖ El usuario ya existe${NC}"
    else
        useradd -m -s /bin/false "$USUARIO" 2>/dev/null || useradd -s /bin/false "$USUARIO"
        echo "$USUARIO:$PASS" | chpasswd
        if [ "$DIAS" -gt 0 ] 2>/dev/null; then
            chage -E "$(date -d "+${DIAS} days" +%Y-%m-%d)" "$USUARIO"
            echo -e "  ${GREEN}✅ Usuario ${USUARIO} creado — expira en ${DIAS} días${NC}"
        else
            echo -e "  ${GREEN}✅ Usuario ${USUARIO} creado — sin expiración${NC}"
        fi
        echo ""
        echo -e "  ${CYAN}━━ DATOS DE CONEXIÓN ━━━━━━━━━━━━━━━━━━━━━━━${NC}"
        echo -e "  ${WHITE}IP       :${NC} ${MYIP}"
        echo -e "  ${WHITE}Usuario  :${NC} ${USUARIO}"
        echo -e "  ${WHITE}Password :${NC} ${PASS}"
        echo -e "  ${WHITE}SSH      :${NC} 22, 90, 109, 143"
        echo -e "  ${WHITE}WS Proxy :${NC} 80, 701"
        echo -e "  ${WHITE}BadVPN   :${NC} 7300"
        echo -e "  ${WHITE}UUID V2  :${NC} ${UUID}"
        echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    fi
    echo ""
    read -p "  Presiona Enter para continuar..."
}

borrar_usuario() {
    echo ""
    read -p "  Nombre de usuario a borrar: " USUARIO
    if id "$USUARIO" &>/dev/null; then
        userdel -f "$USUARIO" 2>/dev/null
        echo -e "  ${GREEN}✅ Usuario ${USUARIO} eliminado${NC}"
    else
        echo -e "  ${RED}✖ Usuario no encontrado${NC}"
    fi
    echo ""
    read -p "  Presiona Enter para continuar..."
}

ver_usuarios() {
    echo ""
    echo -e "  ${CYAN}━━ USUARIOS SSH ━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    awk -F: '$3>=1000 && $3<65534 && $7!="/usr/sbin/nologin" {print "  "$1}' /etc/passwd 2>/dev/null
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    echo -e "  ${YELLOW}Conectados ahora:${NC}"
    who 2>/dev/null | awk '{print "  "$1" — "$5}' || echo "  Ninguno"
    echo ""
    read -p "  Presiona Enter para continuar..."
}

reiniciar_servicios() {
    echo ""
    echo -e "  ${YELLOW}Reiniciando servicios...${NC}"
    for svc in xray ws ssh-ws-internal ws-proxy badvpn1 dropbear_custom; do
        systemctl restart "$svc" 2>/dev/null && \
            echo -e "  ${GREEN}✅ $svc${NC}" || \
            echo -e "  ${RED}✖ $svc${NC}"
    done
    echo ""
    read -p "  Presiona Enter para continuar..."
}

ver_xray() {
    echo ""
    echo -e "  ${CYAN}━━ XRAY INFO ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo -e "  ${WHITE}IP    :${NC} ${MYIP}"
    echo -e "  ${WHITE}UUID  :${NC} ${UUID}"
    echo ""
    echo -e "  ${WHITE}Puertos WebSocket:${NC}"
    echo -e "    VLESS  WS  : ${MYIP}:14016  path /vl-jm-script"
    echo -e "    VMess  WS  : ${MYIP}:23456  path /vm-jm-script"
    echo -e "    Trojan WS  : ${MYIP}:25432  path /tr-jm-script"
    echo -e "    SS     WS  : ${MYIP}:30300  path /ss-jm-script"
    echo ""
    echo -e "  ${WHITE}Puertos gRPC:${NC}"
    echo -e "    VLESS  gRPC: ${MYIP}:24456  srv vlgr-jm-script"
    echo -e "    VMess  gRPC: ${MYIP}:31234  srv vmgr-jm-script"
    echo -e "    Trojan gRPC: ${MYIP}:33456  srv trgr-jm-script"
    echo -e "  ${CYAN}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
    echo ""
    read -p "  Presiona Enter para continuar..."
}

ver_estado() {
    echo ""
    systemctl status xray ws ssh-ws-internal badvpn1 dropbear_custom --no-pager -l 2>/dev/null | head -50
    echo ""
    read -p "  Presiona Enter para continuar..."
}

# Instalar como comando global
[ ! -f /usr/local/bin/menu ] && ln -sf /usr/local/bin/jm-panel /usr/local/bin/menu 2>/dev/null
[ ! -f /usr/local/bin/jm-panel ] && cp "$0" /usr/local/bin/jm-panel && chmod +x /usr/local/bin/jm-panel

# Loop principal
while true; do
    show_panel
    read -p "  Selecciona una opcion: " opt
    case "$opt" in
        1) crear_usuario ;;
        2) borrar_usuario ;;
        3) ver_usuarios ;;
        4) ver_xray ;;
        5) reiniciar_servicios ;;
        6) ver_estado ;;
        0) clear; exit 0 ;;
        *) ;;
    esac
done
