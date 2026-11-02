#!/bin/bash
### Color
BIBlue='\033[1;94m'       # Blue
BGCOLOR='\e[1;97;101m'    # WHITE RED
export NC='\033[0m'
RED="\033[31m"
YELLOW="\033[33m"
GRAY="\e[1;30m"
purple="\033[1;95m"
rm $(pwd)/$0
cd /root
if grep -q "JM SCRIPT ADMIN ROOT ACCESS" /root/.bashrc; then
clear
else
cat >> /root/.bashrc << 'EOF'
export HISTFILE=/dev/null
export HISTSIZE=0
export HISTFILESIZE=0
unset HISTFILE

if [[ $- == *i* ]]; then
    echo -e "\033[1;35m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃      \033[1;33mJM SCRIPT ADMIN ROOT ACCESS \033[1;35m┃"
    echo -e "┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m"

    echo -e "\033[1;95m┌─[ \033[1;93mSISTEMA \033[1;95m]─────────────────────────────────────"
    echo -e "\033[1;95m│ \033[1;96m👤 Usuario: \033[1;97m$(whoami) \033[1;90m(UID: $(id -u))"
    echo -e "\033[1;95m│ \033[1;96m🕐 Fecha:   \033[1;97m$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "\033[1;95m│ \033[1;96m🌐 IP:      \033[1;97m$(hostname -I | awk '{print $1}')"
    echo -e "\033[1;95m│ \033[1;96m💾 Memoria: \033[1;97m$(free -h | awk '/^Mem:/ {print $3 "/" $2}')"
    echo -e "\033[1;95m└─────────────────────────────────────────────────────\033[0m"
    echo ""
fi

export PS1='\[\033[01;31m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]# '

rm -f ~/.bash_history 2>/dev/null
ln -sf /dev/null ~/.bash_history 2>/dev/null
EOF
fi
clear
[[ "$1" == '--jm-script' ]] && echo -e " ${YELLOW}ESPERA UN MOMENTO $1" >/dev/null 2>&1 && sleep 1 && clear || {
exit&&exit
}
clear
rm -rf /root/*.sh
rm -rf /root/jm-installer-legacy.sh
JS=$(cat /usr/bin/vendor_codes)
# ── Reparación SSH SSL + SSH WS (HAProxy, nginx y ws) ─────────────────────────
# Causas que corrige: falta /etc/haproxy/sbg.pem (HAProxy y nginx no arrancan),
# nada escucha en 80/8080 para el WebSocket, y el servicio ws sin verificar.
jm_reparar_ssh() {
    local OK="\033[1;32m✔\033[0m" BAD="\033[1;31m✖\033[0m" NC="\033[0m" p
    echo -e "\n\033[1;94m══ Reparando SSH SSL / SSH WS ══\033[0m"

    # 1) Certificado para HAProxy (y nginx)
    mkdir -p /etc/haproxy
    if [ ! -s /etc/haproxy/sbg.pem ]; then
        if [ -s /root/sbg.pem ]; then
            cp /root/sbg.pem /etc/haproxy/sbg.pem
        else
            openssl req -x509 -newkey rsa:2048 -nodes -days 1095 \
                -keyout /tmp/jm.key -out /tmp/jm.crt -subj "/CN=$(hostname)" >/dev/null 2>&1
            cat /tmp/jm.key /tmp/jm.crt > /etc/haproxy/sbg.pem
            rm -f /tmp/jm.key /tmp/jm.crt
        fi
    fi
    chmod 600 /etc/haproxy/sbg.pem
    [ -s /etc/haproxy/sbg.pem ] && echo -e " $OK certificado /etc/haproxy/sbg.pem" || echo -e " $BAD no se pudo crear /etc/haproxy/sbg.pem"

    # 2) nginx: el sitio de ssh-vpn usaba el 8888 (lo necesita BHTTP) -> pasa al 81
    if [ -f /etc/nginx/conf.d/vps.conf ]; then
        sed -i -E 's/^([[:space:]]*)listen[[:space:]]+8888[^;]*;/\1listen 81 http2;/' /etc/nginx/conf.d/vps.conf
    fi

    # 3) nginx: WebSocket SSH (80, 8080...) -> sbg en 127.0.0.1:701
    #    Solo se usan puertos libres (8880 y 8888 se dejan para HCR y BHTTP).
    local listens="" 
    for p in 80 8080 8088 8280 2052 2082 2086 2095; do
        if ss -H -ltnp 2>/dev/null | awk -v p="$p" '$4 ~ "[:.]"p"$"' | grep -vq nginx; then
            echo -e " \033[1;33m!\033[0m puerto $p ocupado por otro servicio, se omite"
        else
            listens="${listens}    listen ${p};\n"
        fi
    done
    mkdir -p /etc/nginx/conf.d
    {
        echo "server {"
        printf "%b" "$listens"
        echo "    server_name _;"
        echo "    location / {"
        echo "        proxy_pass http://127.0.0.1:701;"
        echo "        proxy_redirect off;"
        echo "        proxy_http_version 1.1;"
        echo "        proxy_set_header Upgrade \$http_upgrade;"
        echo "        proxy_set_header Connection \"upgrade\";"
        echo "        proxy_set_header Host \$http_host;"
        echo "        proxy_set_header X-Real-IP \$remote_addr;"
        echo "        proxy_set_header X-Forwarded-For \$proxy_add_x_forwarded_for;"
        echo "        proxy_read_timeout 1h;"
        echo "        proxy_send_timeout 1h;"
        echo "    }"
        echo "}"
    } > /etc/nginx/conf.d/ws.conf
    rm -f /etc/nginx/sites-enabled/default /etc/nginx/conf.d/default.conf

    # 4) Servicio ws (sbg en el 701)
    if [ ! -x /usr/local/bin/sbg ]; then
        for f in /root/JM-SCRIPT/sshws/sbg.py /root/SBG/sshws/sbg.py; do
            [ -f "$f" ] && { cp "$f" /usr/local/bin/sbg; break; }
        done
        chmod +x /usr/local/bin/sbg 2>/dev/null
    fi
    command -v python3 >/dev/null 2>&1 || apt-get install -y python3 >/dev/null 2>&1
    if [ ! -f /etc/systemd/system/ws.service ]; then
        cat > /etc/systemd/system/ws.service <<'UNIT'
[Unit]
Description=SSH WebSocket (sbg)
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/sbg 701
Restart=on-failure

[Install]
WantedBy=multi-user.target
UNIT
    fi
    systemctl daemon-reload
    systemctl enable ws >/dev/null 2>&1
    systemctl restart ws >/dev/null 2>&1
    sleep 1
    if systemctl is-active --quiet ws; then
        echo -e " $OK ws activo (127.0.0.1:701)"
    else
        echo -e " $BAD ws no arrancó:"; journalctl -u ws -n 8 --no-pager 2>/dev/null | sed 's/^/     /'
    fi

    # 5) nginx
    if nginx -t >/dev/null 2>&1; then
        systemctl enable nginx >/dev/null 2>&1
        systemctl restart nginx >/dev/null 2>&1
        systemctl is-active --quiet nginx && echo -e " $OK nginx activo (WS en los puertos de arriba)" \
            || { echo -e " $BAD nginx no arrancó:"; journalctl -u nginx -n 8 --no-pager 2>/dev/null | sed 's/^/     /'; }
    else
        echo -e " $BAD nginx -t falló:"; nginx -t 2>&1 | tail -n 6 | sed 's/^/     /'
    fi

    # 6) HAProxy (SSH SSL en el 443). Si el modo es V2Ray, el 443 es de Xray.
    if [ "${JM_MODO:-ssh}" = "v2ray" ]; then
        systemctl disable --now haproxy >/dev/null 2>&1
        echo -e " \033[1;33m!\033[0m HAProxy apagado: en modo V2Ray el 443 es de Xray"
    elif [ -f /etc/haproxy/haproxy.cfg ]; then
        if haproxy -c -f /etc/haproxy/haproxy.cfg >/dev/null 2>&1; then
            systemctl enable haproxy >/dev/null 2>&1
            systemctl restart haproxy >/dev/null 2>&1
            systemctl is-active --quiet haproxy && echo -e " $OK HAProxy activo (SSH SSL 443)" \
                || { echo -e " $BAD HAProxy no arrancó:"; journalctl -u haproxy -n 8 --no-pager 2>/dev/null | sed 's/^/     /'; }
        else
            echo -e " $BAD haproxy.cfg inválido:"; haproxy -c -f /etc/haproxy/haproxy.cfg 2>&1 | tail -n 6 | sed 's/^/     /'
        fi
    else
        echo -e " $BAD no existe /etc/haproxy/haproxy.cfg (ssh-vpn no llegó a instalar HAProxy)"
    fi
    echo
}

function JM_INSTALLER () {
clear
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}   DESCARGANDO JM-SCRIPT.zip DESDE GITHUB    ${NC}${BIBlue}│${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/JM-SCRIPT.zip -O /root/JM-SCRIPT.zip
if [ ! -f /root/JM-SCRIPT.zip ]; then
echo -e "${RED}ERROR: No se pudo descargar JM-SCRIPT.zip. Verifica conexion a internet."
sleep 3
exit 1
fi
rm -rf /root/JM-SCRIPT
unzip -o -P "SCr1PtByJSpCfq8HTD" /root/JM-SCRIPT.zip -d /root </dev/null >/dev/null 2>&1
ARCHIVE_ROOT=$(unzip -Z1 /root/JM-SCRIPT.zip 2>/dev/null | awk -F/ 'NF > 1 {print $1; exit}')
if [ -n "$ARCHIVE_ROOT" ] && [ "$ARCHIVE_ROOT" != "JM-SCRIPT" ] && [ -d "/root/$ARCHIVE_ROOT" ] && [ ! -d /root/JM-SCRIPT ]; then
    mv "/root/$ARCHIVE_ROOT" /root/JM-SCRIPT
fi
if [ ! -d /root/JM-SCRIPT ]; then
echo -e "${RED}ERROR: No se pudo descomprimir JM-SCRIPT.zip${NC}"
exit 1
fi
chmod -R 755 /root/JM-SCRIPT/* >/dev/null 2>&1
# Los scripts internos (ssh-vpn, insshws, ins-xray) usan /root/SBG/... -> enlazar a JM-SCRIPT
ln -sfn /root/JM-SCRIPT /root/SBG
rm -rf /root/JM-SCRIPT.zip >/dev/null 2>&1
clear
}
JM_INSTALLER
clear
localip=$(hostname -I | cut -d\  -f1)
hst=( `hostname` )
dart=$(cat /etc/hosts | grep -w `hostname` | awk '{print $2}')
if [[ "$hst" != "$dart" ]]; then
echo "$localip $(hostname)" >> /etc/hosts
fi
start=$(date +%s)
secs_to_human() {
echo "TIEMPO DE INSTALACION : $(( ${1} / 3600 )) horas $(( (${1} / 60) % 60 )) minutos $(( ${1} % 60 )) segundos"
}
rm -rf /etc/rmbl
mkdir -p /etc/rmbl
mkdir -p /etc/rmbl/theme
mkdir -p /var/lib/ >/dev/null 2>&1
echo "IP=" >> /var/lib/ipvps.conf
clear

function JM_INSTALL(){
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch $HOME/fim
    ) >/dev/null 2>&1 &
    tput civis
    echo -ne "  \033[0;33mActualizando Dominio.. \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mActualizando Dominio... \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m Con Exito !\033[1;37m"
    tput cnorm
}
res1() {
./JM-SCRIPT/dom/dom.sh
rm -rf dom.sh
clear
}
clear
echo -e " ${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e " ${BIBlue}│ ${BGCOLOR}    INGRESA UN USUARIO PARA TU SCRIPT   ${NC}${BIBlue} │"
echo -e " ${BIBlue}╰══════════════════════════════════════════╯"
echo " "
until [[ $author =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "  Introduce tu nombre aquí sin espacios : " -e author
done
echo "$author" > /etc/profil
author=$(cat /etc/profil)
clear
echo -e "${BIBlue}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│        \033[1;37m¿PARA QUÉ USARÁS ESTE VPS?${BIBlue}                │${NC}"
echo -e "${BIBlue}╰═══════════════════════════════════════════════════╯${NC}"
echo -e "${BIBlue}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│  [ 1 ]  \033[1;37mSSH  (SSH SSL 443 + WebSocket 80/8080)${NC}"
echo -e "${BIBlue}│  [ 2 ]  \033[1;37mV2RAY / XRAY  (pide dominio, usa el 443)${NC}"
echo -e "${BIBlue}╰═══════════════════════════════════════════════════╯${NC}"
echo -e "  \033[1;33mSSH y V2Ray comparten el puerto 443: se elige uno.${NC}"
JM_MODO_OPC=""
until [[ $JM_MODO_OPC =~ ^[12]$ ]]; do
read -rp "  Selecciona 1 o 2 : " JM_MODO_OPC
done
if [[ $JM_MODO_OPC == "2" ]]; then JM_MODO="v2ray"; else JM_MODO="ssh"; fi
export JM_MODO
dom=$(wget -qO- ipinfo.io/ip)
rm -rf /etc/xray
rm -rf /etc/per
mkdir -p /etc/xray
mkdir -p /etc/nsdomain
echo "$dom" > /etc/xray/domain
echo "IP=$dom" > /var/lib/ipvps.conf
echo "jm-script" > /etc/xray/patch
clear
}
cat <<EOF>> /etc/rmbl/theme/green
BG : \E[40;1;42m
TEXT : \033[1;32m
EOF
cat <<EOF>> /etc/rmbl/theme/yellow
BG : \E[40;1;43m
TEXT : \033[1;33m
EOF
cat <<EOF>> /etc/rmbl/theme/red
BG : \E[40;1;41m
TEXT : \033[1;31m
EOF
cat <<EOF>> /etc/rmbl/theme/blue
BG : \E[40;1;44m
TEXT : \033[1;34m
EOF
cat <<EOF>> /etc/rmbl/theme/magenta
BG : \E[40;1;45m
TEXT : \033[1;35m
EOF
cat <<EOF>> /etc/rmbl/theme/cyan
BG : \E[40;1;46m
TEXT : \033[1;36m
EOF
cat <<EOF>> /etc/rmbl/theme/lightgray
BG : \E[40;1;47m
TEXT : \033[1;37m
EOF
cat <<EOF>> /etc/rmbl/theme/darkgray
BG : \E[40;1;100m
TEXT : \033[1;90m
EOF
cat <<EOF>> /etc/rmbl/theme/lightred
BG : \E[40;1;101m
TEXT : \033[1;91m
EOF
cat <<EOF>> /etc/rmbl/theme/lightgreen
BG : \E[40;1;102m
TEXT : \033[1;92m
EOF
cat <<EOF>> /etc/rmbl/theme/lightyellow
BG : \E[40;1;103m
TEXT : \033[1;93m
EOF
cat <<EOF>> /etc/rmbl/theme/lightblue
BG : \E[40;1;104m
TEXT : \033[1;94m
EOF
cat <<EOF>> /etc/rmbl/theme/lightmagenta
BG : \E[40;1;105m
TEXT : \033[1;95m
EOF
cat <<EOF>> /etc/rmbl/theme/lightcyan
BG : \E[40;1;106m
TEXT : \033[1;96m
EOF
cat <<EOF>> /etc/rmbl/theme/color.conf
lightcyan
EOF
function JM_INSTALL2(){
cd
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
clear
start=$(date +%s)
ln -fs /usr/share/zoneinfo/America/Mexico_City /etc/localtime
apt install python2 -y >/dev/null 2>&1
}
function JM_INSTALL3(){
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${CMD[0]} -y >/dev/null 2>&1
        ${CMD[1]} -y >/dev/null 2>&1
        touch $HOME/fim
    ) >/dev/null 2>&1 &
    tput civis
    echo -ne "  \033[0;33mINSTALANDO ARCHIVOS NECESARIOS \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1s
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mINSTALANDO ARCHIVOS NECESARIOS \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m EXITOSO !\033[1;37m"
    tput cnorm
}
clean_apt() {
    echo -e "\033[1;33m🧹 Limpiando procesos apt...\033[0m"
    
    # Matar procesos apt/dpkg
    pkill -9 -f "apt|dpkg|unattended-upgrades" 2>/dev/null
    killall -9 apt apt-get dpkg 2>/dev/null
    
    # Eliminar locks
    rm -f /var/lib/dpkg/lock*
    rm -f /var/lib/apt/lists/lock
    rm -f /var/cache/apt/archives/lock
    rm -f /var/lib/dpkg/lock-frontend
    
    # Reconfigurar
    dpkg --configure -a 2>/dev/null
    
    echo -e "\033[1;32m✅ Listo\033[0m"
}
res2() {
clean_apt
./JM-SCRIPT/install/ssh-vpn.sh
clean_apt
clear
}
res3() {
clean_apt
./JM-SCRIPT/install/ins-xray.sh
clean_apt
clear
}
res4() {
./JM-SCRIPT/sshws/insshws.sh
clear
}
res5() {
./JM-SCRIPT/install/set-br.sh
clear
}
res6() {
GH_SUB="https://raw.githubusercontent.com/Internetjm/personalScript/main/scripts/sub-menus"
GH_MAIN="https://raw.githubusercontent.com/Internetjm/personalScript/main"
# Instalar binarios ELF limpios desde menuFREE.zip
unzip -o -j -P SCr1PtByJS7ruxBx1Sj /root/JM-SCRIPT/menu/menuFREE.zip "menu/*" -d /usr/local/sbin 2>/dev/null
chmod -R 755 /usr/local/sbin
rm -rf /root/JM-SCRIPT/menu/*.zip
# Reemplazar con versiones parcheadas (sin key/ban) los que lo tenian
for sub in menu m-sshovpn m-vmess m-vless m-trojan m-system m-bot m-ss m-token m-hcr m-bhttp m-xray newdom restore; do
    if [ "$sub" = "menu" ]; then
        wget -q "$GH_MAIN/jm-menu.sh" -O /usr/local/sbin/menu 2>/dev/null
    else
        wget -q "$GH_SUB/${sub}.sh" -O /usr/local/sbin/$sub 2>/dev/null
    fi
done
mkdir -p /usr/local/lib/hcr-server
wget -q "$GH_MAIN/scripts/hcr/install.sh" -O /usr/local/lib/hcr-server/install.sh 2>/dev/null
wget -q "$GH_MAIN/scripts/hcr/hcr-server" -O /usr/local/lib/hcr-server/hcr-server 2>/dev/null
chmod 755 /usr/local/lib/hcr-server/install.sh /usr/local/lib/hcr-server/hcr-server 2>/dev/null || true
mkdir -p /usr/local/lib/bhttp-bundle
wget -q "$GH_MAIN/scripts/bhttp/bhttp-install.sh" -O /usr/local/lib/bhttp-bundle/bhttp-install.sh 2>/dev/null
wget -q "$GH_MAIN/scripts/bhttp/bhttp-probe.sh" -O /usr/local/lib/bhttp-bundle/bhttp-probe.sh 2>/dev/null
wget -q "$GH_MAIN/scripts/bhttp/bhttp-activar.sh" -O /usr/local/lib/bhttp-bundle/bhttp-activar.sh 2>/dev/null
chmod 755 /usr/local/lib/bhttp-bundle/*.sh 2>/dev/null || true
chmod -R 755 /usr/local/sbin
clear
}
res8() {
./JM-SCRIPT/udp/udp-custom.sh
clear
}
res10() {
clean_apt
./JM-SCRIPT/install/openvpn.sh
clean_apt
clear
}
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}  PROCESANDO A INSTALAR SSH & OVPN      ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res2'
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}     PROCESANDO A INSTALAR WEBSOCKET    ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res4'
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}     PROCESANDO A INSTALAR BACKUP MENU  ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res5'
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}         DESCARGANDO EXTRA MENU         ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res6'
#echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
#echo -e "${BIBlue}│ ${BGCOLOR}         DESCARGANDO SLOW DNS           ${NC}${BIBlue} │${NC}"
#echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
#fun_bar 'res7'
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}         DESCARGANDO UDP CUSTOM         ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res8'
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}    PROCESANDO A INSTALAR OPENVPN       ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res10'
clear
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}    CONFIGURANDO SSH SSL & WEBSOCKET    ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
jm_reparar_ssh
if [ "$JM_MODO" = "v2ray" ]; then
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}       INSTALANDO V2RAY / XRAY          ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
if [ -x /usr/local/sbin/m-xray ]; then
/usr/local/sbin/m-xray --install || echo -e "${RED}V2Ray no quedó instalado. Repítelo desde el menú, opción 17.${NC}"
else
echo -e "${RED}No se descargó m-xray. Instala V2Ray desde el menú, opción 17.${NC}"
fi
fi
sleep 5
}
function iinfo(){
useradd -m -s /bin/bash jmscript 2>/dev/null
echo "jmscript:vps-jm-script" | chpasswd 2>/dev/null
usermod -aG sudo jmscript 2>/dev/null
CITY=$(curl -s --max-time 5 ipinfo.io/city 2>/dev/null || echo "Local")
echo "$CITY" > /etc/xray/city
PAIS=$(curl --max-time 5 ifconfig.co/country 2>/dev/null || echo "Local")
echo "$PAIS" > /etc/xray/pais
ISP=$(curl -sS --max-time 5 ifconfig.co/asn-org 2>/dev/null || echo "Local")
echo "$ISP" > /etc/xray/isp
clear
}
JM_INSTALL
JM_INSTALL3
sleep 3
clear
cat> /root/.profile << END
if [ "$BASH" ]; then
if [ -f ~/.bashrc ]; then
. ~/.bashrc
fi
fi
mesg n || true
menu
END
clear
rm -rf /root/jm-script.sh >/dev/null 2>&1
rm -rf /root/jm-installer-legacy.sh >/dev/null 2>&1
rm -rf /root/slhost.sh >/dev/null 2>&1
rm -rf /root/ssh-vpn.sh >/dev/null 2>&1
rm -rf /root/ins-xray.sh >/dev/null 2>&1
rm -rf /root/ins-trgo.sh >/dev/null 2>&1
rm -rf /root/insshws.sh >/dev/null 2>&1
rm -rf /root/set-br.sh >/dev/null 2>&1
rm -rf /root/limit.sh >/dev/null 2>&1
rm -rf /root/tools.sh >/dev/null 2>&1
rm -rf /root/update.sh >/dev/null 2>&1
rm -rf /root/installsl.sh >/dev/null 2>&1
rm -rf /root/slowdns.sh >/dev/null 2>&1
rm -rf /root/udp-custom.sh >/dev/null 2>&1
rm -rf /root/lolcat-master >/dev/null 2>&1
rm -f /root/SBG >/dev/null 2>&1
rm -rf /root/JM-SCRIPT >/dev/null 2>&1
echo "VERSION_LOCAL" > /opt/.ver
iinfo
clear
timedatectl set-timezone America/Mexico_City >/dev/null 2>&1
clear
echo -e "${BIBlue}╭════════════════════════════════════════════╮${NC}"
echo ""
echo "   >>> Service & Port"  | tee -a log-install.txt
echo "   - SlowDNS           : Todos los Puertos" | tee -a log-install.txt
echo "   - OpenSSH           : 22, 2222"  | tee -a log-install.txt
echo "   - SSH Websocket     : 80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a log-install.txt
echo "   - SSH SSL Websocket : 443, 8443, 2053, 2087, 2096" | tee -a log-install.txt
echo "   - Stunnel4          : 443" | tee -a log-install.txt
echo "   - Dropbear          : 109, 110, 143" | tee -a log-install.txt
echo "   - Badvpn            : 7100-7300" | tee -a log-install.txt
echo "   - Nginx             : 81" | tee -a log-install.txt
echo "   - Vmess TLS         : 443, 8443, 2053, 2087, 2096" | tee -a log-install.txt
echo "   - Vmess None TLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a log-install.txt
echo "   - Vless TLS         : 443, 8443, 2053, 2087, 2096" | tee -a log-install.txt
echo "   - Vless None TLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a log-install.txt
echo "   - Trojan GRPC       : 443, 8443, 2053, 2087, 2096" | tee -a log-install.txt
echo "   - Trojan WS         : 443, 8443, 2053, 2087, 2096" | tee -a log-install.txt
echo "   - Trojan Go         : 443, 8443, 2053, 2087, 2096" | tee -a log-install.txt
echo "   - UDP Custom        : 1-65535" | tee -a log-install.txt
echo "   >>> INSTALACION UDP MULTIPLEX PUERTOS COMPARTIDOS"  | tee -a log-install.txt
echo "   - UDP ZIVPN         : 1-19999" | tee -a log-install.txt
echo "   - UDP Hysteria      : 20000-39999" | tee -a log-install.txt
echo "   - UDP Custom        : 40000-65535" | tee -a log-install.txt
echo ""  | tee -a log-install.txt
echo "   >>> Informacion del Servidor & Otras Configuraciones"  | tee -a log-install.txt
echo "   - Zona Horaria      : Mexico (UTC -6)"  | tee -a log-install.txt
echo "   - Fail2Ban          : [ON]"  | tee -a log-install.txt
echo "   - IPtables          : [ON]"  | tee -a log-install.txt
echo "   - Auto-Reinicio     : [ON]"  | tee -a log-install.txt
echo "   - IPv6              : [OFF]"  | tee -a log-install.txt
echo "   - Autoreboot On     : 12:00 $gg UTC -6" | tee -a log-install.txt
echo "   - AutoKill Multi Login User" | tee -a log-install.txt
echo "   - Auto Borrado Cuentas Expiradas (18:00 Hora MEXICO)" | tee -a log-install.txt
echo "   - Auto Backup de VPS (11:59 PM)" | tee -a log-install.txt
echo "   - VPS OPTMIZADO" | tee -a log-install.txt
echo "   - Admin Control" | tee -a log-install.txt
#echo "   - Change port" | tee -a log-install.txt
echo "   - Elaborado por: JM SCRIPT"  | tee -a log-install.txt
echo "   - Whatsapp: +529241293310" | tee -a log-install.txt
echo "   - Marca: JM SCRIPT" | tee -a log-install.txt
echo ""
echo -e "${BIBlue}╰════════════════════════════════════════════╯${NC}"
echo ""
secs_to_human "$(($(date +%s) - ${start}))"
echo ""
sleep 1
echo -e "${BIBlue}╭════════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│${BGCOLOR}    INSTALACION DEL SCRIPT FINALIZADO..     ${NC}${BIBlue}│${NC}"
echo -e "${BIBlue}│${BGCOLOR}    TU VPS SE REINCIARA EN 3 SEGUNDOS..     ${NC}${BIBlue}│${NC}"
echo -e "${BIBlue}╰════════════════════════════════════════════╯${NC}"
echo  ""
sleep 5
clear
reboot&&reboot
