#!/bin/bash
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export YELLOW='\033[0;33m';
export RED="\033[0;31m"
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
clear
echo ""
echo " Esta función solo se puede utilizar según los datos del VPS con este script automático"
echo " Inserte el enlace de copia de seguridad de datos del VPS para restaurar los datos"
echo ""
read -rp "Link File: " -e url
cd
mkdir -p /root/backup
wget -O backup.zip "$url"
unzip -o backup.zip  &> /dev/null
rm -f backup.zip
sleep 1
echo Start Restore
cd /root/backup
echo -e "[ ${green}INFO${NC} ] Inicinado RESTAURACION . . . "
cp -r passwd /etc/ &> /dev/null
cp -r group /etc/ &> /dev/null
cp -r shadow /etc/ &> /dev/null
cp -r xray /etc/xray/config.json &> /dev/null
cp -r ssh /etc/xray/ssh &> /dev/null
cp -r idchat /usr/bin/idchat &> /dev/null
cp -r token /usr/bin/token &> /dev/null
cp -r id /etc/per/id &> /dev/null
cp -r token2 /etc/per/token &> /dev/null
cp -r loginid /etc/perlogin/id &> /dev/null
cp -r logintoken /etc/perlogin/token &> /dev/null
cp -r public_html /home/vps/ &> /dev/null
cp -r gshadow /etc/ &> /dev/null
cp -r sshx /etc/xray/ &> /dev/null
cp -r vmess /etc/ &> /dev/null
cp -r vless /etc/ &> /dev/null
cp -r trojan /etc/ &> /dev/null
cp -r issue /etc/issue.net &> /dev/null
echo ""
echo -e "[ ${green}INFO${NC} ] Datos VPS Restaurados Completamente !"
echo ""
echo -e "[ ${green}INFO${NC} ] Resinicinado TODOS los Servicios
systemctl restart xray
systemctl restart nginx
cd
rm -rf *
sleep 0.5
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
menue/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
ipsaya=$(wget -qO- ipinfo.io/ip)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
checking_sc() { clear }
echo -e "${COLOR1}│             \033[0;32mTELEGRAM: @Jerry_SBG ${NC}               ${COLOR1}│"
echo -e "${COLOR1}│             \033[0;32mWHATSAPP: 0529241293310 ${NC}            ${COLOR1}│"
echo -e "${COLOR1}└─────────────────────────────────────────────────┘${NC}"
exit
fi
}
clear
echo ""
echo " Esta función solo se puede utilizar según los datos del VPS con este script automático"
echo " Inserte el enlace de copia de seguridad de datos del VPS para restaurar los datos"
echo ""
read -rp "Link del Archivo: " -e url
cd
mkdir -p /root/backup
wget -O backup.zip "$url"
unzip -o backup.zip  &> /dev/null
rm -f backup.zip
sleep 1
echo Start Restore
cd /root/backup
echo -e "[ ${green}INFO${NC} ] Iniciando RESTAURACION . . . "
cp -r passwd /etc/ &> /dev/null
cp -r group /etc/ &> /dev/null
cp -r shadow /etc/ &> /dev/null
cp -r xray /etc/xray/config.json &> /dev/null
cp -r ssh /etc/xray/ssh &> /dev/null
cp -r idchat /usr/bin/idchat &> /dev/null
cp -r token /usr/bin/token &> /dev/null
cp -r id /etc/per/id &> /dev/null
cp -r token2 /etc/per/token &> /dev/null
cp -r loginid /etc/perlogin/id &> /dev/null
cp -r logintoken /etc/perlogin/token &> /dev/null
cp -r public_html /home/vps/ &> /dev/null
cp -r gshadow /etc/ &> /dev/null
cp -r sshx /etc/xray/ &> /dev/null
cp -r vmess /etc/ &> /dev/null
cp -r vless /etc/ &> /dev/null
cp -r trojan /etc/ &> /dev/null
cp -r issue /etc/issue.net &> /dev/null
echo ""
echo -e "[ ${green}INFO${NC} ] Datos VPS Restaurados Completamente !"
echo ""
echo -e "[ ${green}INFO${NC} ] Reiniciando TODOS los Servicios"
systemctl restart xray
systemctl restart nginx
dateFromServer=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export YELLOW='\033[0;33m';
export RED="\033[0;31m"
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
ipsaya=$(wget -qO- ipinfo.io/ip)
data_server=$(curl -v --insecure --silent https://google.com/ 2>&1 | grep Date | sed -e 's/< Date: //')
date_list=$(date +"%Y-%m-%d" -d "$data_server")
checking_sc() { clear }COMPRA ACCESO AL SCRIPT POR FAVOR ${NC}          ${COLOR1}│"
echo -e "${COLOR1}│             \033[0;32mTELEGRAM: @Jerry_SBG ${NC}               ${COLOR1}│"
echo -e "${COLOR1}│             \033[0;32mWHATSAPP: 0529241293310 ${NC}            ${COLOR1}│"
echo -e "${COLOR1}└─────────────────────────────────────────────────┘${NC}"
exit
fi
}
clear
echo ""
echo " Esta función solo se puede utilizar según los datos del VPS con este script automático"
echo " Inserte el enlace de copia de seguridad de datos del VPS para restaurar los datos"
echo ""
read -rp "Link File: " -e url
cd
mkdir -p /root/backup
wget -O backup.zip "$url"
unzip -o backup.zip  &> /dev/null
rm -f backup.zip
sleep 1
echo Start Restore
cd /root/backup
echo -e "[ ${green}INFO${NC} ] Iniciando RESTAURACION . . . "
cp -r passwd /etc/ &> /dev/null
cp -r group /etc/ &> /dev/null
cp -r shadow /etc/ &> /dev/null
cp -r xray /etc/xray/config.json &> /dev/null
cp -r ssh /etc/xray/ssh &> /dev/null
cp -r idchat /usr/bin/idchat &> /dev/null
cp -r token /usr/bin/token &> /dev/null
cp -r id /etc/per/id &> /dev/null
cp -r token2 /etc/per/token &> /dev/null
cp -r loginid /etc/perlogin/id &> /dev/null
cp -r logintoken /etc/perlogin/token &> /dev/null
cp -r public_html /home/vps/ &> /dev/null
cp -r gshadow /etc/ &> /dev/null
cp -r sshx /etc/xray/ &> /dev/null
cp -r vmess /etc/ &> /dev/null
cp -r vless /etc/ &> /dev/null
cp -r trojan /etc/ &> /dev/null
cp -r issue /etc/issue.net &> /dev/null
echo ""
echo -e "[ ${green}INFO${NC} ] Datos VPS Restaurados Completamente !"
echo ""
echo -e "[ ${green}INFO${NC} ] Resinicinado TODOS los Servicios"
systemctl restart xray
systemctl restart nginx
cd
rm -rf *
sleep 0.5
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
mene
