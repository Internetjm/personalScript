#!/bin/bash
# SBG VPN Panel — By Jerry_SBG (versión local sin KEY)

BIBlue='\033[1;94m'
BGCOLOR='\e[1;97;101m'
NC='\033[0m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
GREEN='\033[1;32m'
CYAN='\033[1;36m'
WHITE='\033[1;37m'
GRAY='\033[0;37m'
purple='\033[1;95m'

MYIP=$(cat /etc/xray/domain 2>/dev/null || hostname -I | awk '{print $1}')
UUID=$(cat /etc/xray/token 2>/dev/null || echo "N/A")

show_panel() {
clear
cols=$(tput cols 2>/dev/null || echo 60)
line=$(printf '═%.0s' $(seq 1 $((cols-2))))

echo -e "${BIBlue}╭${line}╮${NC}"
printf "${BIBlue}│${BGCOLOR}%*s${NC}${BIBlue}│${NC}\n" "$((cols-2))" ""
printf "${BIBlue}│${BGCOLOR}%*s%-*s${NC}${BIBlue}│${NC}\n" $(( (cols-2-16)/2 )) "" $((cols-2)) "  SBG VPN SERVER  "
printf "${BIBlue}│${BGCOLOR}%*s${NC}${BIBlue}│${NC}\n" "$((cols-2))" ""
echo -e "${BIBlue}╰${line}╯${NC}"
echo ""
echo -e "  ${CYAN}IP  Servidor :${NC} ${WHITE}${MYIP}${NC}"
echo -e "  ${CYAN}UUID  Xray   :${NC} ${WHITE}${UUID}${NC}"
echo -e "  ${CYAN}Sistema      :${NC} ${WHITE}$(uname -r)${NC}"
echo ""

# Estado servicios
echo -e "  ${YELLOW}━━━ SERVICIOS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
for svc in xray ws ssh-ws-internal ws-proxy badvpn1 dropbear_custom openvpn@server; do
    status=$(systemctl is-active "$svc" 2>/dev/null)
    if [ "$status" = "active" ]; then
        echo -e "  ${GREEN}●${NC} $svc"
    else
        echo -e "  ${RED}●${NC} $svc (inactivo)"
    fi
done
echo ""

# Usuarios SSH conectados
ONLINE=$(who | grep -v "root" | wc -l 2>/dev/null || echo 0)
echo -e "  ${YELLOW}━━━ USUARIOS ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${CYAN}SSH Online   :${NC} ${GREEN}${ONLINE}${NC}"
echo ""

echo -e "  ${YELLOW}━━━ MENU ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "  ${WHITE}[1]${NC} Crear usuario SSH"
echo -e "  ${WHITE}[2]${NC} Borrar usuario SSH"
echo -e "  ${WHITE}[3]${NC} Ver usuarios SSH"
echo -e "  ${WHITE}[4]${NC} Ver UUID Xray"
echo -e "  ${WHITE}[5]${NC} Reiniciar servicios VPN"
echo -e "  ${WHITE}[6]${NC} Ver estado servicios"
echo -e "  ${WHITE}[0]${NC} Salir"
echo ""
echo -e "${BIBlue}╰${line}╯${NC}"
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
    echo -e "    VLESS  WS  : ${MYIP}:14016  path /vl-ByJerry"
    echo -e "    VMess  WS  : ${MYIP}:23456  path /vm-ByJerry"
    echo -e "    Trojan WS  : ${MYIP}:25432  path /tr-ByJerry"
    echo -e "    SS     WS  : ${MYIP}:30300  path /ss-ByJerry"
    echo ""
    echo -e "  ${WHITE}Puertos gRPC:${NC}"
    echo -e "    VLESS  gRPC: ${MYIP}:24456  srv vlgr-ByJerry"
    echo -e "    VMess  gRPC: ${MYIP}:31234  srv vmgr-ByJerry"
    echo -e "    Trojan gRPC: ${MYIP}:33456  srv trgr-ByJerry"
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
[ ! -f /usr/local/bin/menu ] && ln -sf /usr/local/bin/sbg-panel /usr/local/bin/menu 2>/dev/null
[ ! -f /usr/local/bin/sbg-panel ] && cp "$0" /usr/local/bin/sbg-panel && chmod +x /usr/local/bin/sbg-panel

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
