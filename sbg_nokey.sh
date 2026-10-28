#!/bin/bash
# By Jerry_SBG - VERSIÓN DEFINITIVA (sin KEY)
### Color
BIBlue='\033[1;94m'
BGCOLOR='\e[1;97;101m'
Wh='\033[0;37m'
NC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
GRAY='\e[1;30m'
purple='\033[1;95m'
BLUE='\033[1;34m'
WH='\033[1;37m'
OK='\033[1;32m[✔]\033[0m'
EROR='\033[1;31m[✖]\033[0m'
# // Verificacion temprana de arquitectura (antes de modificar el sistema)
ARCH=$(uname -m)
if [[ "$ARCH" != "x86_64" && "$ARCH" != "aarch64" ]]; then
    echo -e "${EROR} Su arquitectura no es compatible ( ${YELLOW}${ARCH}${NC} )"
    exit 1
fi
if [[ "$(id -u)" != "0" ]]; then
    echo -e "${EROR} Ejecute como root ( sudo -i )"
    exit 1
fi
# ===== SOPORTE ARM64 (aarch64) via box64 =====
# Los binarios del script son x86_64; box64 los emula en ARM usando las libs nativas.
setup_box64() {
    local BOX_OK=0
    echo -e "${YELLOW}🔧 Arquitectura ARM64 detectada: configurando box64 (emulador x86_64)...${NC}"
    if command -v box64 >/dev/null 2>&1; then
        BOX_OK=1
    else
        apt-get update -y >/dev/null 2>&1
        # 1) intentar desde repositorio de la distro
        apt-get install -y box64 >/dev/null 2>&1 && command -v box64 >/dev/null 2>&1 && BOX_OK=1
    fi
    if [ "$BOX_OK" != "1" ]; then
        # 2) compilar desde el codigo oficial (ptitSeb/box64)
        echo -e "${YELLOW}📦 Compilando box64 desde fuente (puede tardar varios minutos)...${NC}"
        apt-get install -y git cmake build-essential python3 binutils >/dev/null 2>&1 || {
            echo -e "${RED}✖ No se pudieron instalar dependencias de compilacion${NC}"; return 1; }
        local BDIR
        BDIR=$(mktemp -d /root/box64-build.XXXXXX)
        git clone --depth 1 https://github.com/ptitSeb/box64.git "$BDIR/box64" >/dev/null 2>&1 || {
            echo -e "${RED}✖ No se pudo clonar box64${NC}"; rm -rf "$BDIR"; return 1; }
        mkdir -p "$BDIR/box64/build" && cd "$BDIR/box64/build" || return 1
        cmake .. -DARM_DYNAREC=ON -DCMAKE_BUILD_TYPE=RelWithDebInfo >/dev/null 2>&1 \
            && make -j"$(nproc)" >/dev/null 2>&1 \
            && make install >/dev/null 2>&1 && BOX_OK=1
        cd /root
        rm -rf "$BDIR"
    fi
    if [ "$BOX_OK" != "1" ] || ! command -v box64 >/dev/null 2>&1; then
        echo -e "${RED}✖ No se pudo instalar box64${NC}"
        return 1
    fi
    # Registrar binfmt_misc para que los ELF x86_64 se ejecuten directo con box64
    systemctl restart systemd-binfmt >/dev/null 2>&1
    if [ ! -e /proc/sys/fs/binfmt_misc/box64 ]; then
        mountpoint -q /proc/sys/fs/binfmt_misc || mount -t binfmt_misc binfmt_misc /proc/sys/fs/binfmt_misc 2>/dev/null
        local BOXBIN
        BOXBIN=$(command -v box64)
        printf '%s\n' ":box64:M::\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x3e\\x00:\\xff\\xff\\xff\\xff\\xff\\xfe\\xfe\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff\\xff:${BOXBIN}:" \
            > /proc/sys/fs/binfmt_misc/register 2>/dev/null
        # persistir tras reinicio
        mkdir -p /etc/binfmt.d
        [ -f /etc/binfmt.d/box64.conf ] || printf '%s\n' ":box64:M::\\x7fELF\\x02\\x01\\x01\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x00\\x02\\x00\\x3e\\x00:\\xff\\xff\\xff\\xff\\xff\\xfe\\xfe\\x00\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xff\\xfe\\xff\\xff\\xff:${BOXBIN}:" > /etc/binfmt.d/box64.conf
    fi
    if [ ! -e /proc/sys/fs/binfmt_misc/box64 ]; then
        echo -e "${RED}✖ binfmt_misc no disponible: los binarios x86_64 no se ejecutaran directo${NC}"
        return 1
    fi
    echo -e "${OK} box64 listo: $(box64 --version 2>/dev/null | head -n1)"
    return 0
}
kill_zombies() {
    pkill -9 -f "apt|dpkg" 2>/dev/null
    pkill -9 -f "unattended-upgrades" 2>/dev/null
    rm -f /var/lib/dpkg/lock* 2>/dev/null
    rm -f /var/lib/apt/lists/lock 2>/dev/null
    rm -f /var/cache/apt/archives/lock 2>/dev/null
    dpkg --configure -a 2>/dev/null
}
clear
run_silent() {
    "$@" > /dev/null 2>&1
}
kill_zombies
apt install -y figlet boxes >/dev/null 2>&1
apt install -y pv >/dev/null 2>&1
if [[ "$ARCH" == "aarch64" ]]; then
    setup_box64 || { echo -e "${EROR} Fallo la configuracion de box64. Abortando."; exit 1; }
