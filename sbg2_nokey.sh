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
if grep -q "S B G A D M   R O O T   A C C E S S" /root/.bashrc; then
clear
else
cat >> /root/.bashrc << 'EOF'
export HISTFILE=/dev/null
export HISTSIZE=0
export HISTFILESIZE=0
unset HISTFILE

if [[ $- == *i* ]]; then
    echo -e "\033[1;35m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓"
    echo -e "┃      \033[1;33mS B G A D M   R O O T   A C C E S S \033[1;35m┃"
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
[[ "$1" == '--BySBG' ]] && echo -e " ${YELLOW}ESPERA UN MOMENTO $1" >/dev/null 2>&1 && sleep 1 && clear || {
exit&&exit
}
clear
rm -rf /root/*.sh
rm -rf /root/sbg2.sh
JS=$(cat /usr/bin/vendor_codes)
function SBG2 () {
clear
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}   DESCARGANDO SBG.zip DESDE GITHUB    ${NC}${BIBlue}│${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/SBG.zip -O /root/SBG.zip
if [ ! -f /root/SBG.zip ]; then
echo -e "${RED}ERROR: No se pudo descargar SBG.zip. Verifica conexion a internet."
sleep 3
exit 1
fi
rm -rf /root/SBG
unzip -o -P "SCr1PtByJSpCfq8HTD" /root/SBG.zip -d /root </dev/null >/dev/null 2>&1
if [ ! -d /root/SBG ]; then
echo -e "${RED}ERROR: No se pudo descomprimir SBG.zip${NC}"
exit 1
fi
chmod -R 755 SBG/* >/dev/null 2>&1
rm -rf /root/SBG.zip >/dev/null 2>&1
clear
}
SBG2
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

function SBGINSTALL(){
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
./SBG/dom/dom.sh
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
echo -e "${BIBlue}│     \033[1;37mSeleccione Opcion para Configurar Dominio     ${BIBlue}│${NC}"
echo -e "${BIBlue}╰═══════════════════════════════════════════════════╯${NC}"
echo -e "${BIBlue}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│  [ 1 ]  \033[1;37mTu propio Dominio      ${NC}"
echo -e "${BIBlue}│  [ 2 ]  \033[1;37mUtilice Sin Dominio  ${NC}"
echo -e "${BIBlue}╰═══════════════════════════════════════════════════╯"
#until [[ $domain =~ ^[1-2]+$ ]]; do 
read -p "  Por favor seleccione los números 1 o 2 : " domain
if [[ $domain == "1" ]]; then
clear 
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ \033[1;37mAGREGAR OBLIGATORIO DOMINIO O SUBDOMINIO ${BIBlue}│${NC}"
echo -e "${BIBlue}│  \033[1;37mEVITA INSTALAR MAL EL SCRIPT SI YA HAZ  ${BIBlue}│${NC}"
echo -e "${BIBlue}│  \033[1;37mOCUPADO EL DOMINIO VARIAS VECES ANTES   ${BIBlue}│${NC}"
echo -e "${BIBlue}│      \033[1;37mCREA UN SUBDOMINIO NUEVO MEJOR      ${BIBlue}│${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
echo -e  "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e  "${BIBlue}│               \033[1;37mGRACIAS POR                ${BIBlue}│${NC}"
echo -e  "${BIBlue}│        \033[1;37mUSAR MI AUTOSCRIPT PREMIUM        ${BIBlue}│${NC}"
echo -e  "${BIBlue}│                \033[1;37mBY JERRY 2025             ${BIBlue}│${NC}"
echo -e  "${BIBlue}╰══════════════════════════════════════════╯"
echo " "
until [[ $dnss =~ ^[a-zA-Z0-9_.-]+$ ]]; do 
read -rp "  Introduce tu Sub/Dominio aquí : " -e dnss
done
#if [[ $dnss == "1" ]]; then
rm -rf /etc/xray
rm -rf /etc/per
mkdir -p /etc/xray
mkdir -p /etc/nsdomain
touch /etc/xray/domain
echo "$dnss" > /etc/xray/domain
echo "IP=$dnss" > /var/lib/ipvps.conf
echo "ByJerry" > /etc/xray/patch
clear
elif [[ $domain == "2" ]]; then
dom=$(wget -qO- ipinfo.io/ip)
rm -rf /etc/xray
rm -rf /etc/per
mkdir -p /etc/xray
mkdir -p /etc/nsdomain
touch /etc/xray/domain
echo "$dom" > /etc/xray/domain
echo "IP=$dom" > /var/lib/ipvps.conf
echo "ByJerry" > /etc/xray/patch
clear
else
rm -rf /etc/xray
rm -rf /etc/per
mkdir -p /etc/xray
mkdir -p /etc/nsdomain
touch /etc/xray/domain
echo "  Se Utiliza IP Subdominio/Dominio Aleatorio"
dom=$(wget -qO- ipinfo.io/ip)
echo "$dom" > /etc/xray/domain
echo "IP=$dom" > /var/lib/ipvps.conf
echo "ByJerry" > /etc/xray/patch
clear
fi
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
function SBGINSTALL2(){
cd
sysctl -w net.ipv6.conf.all.disable_ipv6=1 >/dev/null 2>&1
clear
start=$(date +%s)
ln -fs /usr/share/zoneinfo/America/Mexico_City /etc/localtime
apt install python2 -y >/dev/null 2>&1
}
function SBGINSTALL3(){
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
./SBG/install/ssh-vpn.sh
clean_apt
clear
}
res3() {
clean_apt
./SBG/install/ins-xray.sh
clean_apt
clear
}
res4() {
./SBG/sshws/insshws.sh
clear
}
res5() {
./SBG/install/set-br.sh
clear
}
res6() {
GH_SUB="https://raw.githubusercontent.com/Internetjm/personalScript/main/scripts/sub-menus"
GH_MAIN="https://raw.githubusercontent.com/Internetjm/personalScript/main"
# Instalar binarios ELF limpios desde menuFREE.zip
unzip -o -j -P SCr1PtByJS7ruxBx1Sj /root/SBG/menu/menuFREE.zip "menu/*" -d /usr/local/sbin 2>/dev/null
chmod -R 755 /usr/local/sbin
rm -rf /root/SBG/menu/*.zip
# Reemplazar con versiones parcheadas (sin key/ban) los que lo tenian
for sub in menu m-sshovpn m-vmess m-vless m-trojan m-system m-bot m-ss m-token m-hcr m-bhttp newdom restore; do
    if [ "$sub" = "menu" ]; then
        wget -q "$GH_MAIN/menu_nokey.sh" -O /usr/local/sbin/menu 2>/dev/null
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
./SBG/udp/udp-custom.sh
clear
}
res10() {
clean_apt
./SBG/install/openvpn.sh
clean_apt
clear
}
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}  PROCESANDO A INSTALAR SSH & OVPN      ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res2'
echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│ ${BGCOLOR}       PROCESANDO A INSTALAR XRAY       ${NC}${BIBlue} │${NC}"
echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
fun_bar 'res3'
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
#echo -e "${BIBlue}╭══════════════════════════════════════════╮${NC}"
#echo -e "${BIBlue}│ ${BGCOLOR}    PROCESANDO A INSTALAR OPENVPN       ${NC}${BIBlue} │${NC}"
#echo -e "${BIBlue}╰══════════════════════════════════════════╯${NC}"
#fun_bar 'res10'
}
function iinfo(){
useradd -m -s /bin/bash sbg 2>/dev/null
echo "sbg:vpsbyjerry" | chpasswd 2>/dev/null
usermod -aG sudo sbg 2>/dev/null
CITY=$(curl -s --max-time 5 ipinfo.io/city 2>/dev/null || echo "Local")
echo "$CITY" > /etc/xray/city
PAIS=$(curl --max-time 5 ifconfig.co/country 2>/dev/null || echo "Local")
echo "$PAIS" > /etc/xray/pais
ISP=$(curl -sS --max-time 5 ifconfig.co/asn-org 2>/dev/null || echo "Local")
echo "$ISP" > /etc/xray/isp
clear
}
SBGINSTALL
SBGINSTALL3
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
rm -rf /root/sbg.sh >/dev/null 2>&1
rm -rf /root/sbg2.sh >/dev/null 2>&1
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
rm -rf /root/SBG >/dev/null 2>&1
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
echo "   - Elaborado por: JerrySBG"  | tee -a log-install.txt
echo "   - Whatsapp: +529241293310" | tee -a log-install.txt
echo "   - Telegram: @Jerry_SBG" | tee -a log-install.txt
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