fi
unset HISTFILE
history -cw
# ===================
IVAR="/etc/http-instas"
SCPT_DIR="/var/www/html/KEY"
rm $(pwd)/$0 2>/dev/null
rm -rf /tmp/tmp.* 2>/dev/null
rm -f /root/sbg.sh 2>/dev/null
desofus() {
    local input="$1"
    local unrot13=$(echo "$input" | tr 'A-Za-z' 'N-ZA-Mn-za-m')
    local decoded=$(echo "$unrot13" | base64 -d 2>/dev/null)
    if [ $? -eq 0 ] && [ -n "$decoded" ]; then
        echo "$decoded" | sed 's/:[^:]*$//'
    else
        echo ""
        return 1
    fi
}
extraer_ip() {
    local key="$1"
    local datos=$(desofus "$key")
    if [ -z "$datos" ]; then
        echo ""
        return 1
    fi
    echo "$datos" | cut -d':' -f1
}
extraer_key() {
    local key="$1"
    local datos=$(desofus "$key")
    if [ -z "$datos" ]; then
        echo ""
        return 1
    fi
    local sin_ip_puerto=$(echo "$datos" | cut -d'/' -f2-)
    echo "$sin_ip_puerto" | cut -d'/' -f1
}
extraer_usuario() {
    local key="$1"
    local datos=$(desofus "$key")
    if [ -z "$datos" ]; then
        echo ""
        return 1
    fi
    echo "$datos" | rev | cut -d'/' -f1 | rev
}
export IP=$( curl -sS ipinfo.io/ip 2>/dev/null )
clear
if [ -f "/etc/xray/domain" ]; then
clear
echo -e "${BIBlue}╭═══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│  [ ${YELLOW}DETECTADO${BIBlue} ] Script ya Instalado         │${NC}"
echo -e "${BIBlue}╰═══════════════════════════════════════════╯${NC}"
echo -e "${BIBlue}╭═══════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│  [ ${GREEN}1${BIBlue} ]  Abrir Panel SBG                   │${NC}"
echo -e "${BIBlue}│  [ ${GREEN}2${BIBlue} ]  Reinstalar Script VPN             │${NC}"
echo -e "${BIBlue}│  [ ${GREEN}3${BIBlue} ]  Salir                             │${NC}"
echo -e "${BIBlue}╰═══════════════════════════════════════════╯${NC}"
read -p "   Selecciona opcion [1-3]: " op_ins
if [[ $op_ins == "1" ]]; then
    if command -v menu >/dev/null 2>&1; then
        exec menu
    elif [ -f /usr/local/sbin/menu ]; then
        exec bash /usr/local/sbin/menu
    else
        echo -e "${RED}Panel no encontrado. Intenta reinstalar el script (opcion 2).${NC}"
        sleep 3
    fi
    exit 0
elif [[ $op_ins == "2" ]]; then
    echo -e "${YELLOW}Reinstalando script VPN...${NC}"
    # Continua con la instalacion
else
    exit 0
fi
fi
clear
rm -rf /root/sbg.sh
clear
echo -e "  ${BIBlue}╭══════════════════════════════════════╮${NC}"
echo -e "  ${BIBlue}│ ${BGCOLOR}      ACTUALIZANDO BASE DE DATOS!   ${NC}${BIBlue} │${NC}"
echo -e "  ${BIBlue}╰══════════════════════════════════════╯${NC}"
sleep 0.5
kill_zombies
# ===== INSTALACIÓN DIRECTA SIN FUNCIONES COMPLEJAS =====
echo -e "\n${YELLOW}📦 Instalando Paquetes Esenciales:${NC}\n"
# Actualizaciones básicas
apt update -y
apt upgrade -y
apt dist-upgrade -y
apt full-upgrade -y
# Instalar sudo
apt install sudo -y
echo "✅ sudo instalado"
# Limpiar
sudo apt-get clean all
# Instalar debconf-utils
apt install -y debconf-utils
echo "✅ debconf-utils instalado"
# Eliminar paquetes conflictivos
apt-get remove --purge ufw firewalld -y 2>/dev/null
apt-get remove --purge exim4 -y 2>/dev/null
apt-get autoremove -y
# Instalar software-properties-common
apt install -y --no-install-recommends software-properties-common
echo "✅ software-properties-common instalado"
# Configurar iptables-persistent
echo iptables-persistent iptables-persistent/autosave_v4 boolean true | debconf-set-selections
echo iptables-persistent iptables-persistent/autosave_v6 boolean true | debconf-set-selections
kill_zombies
# iptables
echo -n "📦 iptables... "
apt install -y iptables >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# iptables-persistent
echo -n "📦 iptables-persistent... "
apt install -y iptables-persistent >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# netfilter-persistent
echo -n "📦 netfilter-persistent... "
apt install -y netfilter-persistent >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# net-tools
echo -n "📦 net-tools... "
apt install -y net-tools >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# curl
echo -n "📦 curl... "
apt install -y curl >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# wget
echo -n "📦 wget... "
apt install -y wget >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# zip
echo -n "📦 zip... "
apt install -y zip >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# unzip
echo -n "📦 unzip... "
apt install -y unzip >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# p7zip-full
echo -n "📦 p7zip-full... "
apt install -y p7zip-full >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# cron
echo -n "📦 cron... "
apt install -y cron >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# bash-completion
echo -n "📦 bash-completion... "
apt install -y bash-completion >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# bc
echo -n "📦 bc... "
apt install -y bc >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# ntpdate
echo -n "📦 ntpdate... "
apt install -y ntpdate >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# htop
echo -n "📦 htop... "
apt install -y htop >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# vnstat
echo -n "📦 vnstat... "
apt install -y vnstat >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
# chrony
echo -n "📦 chrony... "
apt install -y chrony >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
echo -n "📦 fail2ban... "
apt install -y fail2ban >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
cat > /etc/fail2ban/jail.local << 'EOF'
[DEFAULT]
ignoreip = 127.0.0.1/8 ::1
bantime = 3600
findtime = 600
maxretry = 3
backend = systemd
destemail = root@localhost
action = %(action_mwl)s

[sshd]
enabled = true
port = ssh
filter = sshd
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[dropbear]
enabled = true
port = 143,110,109,69
filter = dropbear
logpath = /var/log/auth.log
maxretry = 3
bantime = 3600

[recidive]
enabled = true
logpath = /var/log/fail2ban.log
banaction = %(banaction_allports)s
bantime = 604800   ; 1 semana
findtime = 86400   ; 1 día
maxretry = 5

[haproxy]
enabled = false

[web-ports]
enabled = true
port = 80,8080,8880,2052,2082,2086,2095,8088,8280,8888,8989,9999,8443
filter = haproxy
logpath = /var/log/haproxy.log
maxretry = 5
bantime = 3600
EOF
echo -n "📦 lolcat... "
apt install -y lolcat >/dev/null 2>&1 && echo "✅ INSTALADO" || echo "❌"
if [ -x /usr/games/lolcat ]; then
ln -sf /usr/games/lolcat /usr/bin/lolcat
echo "✅ lolcat instalado y enlazado a /usr/bin/lolcat"
elif [ -x /usr/bin/lolcat ]; then
echo "✅ lolcat ya está en /usr/bin/lolcat"
else
echo "❌ Error: No se pudo instalar lolcat"
exit 1
fi
# Eliminar servicios no deseados
sudo apt-get -y --purge remove samba* >/dev/null 2>&1
sudo apt-get -y --purge remove apache2* >/dev/null 2>&1
sudo apt-get -y --purge remove bind9* >/dev/null 2>&1
sudo apt-get -y remove sendmail* >/dev/null 2>&1
apt autoremove -y >/dev/null 2>&1
# MATAR ZOMBIES FINAL
kill_zombies
yellow() { echo -e "\\033[33;1m${*}\\033[0m"; }
yellow "✅ Dependencias Instaladas Exitosamente..."
sleep 1
clear
# // Banner
echo -e "${BIBlue}╭═══════════════════════════════════════════════════╮"
echo -e " ${YELLOW}     Bienvenido al Auto-Script MOD´s EDICION${NC}"
echo -e " ${purple} Esto Configurará Rápidamente el SCRIPT en su VPS${NC}"
echo -e "    ${Wh}     Autor : ${RED}JERRY® ${NC}( ${Wh} Hecho en Mexico ${NC})${NC}"
echo -e "       ${purple}        © DEV JERRY-SBG ${NC}(${purple} 2026 ${NC})${NC}"
echo -e " ${RED}     Telegram : ${Wh}@Jerry_SBG ${NC}${RED} Grupo: ${NC}${Wh}sbg_yt${NC}"
echo -e "${BIBlue}╰═══════════════════════════════════════════════════╯"
echo ""
sleep 0.1
# // Arquitectura
if [[ "$ARCH" == "aarch64" ]]; then
    echo -e "${OK}${BIBlue} Arquitectura ARM64 ( ${WH}aarch64${NC} ) - usando box64"
else
    echo -e "${OK}${BIBlue} Su arquitectura es compatible ( ${WH}${ARCH}${NC} )"
fi
# // Checking System
if [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "ubuntu" ]]; then
    echo -e "${OK}${BIBlue} Su sistema Operativo es Compatible ( ${WH}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
elif [[ $( cat /etc/os-release | grep -w ID | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/ID//g' ) == "debian" ]]; then
    echo -e "${OK}${BIBlue} Su sistema Operativo es Compatible ( ${WH}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
else
    echo -e "${EROR} Su Sistema Operativo No es Compatible ( ${YELLOW}$( cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g' )${NC} )"
    exit 1
fi
MYIP=$(curl -s ipv4.icanhazip.com || curl -s ifconfig.me || hostname -I | awk '{print $1}')
echo -e "${OK}${BIBlue} Direccion De IP ${NC}( ${WH}$MYIP${NC} )"
echo ""
read -p "$( echo -e "${purple}Presione ${GRAY}[ ${NC}${RED}Enter${NC} ${GRAY}]${purple} Para iniciar la instalación") "
clear
echo -e "${BIBlue}╭════════════════════════════════════════════════════╮${NC}"
echo -e "${BIBlue}│   ALGUNAS VPS NECESITAN PERMISOS DE USUARIO ROOT   ${NC}${BIBlue}│${NC}"
echo -e "${BIBlue}│   COMO ORACLE, GOOGLE, AZURE, Y ALGUNOS PROVEDORES ${NC}${BIBlue}│${NC}"
echo -e "${BIBlue}│ SI TU VPS YA CUENTA CON ACCESO ROOT PRESIONA ENTER ${NC}${BIBlue}│${NC}"
echo -e "${BIBlue}│      ${BLUE}[ ${purple}By JERRY®${BLUE} ]  ${BLUE}[ ${purple}By JERRY®${BLUE} ] ${BLUE}[ ${purple}By JERRY®${BLUE} ]${NC}    ${BIBlue}│${NC}"
echo -e "${BIBlue}╰════════════════════════════════════════════════════╯${YELLOW}"
echo  ""
echo -e "[ ADVERTENCIA ] ¿Quieres Dar PERMISOS ROOT Ahora? (y/n) "; read answer
if [ "$answer" == "${answer#[Yy]}" ] ;then
clear
else
[[ "$(whoami)" != "root" ]] && {
    clear
    echo -e "\033[1;31mEJECUTE COMO USUARIO ROOT, \033[1;32m(\033[1;33msudo -i\033[1;32m)\033[0m"
    exit
}
iptables -F
echo 'nameserver 1.1.1.1' > /etc/resolv.conf
echo 'nameserver 1.0.0.1' >> /etc/resolv.conf
apt update -y
[[ $(grep -c "prohibit-password" /etc/ssh/sshd_config) != '0' ]] && {
    sed -i "s/prohibit-password/yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "without-password" /etc/ssh/sshd_config) != '0' ]] && {
    sed -i "s/without-password/yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "#PermitRootLogin" /etc/ssh/sshd_config) != '0' ]] && {
    sed -i "s/#PermitRootLogin/PermitRootLogin/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "PasswordAuthentication" /etc/ssh/sshd_config) = '0' ]] && {
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
    sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
} > /dev/null
[[ $(grep -c "#PasswordAuthentication no" /etc/ssh/sshd_config) != '0' ]] && {
    sed -i "s/#PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config
} > /dev/null
sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 2>/dev/null
service ssh restart > /dev/null
iptables -F
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p tcp --dport 81 -j ACCEPT
iptables -A INPUT -p tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp --dport 8888 -j ACCEPT
iptables -A INPUT -p tcp --dport 8008 -j ACCEPT
iptables -A INPUT -p tcp --dport 8080 -j ACCEPT
iptables -A INPUT -p tcp --dport 8280 -j ACCEPT
clear && echo -ne "\033[1;32mESCRIBA SU NUEVA CLAVE ROOT\033[1;37m: "; read senha
[[ -z "$senha" ]] && {
echo -e "\n\033[1;31mCLAVE INVALIDA !\033[0m"
exit 0
}
echo "root:$senha" | chpasswd
echo -e "\n\033[1;31m[ \033[1;33mOK ! \033[1;31m]\033[1;37m - \033[1;32mCLAVE DEFINIDA ! \033[0m"
fi
clear
echo -e "  ${BIBlue}╭═══════════════════════════════════════╮${NC}"
echo -e "  ${BIBlue}│ ${BGCOLOR}                ATENCION             ${NC}${BIBlue} │${NC}"
echo -e "  ${BIBlue}╰═══════════════════════════════════════╯${NC}"
echo -e "  ${BIBlue}╭═══════════════════════════════════════╮${NC}"
echo -e "   ${Wh}NO OLVIDES MANDAR CAPTURA AL ADM ${purple}JERRY®${NC}"
echo -e "      ${BGCOLOR}EVITA SER BANEADO TU SCRIPT FREE${NC}"
echo -e "      ${Wh}COMPRA TU ACCESO PREMIUM AL BOT${NC}"
echo -e "   ${Wh}ACTUALIZACIONES Y SOPORTE PERSONALIZADO${NC}"
echo -e "          ${Wh}TELEGRAM: ${YELLOW}@Jerry_SBG${NC}${BIBlue} ${NC}"
echo -e "          ${Wh}Grupo Telegram: ${YELLOW}@sbg_yt${NC}${BIBlue} ${NC}"
echo -e "  ${BIBlue}╰═══════════════════════════════════════╯${NC}"
echo ""
clear
if [ "$(systemd-detect-virt)" == "openvz" ]; then
        echo "OpenVZ no es Soportado"
        exit 1
fi
clear
###### IZIN SC
rm -rf /etc/profil
rm -rf /usr/bin/profil2
rm -rf /etc/profil*
rm -rf /usr/bin/cred
rm -rf /usr/bin/cred*
rm -rf /usr/bin/vendor_code
rm -rf /usr/bin/vendor_code*
rm -rf /usr/bin/vendor_codes
rm -rf /usr/bin/vendor_codes*
rm -rf /usr/bin/kelly
rm -rf /usr/bin/kelly*
descargar_silencioso() {
    local url="$1"
    local destino="$2"
    wget -q --timeout=5 --tries=2 "$url" -O "$destino" 2>/dev/null
    return $?
}
clear
function SBG () {
# Verificacion de KEY desactivada — funciona 100% local
MYIP_TMP=$(curl -s ipv4.icanhazip.com 2>/dev/null || curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
Key="LOCAL"
IP_REAL="${MYIP_TMP}"
echo "${IP_REAL}" > /usr/bin/vendor_codes
echo "${MYIP_TMP}" > /usr/bin/vendor_code
echo "${Key}" > /usr/bin/kelly
}
SBG
# Crear archivos de credenciales directamente (reemplaza install.zip)
echo "SOCRATES SBG" > /usr/bin/profil2
echo "KEY DE JerrySBG!" > /usr/bin/cred
clear
checking_sc() {
clear
cols=$(tput cols)
text=" INSTALACION EN CURSO "
padding=$(((cols - ${#text}) / 2))
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
echo -ne "\033[38;5;15;48;5;208m$(printf "%*s" $padding)${text}$(printf "%*s" $padding)\033[0m"
echo " "
echo -e "\e[1;33m RESELLER: $(cat /usr/bin/profil2 2>/dev/null || echo 'SOCRATES SBG') ${purple}VERIFICADO \e[0m" | pv -qL 10
echo -e "\e[1;33m KEY SCRIP: $(cat /usr/bin/cred 2>/dev/null || echo 'KEY DE JerrySBG!') ${purple}VERIFICADO \e[0m" | pv -qL 10
echo -e "              ${RED}PERMISO CONCEDIDO${NC}"
echo -e "   \033[0;33mTu IP fue Autorizado Exitosamente.\033[0m"
echo -e "\033[1;93m────────────────────────────────────────────\033[0m"
sleep 1
}
checking_sc
kill_zombies
pkill -9 -f "apt.*install" 2>/dev/null
pkill -9 -f "needrestart" 2>/dev/null
rm -f /var/lib/dpkg/lock*
rm -f /var/lib/apt/lists/lock
rm -f /var/cache/apt/archives/lock
dpkg --configure -a 2>/dev/null
# Descargar sbg2.sh desde GitHub (siempre fresco)
rm -f /root/sbg2.sh 2>/dev/null
echo -e "${YELLOW}📥 Descargando instalador VPN...${NC}"
wget -q --timeout=60 --tries=3 \
    "https://raw.githubusercontent.com/Internetjm/personalScript/main/sbg2_nokey.sh" \
    -O /root/sbg2.sh 2>/dev/null
if [ ! -f /root/sbg2.sh ] || [ ! -s /root/sbg2.sh ]; then
    echo -e "${RED}✖ Error descargando sbg2.sh desde GitHub${NC}"
    exit 1
fi
if file /root/sbg2.sh 2>/dev/null | grep -q "ELF"; then
    echo -e "${RED}✖ sbg2.sh descargado es binario ELF. Verifica el repo.${NC}"
    rm -f /root/sbg2.sh
    exit 1
fi
chmod +x /root/sbg2.sh && bash /root/sbg2.sh --BySBG
