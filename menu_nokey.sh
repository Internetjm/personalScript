#!/bin/bash
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
JS=$(cat /usr/bin/vendor_codes 2>/dev/null || echo "")
#ipsaya=$(wget -qO- ipinfo.io/ip)
ipsaya=$(hostname -I | cut -f1 -d" ")
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export RED="\033[0;31m"
export BLACK="\033[1;30m"
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
yl='\033[33m';
purple="\033[1;95m"
tram=$( free -m | awk 'NR==2 {print $2}' )
uram=$( free -m | awk 'NR==2 {print $3}' )
#ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
PAIS=$(cat /etc/xray/pais)
DAY=$(date +%A)
DATE=$(date +%Y-%m-%d)
DATE2=$(date -R | cut -d " " -f -5)
Fecha=$(date +"%A, %e de %B del %Y" -d "$data_server")
TIMEZONE=$(printf '%(%I:%M %p)T')
export RED='\033[0;31m'
export GREEN='\033[0;32m'
clear
function iinfo(){
clear
}
checking_sc() {
clear
}
checking_sc
rm -rf /root/checkIP.*
rm -rf /root/status
rm -rf /tmp/tmp.*
clear
if [ ! -e /etc/per/id ]; then
mkdir -p /etc/per
echo "" > /etc/per/id
echo "" > /etc/per/token
elif [ ! -e /etc/perlogin/id ]; then
mkdir -p /etc/perlogin
echo "" > /etc/perlogin/id
echo "" > /etc/perlogin/token
elif [ ! -e /usr/bin/id ]; then
echo "" > /usr/bin/idchat
echo "" > /usr/bin/token
fi
if [ ! -e /etc/xray/ssh ]; then
echo "" > /etc/xray/ssh
elif [ ! -e /etc/xray/token ]; then
echo "" > /etc/xray/token
elif [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
elif [ ! -e /etc/xray/sshx/listlock ]; then
echo "" > /etc/xray/sshx/listlock
elif [ ! -e /etc/vmess ]; then
mkdir -p /etc/vmess
elif [ ! -e /etc/vmess/listlock ]; then
echo "" > /etc/vmess/listlock
elif [ ! -e /etc/vless ]; then
mkdir -p /etc/vless
elif [ ! -e /etc/vless/listlock ]; then
echo "" > /etc/vless/listlock
elif [ ! -e /etc/trojan ]; then
mkdir -p /etc/trojan
elif [ ! -e /etc/trojan/listlock ]; then
echo "" > /etc/trojan/listlock
elif [ ! -e /etc/xray/patch ]; then
echo "ByJerry" > /etc/xray/patch
fi
if ! find /var/www/html/ -name "CheckUser" -print -quit; then
clear
    else
touch /var/www/html/CheckUser
fi
clear
MODEL2=$(cat /etc/os-release | grep -w PRETTY_NAME | head -n1 | sed 's/=//g' | sed 's/"//g' | sed 's/PRETTY_NAME//g')
check_service() {
    local service_name=$1
    # Verificar si el servicio existe
    if systemctl list-unit-files "$service_name.service" >/dev/null 2>&1 || \
       [ -f "/etc/systemd/system/$service_name.service" ] || \
       [ -f "/lib/systemd/system/$service_name.service" ]; then
        # Verificar si está activo
        if systemctl is-active "$service_name" >/dev/null 2>&1; then
            echo "${COLOR1}ON${NC}"
        else
            # Intentar reiniciar UNA VEZ si está instalado pero apagado
            systemctl daemon-reload >/dev/null 2>&1
            systemctl restart "$service_name" >/dev/null 2>&1
            sleep 0.5           
            if systemctl is-active "$service_name" >/dev/null 2>&1; then
                echo "${COLOR1}ON${NC}"
            else
                echo "${RED}OFF${NC}"
            fi
        fi
    else
        echo "${RED}OFF${NC}"
    fi
}
status_ssl=$(check_service haproxy)
status_nginx=$(check_service nginx)
status_xray=$(check_service xray)
status_ws=$(check_service ws)
status_beruangjatuh=$(check_service dropbear)
status_udp=$(check_service udp-custom)
status_zivpn=$(check_service zivpn)
status_hysteria=$(check_service udpmod)
# TOTAL CREATE ACC VMESS
vmess=$(grep -c -E "^#vmg " "/etc/xray/config.json")
# TOTAL CREATE ACC VLESS
vless=$(grep -c -E "^#vlg " "/etc/xray/config.json")
# TOTAL CREATE ACC TROJAN
trtls=$(grep -c -E "^#trg " "/etc/xray/config.json")
# TOTAL CREATE ACC SSH
total_ssh=$(grep -c -E "^### " "/etc/xray/ssh")
total_token=$(grep -c -E "^### " "/etc/xray/token")
# TOTAL CREATE ACC NOOBZ
#jumlah_noobz=$(grep -c -E "^### " "/etc/xray/noob")
# TOTAL CREATE ACC TROJAN-GO
#jumlah_trgo=$(grep -c -E "^### " "/etc/trojan-go/trgo")
# TOTAL CREATE ACC SHADOW
shadow=$(grep -c -E "^## " "/etc/xray/config.json")
uphours=`uptime -p | awk '{print $2,$3}' | cut -d , -f1`
upminutes=`uptime -p | awk '{print $4,$5}' | cut -d , -f1`
uptimecek=`uptime -p | awk '{print $6,$7}' | cut -d , -f1`
cekup=`uptime -p | grep -ow "day"`
function m-bot2(){
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}  ${WH}Please select a Bot type below                 ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}  [ 1 ] ${WH}Buat/Edit BOT INFO Multi Login SSH, XRAY & TRANSAKSI   ${NC}"
echo -e "${COLOR1}  [ 2 ] ${WH}Buat/Edit BOT INFO Create User & Lain Lain    ${NC}"
echo -e ""
echo -e "${COLOR1}  [ 3 ] ${WH}Buat/Edit BOT INFO Backup Telegram    ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
read -p "   Please select numbers 1-3 or Any Button(Random) to exit : " bot
echo ""
if [[ $bot == "1" ]]; then
clear
rm -rf /etc/perlogin
mkdir -p /etc/perlogin
cd /etc/perlogin
touch token
touch id
echo -e ""
echo -e "${COLOR1} [ INFO ] ${WH}Create for database Multi Login"
read -rp "Enter Token (Creat on @BotFather) : " -e token2
echo "$token2" > token
read -rp "Enter Your Id (Creat on @userinfobot)  : " -e idat
echo "$idat" > id
sleep 1
m-bot2
fi
if [[ $bot == "2" ]]; then
clear
rm -rf /etc/per
mkdir -p /etc/per
cd /etc/per
touch token
touch id
echo -e ""
echo -e "${COLOR1} [ INFO ] ${WH}Create for database Akun Dan Lain Lain"
read -rp "Enter Token (Creat on @BotFather) : " -e token3
echo "$token3" > token
read -rp "Enter Your Id (Creat on @userinfobot)  : " -e idat2
echo "$idat2" > id
sleep 1
m-bot2
fi
if [[ $bot == "3" ]]; then
clear
rm -rf /usr/bin/token
rm -rf /usr/bin/idchat
echo -e ""
echo -e "${COLOR1} [ INFO ] ${WH}Create for database Backup Telegram"
read -rp "Enter Token (Creat on @BotFather) : " -e token23
echo "$token23" > /usr/bin/token
read -rp "Enter Your Id (Creat on @userinfobot)  : " -e idchat
echo "$idchat" > /usr/bin/idchat
sleep 1
m-bot2
fi
menu
}
clear && clear && clear
sleep 0.01
clear
echo -e " ${COLOR1}╭══════════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│${NC} \E[40;1;30m       ${WH} .::::. ᴀᴜᴛᴏꜱᴄʀɪᴘᴛ ᴍᴜʟᴛɪᴘᴏʀᴛ ꜰʀᴇᴇ .::::.         ${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}╰══════════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭══════════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│$NC${WH} ❈ OS            ${COLOR1}: ${WH}$MODEL2 ❈ RAM: $tram / $uram MB${NC}"
echo -e " ${COLOR1}│$NC${WH} ❈ FECHA         ${COLOR1}: ${WH}$Fecha${NC}"
echo -e " ${COLOR1}│$NC${WH} ❈ ACTIVO        ${COLOR1}: ${WH}$uphours $upminutes $uptimecek❈ HORA:$TIMEZONE"
#echo -e " ${COLOR1}│$NC${WH} ❈ CIUDAD-PAIS   ${COLOR1}: ${WH}$CITY $PAIS${NC}"
echo -e " ${COLOR1}│$NC${WH} ❈ IP VPS        ${COLOR1}: ${WH}$ipsaya${NC}"
echo -e " ${COLOR1}│$NC${WH} ❈ DOMINIO       ${COLOR1}: ${WH}$(cat /etc/xray/domain)"
echo -e " ${COLOR1}╰══════════════════════════════════════════════════════════╯${NC}"
echo -e "    ${COLOR1}╭═════════════════ • ${NC}${WH}STATUS SERVER${NC}${COLOR1} • ═══════════════╮${NC}"
#sleep 1
echo -e "     ${WH} SSH SSL : ${status_ssl} ${WH} XRAY : ${status_xray} ${WH} NGINX : ${status_nginx} ${WH} DROPBEAR : ${status_beruangjatuh}$NC"
echo -e "         ${WH} HA-PROXY : ${status_ssl} ${WH} SSH WS : ${status_ws} ${WH} UDP-CUSTOM : ${status_udp} ${NC}"
echo -e "    ${COLOR1}╰═══════════════════════════════════════════════════╯${NC}"
echo -e "        ${COLOR1}╭════════════════════════════════════════════╮${NC}"
echo -e "                 ${COLOR1}$NC${WH}    LISTA CUENTAS PREMIUM ${NC}"
echo -e "        ${COLOR1}      ═════════════════════════════════ ${NC}"
printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " SSH/OPVPN   =" "$total_ssh" "ACCOUNT "
printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " VMESS/WS    =" "$vmess" "ACCOUNT "
printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " VLESS/WS    =" "$vless" "ACCOUNT "
printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " TROJAN/GRPC =" "$trtls" "ACCOUNT "
#printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " NOOBZVPNS   =" "$jumlah_noobz" "ACCOUNT "
#printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " TROJAN-GO   =" "$jumlah_trgo" "ACCOUNT "
printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " SHADOW-SOCK =" "$shadow" "ACCOUNT "
printf "                \033[1;37m%-16s ${COLOR1}%-4s${NC} ${WH}%-5s\e[0m\n" " TOKEN =" "$total_token" "ACCOUNT "
echo -e "        ${COLOR1}╰════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭═════════════════════ • ${WH}LISTA MENU${NC}${COLOR1} • ═════════════════════╮${NC}"
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}SSH-WS     ${RED}$total_ssh ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}BOT PANEL       ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}"
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}VMESS      ${RED}$vmess ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}BOT NOTIFICAC.  ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}"    
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}VLESS      ${RED}$vless ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}• ${WH}CAMBIAR DOMINIO ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}"    
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}SHADO-SOCK ${RED}$shadow ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}89${WH}]${NC} ${COLOR1}• ${WH}EDITAR BANER    ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}"   
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}TROJAN     ${RED}$trtls ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}11${WH}]${NC} ${COLOR1}• ${WH}OTRAS OPCIONES  ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}" 
#echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}TROJAN-GO    ${WH}[${COLOR1}Menu${WH}] ${NC} ${COLOR1}│${NC} ${WH}[${COLOR1}12${WH}]${NC} ${COLOR1}• ${WH}RESPALDAR VPS   ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}" 
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}MODO TOKEN ${RED}$total_token ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}12${WH}]${NC} ${COLOR1}• ${WH}REINICIAR VPS   ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}" 
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}BORRAR EXP   ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}13${WH}]${NC} ${COLOR1}• ${WH}RESET SERVICIOS ${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}"
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}24${WH}]${NC} ${COLOR1}• ${WH}SERVICIOS ON ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}25${WH}]${NC} ${COLOR1}• ${WH}INSTALAR SlowDNS${WH}[${COLOR1}Menu${WH}]${COLOR1}│${NC}"
echo -e " ${COLOR1}│$NC ${WH}[${COLOR1}26${WH}]${NC} ${COLOR1}• ${WH}INSTALAR UDP ${WH}[${COLOR1}Menu${WH}]${NC}${COLOR1}│${NC} ${WH}[${COLOR1}66${WH}]${NC} ${COLOR1}• ${WH}DESINTALAR SCRIPT ${WH}[${COLOR1}🔴${WH}]${COLOR1}│${NC}"
echo -e " ${COLOR1}╰══════════════════════════════════════════════════════════╯${NC}"
function rules(){
COLOR1='\033[1;94m'  
NC='\e[0m'
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════════════════╮${NC}"
echo -e " [ ${RED}ADVERTENCIA${NC} ] PRESIONA (s) PARA PODER USAR 2 O LOS 3 UDP"
echo -e " [ ${RED}ADVERTENCIA${NC} ] PRESIONA (n) SOLO TENDRAS UDP CUSTOM 1-65535"
echo -e "${COLOR1}╰═════════════════════════════════════════════════════════════╯${NC}"
echo ""
echo -e "[ ${RED}ADVERTENCIA${NC} ] ¿QUIERES USAR LOS 3 UDP´s Al MISMO TIEMPO? (s/n)"; read answer
if [ "$answer" == "${answer#[Ss]}" ] ;then
if systemctl is-enabled udp-custom.service >/dev/null 2>&1; then
    if systemctl is-active udp-custom >/dev/null 2>&1; then
        status_udp="${WH}ON${NC}"
    else
        status_udp="${RED}OFF${NC}"
        systemctl daemon-reload >/dev/null 2>&1
        systemctl restart udp-custom >/dev/null 2>&1
    fi
else
    status_udp="${RED}OFF${NC}"
fi
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│       ${WH}SIGUE Disfrutando del UDP-CUSTOM ${NC}"
echo -e "${COLOR1}│       ${WH}STATUS UDP CUSTOM : ${status_udp} Puertos: 1:65535  ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
sleep 2
clear
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
awk '!/53/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/1:65535/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/1:19999/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/20000:39999/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/40000:65535/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
sudo iptables -F
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8008 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8008 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8280 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8280 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8443 -j ACCEPT
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
sudo iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination :5300
sudo iptables -t nat -A PREROUTING -p udp --dport 1:65535 -j DNAT --to-destination :36715
netfilter-persistent save
netfilter-persistent reload
iptables -t nat -D PREROUTING 3
iptables -t nat -D PREROUTING 3
menu
else
clear
echo -e "    ${yl}INSTALANDO REGLAS DE PUERTOS UDPs..."
echo -e "    ${yl}PUERTOS ZIVPN: 1:19999..."
echo -e "    ${yl}PUERTOS HYSTERIA: 20000:39999..."
echo -e "    ${yl}PUERTOS UDP-CUSTOM: 40000-65535..."
sleep 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
awk '!/53/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/1:65535/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/1:19999/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/20000:39999/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
awk '!/40000:65535/' /etc/iptables/rules.v4 > /etc/iptables/rules2.v4; mv /etc/iptables/rules2.v4 /etc/iptables/rules.v4
sudo iptables -F
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 80 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8080 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8008 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8008 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8280 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8280 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m tcp -p tcp --dport 8443 -j ACCEPT
iptables -I INPUT -m state --state NEW -m udp -p udp --dport 8443 -j ACCEPT
iptables -A FORWARD -m string --string "get_peers" --algo bm -j DROP
iptables -A FORWARD -m string --string "announce_peer" --algo bm -j DROP
iptables -A FORWARD -m string --string "find_node" --algo bm -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "BitTorrent protocol" -j DROP
iptables -A FORWARD -m string --algo bm --string "peer_id=" -j DROP
iptables -A FORWARD -m string --algo bm --string ".torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce.php?passkey=" -j DROP
iptables -A FORWARD -m string --algo bm --string "torrent" -j DROP
iptables -A FORWARD -m string --algo bm --string "announce" -j DROP
iptables -A FORWARD -m string --algo bm --string "info_hash" -j DROP
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination :5300
iptables -t nat -A PREROUTING -p udp --dport 1:19999 -j DNAT --to-destination :5667
iptables -t nat -A PREROUTING -p udp --dport 20000:39999 -j DNAT --to-destination :36712
iptables -t nat -A PREROUTING -p udp --dport 40000:65535 -j DNAT --to-destination :36715
netfilter-persistent save
netfilter-persistent reload
iptables -t nat -D PREROUTING 5
iptables -t nat -D PREROUTING 5
iptables -t nat -D PREROUTING 5
iptables -t nat -D PREROUTING 5
clear
systemctl daemon-reload &>/dev/null
setupudp2
fi
}
function setupudp(){
if [ ! -f /etc/systemd/system/udpmod.service ] | [ ! -f "/etc/systemd/system/zivpn.service" ]; then
setupudp2
fi
if [ ! -f /etc/systemd/system/udpmod.service ] | [ ! -f "/etc/systemd/system/zivpn.service" ] | [ ! -f /etc/systemd/system/udp-custom.service ]; then
setupudp2
fi
if [ ! -f /etc/systemd/system/udp-custom.service ]; then
menu
fi
rules
}
function setupudp2(){
clear
figlet '  UDPs By JERRY-SBG' | lolcat
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
check_service() {
    local service_name=$1
    # Verificar si el servicio existe
    if systemctl list-unit-files "$service_name.service" >/dev/null 2>&1 || \
       [ -f "/etc/systemd/system/$service_name.service" ] || \
       [ -f "/lib/systemd/system/$service_name.service" ]; then
        # Verificar si está activo
        if systemctl is-active "$service_name" >/dev/null 2>&1; then
            echo "${COLOR1}ON${NC}"
        else
            # Intentar reiniciar UNA VEZ si está instalado pero apagado
            systemctl daemon-reload >/dev/null 2>&1
            systemctl restart "$service_name" >/dev/null 2>&1
            sleep 0.5           
            if systemctl is-active "$service_name" >/dev/null 2>&1; then
                echo "${COLOR1}ON${NC}"
            else
                echo "${RED}OFF${NC}"
            fi
        fi
    else
        echo "${RED}OFF${NC}"
    fi
}
status_zivpn=$(check_service zivpn)
status_hysteria=$(check_service udpmod)
status_udp=$(check_service udp-custom)
echo -e "${COLOR1}│   ${WH}STATUS ZIVPN UDP  : ${status_zivpn} \e[1;32mPuertos: 1:19999      ${NC}"
echo -e "${COLOR1}│   ${WH}STATUS HYSTERIA   : ${status_hysteria} \e[1;32mPuertos: 20000:39999  ${NC}"
echo -e "${COLOR1}│   ${WH}STATUS UDP CUSTOM : ${status_udp} \e[1;32mPuertos: 40000:65535  ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│     ${WH}[ 0 ]  ${RED}INSTALAR REGLAS UDPs         ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1} 1 ${WH}]  INSTALAR UDP CUSTOM          ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1} 2 ${WH}]  DESINSTALAR UDP CUSTOM       ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1} 3 ${WH}]  MENU ZIVPN 💥                ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1} 4 ${WH}]  MENU UDP HYSTERIA 💥         ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1} 5 ${WH}]  INSTALAR ZIVPN               ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1} 6 ${WH}]  DESINTALAR ZIVPN             ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1} 7 ${WH}]  INSTALAR UDP HYSTERIA        ${COLOR1} │${NC}" 
echo -e "${COLOR1}│     ${WH}[${COLOR1} 8 ${WH}]  DESINSTALAR UDP HYSTERIA     ${COLOR1} │${NC}"
echo -e "${COLOR1}│     ${WH}[${COLOR1}ENTER${WH}]  REGRESAR AL MENU           ${COLOR1} │${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -n 1 -s -r -p "   Por Favor Selecciona una Opcion : " udp
clear
if [[ $udp == "0" ]]; then
echo "INSTALANDO REGLAS DE PUERTOS UDPs..."
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination :5300
iptables -t nat -A PREROUTING -p udp --dport 1:19999 -j DNAT --to-destination :5667
iptables -t nat -A PREROUTING -p udp --dport 20000:39999 -j DNAT --to-destination :36712
iptables -t nat -A PREROUTING -p udp --dport 40000:65535 -j DNAT --to-destination :36715
netfilter-persistent save
netfilter-persistent reload
clear
systemctl daemon-reload &>/dev/null
echo -e "    ${yl}INSTALANDO REGLAS DE PUERTOS UDPs..."
echo -e "    ${yl}PUERTOS ZIVPN: 1:19999..."
echo -e "    ${yl}PUERTOS HYSTERIA: 20000:39999..."
echo -e "    ${yl}PUERTOS UDP-CUSTOM: 40000-65535..."
echo -e "    ${yl}Agregado Con Exito las Reglas (ZIVPN, HYSTERIA, UDP-CUSTOM.)"
sleep 1
setupudp2
fi
if [[ $udp == "1" ]]; then
#wget https://raw.githubusercontent.com/JerrySBG/SBG/main/udp/install_udp.sh && chmod +x install_udp.sh && bash install_udp.sh
#rm -rf install_udp.sh
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
wget -q https://raw.githubusercontent.com/Internetjm/personalScript/main/scripts/udp/udp-custom.sh -O udp-custom.sh 2>/dev/null
chmod +x udp-custom.sh && ./udp-custom.sh
rm -rf udp-custom.sh
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════════════════╮${NC}"
echo -e " [ ${RED}ADVERTENCIA${NC} ] PRESIONA (s) PARA PODER USAR LOS 3 UDP"
echo -e " [ ${RED}ADVERTENCIA${NC} ] PRESIONA (n) SOLO TENDRAS UDP CUSTOM 1-65535"
echo -e "${COLOR1}╰═════════════════════════════════════════════════════════════╯${NC}"
echo ""
echo -e "[ ${RED}ADVERTENCIA${NC} ] ¿QUIERES USAR LOS 3 UDP´s Al MISMO TIEMPO? (s/n)"; read answer
if [ "$answer" == "${answer#[Ss]}" ] ;then
if systemctl is-enabled udp-custom.service >/dev/null 2>&1; then
    if systemctl is-active udp-custom >/dev/null 2>&1; then
        status_udp="${WH}ON${NC}"
    else
        status_udp="${RED}OFF${NC}"
        systemctl daemon-reload >/dev/null 2>&1
        systemctl restart udp-custom >/dev/null 2>&1
    fi
else
    status_udp="${RED}OFF${NC}"
fi
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│       ${WH}SIGUE Disfrutando del UDP-CUSTOM ${NC}"
echo -e "${COLOR1}│       ${WH}STATUS UDP CUSTOM : ${status_udp} Puertos: 1:65535  ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
sleep 2
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
sudo iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination :5300
sudo iptables -t nat -A PREROUTING -p udp --dport 1:65535 -j DNAT --to-destination :36715
netfilter-persistent save
netfilter-persistent reload
clear
menu
else
echo -e "    ${yl}INSTALANDO REGLAS DE PUERTOS UDPs..."
echo -e "    ${yl}PUERTOS ZIVPN: 1:19999..."
echo -e "    ${yl}PUERTOS HYSTERIA: 20000:39999..."
echo -e "    ${yl}PUERTOS UDP-CUSTOM: 40000-65535..."
sleep 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -D PREROUTING 1
iptables -t nat -A PREROUTING -p udp --dport 53 -j DNAT --to-destination :5300
iptables -t nat -A PREROUTING -p udp --dport 1:19999 -j DNAT --to-destination :5667
iptables -t nat -A PREROUTING -p udp --dport 20000:39999 -j DNAT --to-destination :36712
iptables -t nat -A PREROUTING -p udp --dport 40000:65535 -j DNAT --to-destination :36715
netfilter-persistent save
netfilter-persistent reload
iptables -t nat -D PREROUTING 5
iptables -t nat -D PREROUTING 5
iptables -t nat -D PREROUTING 5
iptables -t nat -D PREROUTING 5
clear
systemctl daemon-reload &>/dev/null
setupudp2
fi
fi
if [[ $udp == "2" ]]; then
clear
systemctl stop udp-custom &>/dev/null
systemctl disable udp-custom &>/dev/null
systemctl daemon-reload &>/dev/null
rm -rf /etc/systemd/system/udp-custom.service
rm -rf /etc/udp
clear
echo -e "    ${RED}Desintalado Correctamente UDP CUSTOM"
sleep 1
setupudp2
fi
if [[ $udp == "3" ]]; then
setupzip
fi
if [[ $udp == "4" ]]; then
setupmod
fi
if [[ $udp == "5" ]]; then
wget -q https://raw.githubusercontent.com/Internetjm/personalScript/main/scripts/zivpn/ziv2.sh -O ziv2.sh 2>/dev/null
chmod +x ziv2.sh && ./ziv2.sh
rm -rf ziv2.sh
setupudp2
fi
if [[ $udp == "6" ]]; then
clear
wget -q https://raw.githubusercontent.com/Internetjm/personalScript/main/scripts/zivpn/uninstall.sh -O uninstall.sh 2>/dev/null
chmod +x uninstall.sh && ./uninstall.sh
rm -rf uninstall.sh
clear
echo -e "    ${RED}Desintalado Correctamente ZIVPN"
sleep 1
setupudp2
fi
if [[ $udp == "7" ]]; then
clear
if [ ! -e /root/UDPMOD ]; then
wget -q https://raw.githubusercontent.com/Internetjm/personalScript/main/scripts/UDPMOD/install.sh -O install.sh 2>/dev/null
chmod +x install.sh && ./install.sh
rm -rf install.sh
#setupudp2
setupmod
else
setupmod
fi
fi
if [[ $udp == "8" ]]; then
clear
systemctl stop udpmod &>/dev/null
systemctl disable udpmod &>/dev/null
systemctl daemon-reload &>/dev/null
rm -rf /etc/systemd/system/udpmod.service
rm -rf /root/UDPMOD
clear
echo -e "    ${RED}Desintalado Correctamente HYSTERIA"
sleep 1
setupudp2
fi
menu
}

function setupmod(){
clear
figlet 'HYSTERIA By JERRY-SBG' | lolcat
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│             ${WH}MENU UDP HYSTERIA           ${COLOR1} │${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 1 ${WH}] AGREGAR USUARIO(s)             ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 2 ${WH}] LISTA DE USUARIO(s)            ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 3 ${WH}] BORRAR USUARIO(s)              ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1}ENTER${WH}] REGRESAR AL MENU             ${COLOR1} │${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -n 1 -s -r -p "   Por Favor Selecciona una Opcion : " mod
clear
if [[ $mod == "1" ]]; then
CONFIG_FILE="/root/UDPMOD/config.json"
LOG_FILE="/root/UDPMOD/user.log"

# Prompt the user for a username and validity period in days
while true; do
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│        ${WH}MENU USUARIOS HYSTERIA            ${NC}${COLOR1}│${NC}"
#echo -e "${COLOR1}│       ${COLOR1}INGRESA: Usuario:Password          ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│        ${WH}EJEMPLO: Manco123 SIN ESPACIOS    ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -p " Ingresa Nombre de USUARIO : " username
    # Check if username contains only letters
    if [[ "$username" =~ ^[a-zA-Z0-9]+$ ]]; then
        # Check if username already exists in config.json or user.log
        if grep -q "\"$username\"" "$CONFIG_FILE" || grep -q "^$username:" "$LOG_FILE"; then
        echo ""
        echo -e " ${RED}ERROR: ${yl}Usuario '$username' Ya EXISTE. Por Favor, Ingresa Otro."
        echo ""
        sleep 2
        else
            break  # Username is valid and doesn't exist, so exit the loop
        fi
    else
        echo ""
        echo -e " ${RED}ERROR: ${yl}El Nombre de USUARIO debe Contener solo letras."
        echo ""
        sleep 2
    fi
done

while true; do
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│            ${WH}INGRESA UNA CONTRASEÑA        ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│              ${WH}USUARIOS HYSTERIA           ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -p " Ingresa Contraseña del USUARIO: " pw
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│          ${WH}FECHA DE VENCIMIENTO PARA       ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│              ${WH}USUARIOS HYSTERIA           ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -p " Ingrese DIAS de Expiracion : " days_valid
    # Check if days_valid contains only numbers
    if [[ "$days_valid" =~ ^[0-9]+$ ]]; then
        break
    else
        echo ""
        echo -e " ${RED}ERROR: ${yl} El Periodo de Validez debe ser un NUMERO."
        echo ""
        sleep 2
    fi
done

# Calculate the expiration date
expiry_date=$(date -d "+$days_valid days" +"%d/%m/%Y")

# Use sed to insert the username before the closing bracket of the config array
sed -i "/\"config\": \[/ s/\]/,\"$username:$pw\"\]/" "$CONFIG_FILE"
sudo systemctl daemon-reload &>/dev/null
sudo systemctl restart udpmod &>/dev/null

# Check if the update was successful
if [ $? -eq 0 ]; then
    # Log the username and expiration date in user.log
    LOG_FILE="/root/UDPMOD/user.log"
    echo "$username:$expiry_date" >> "$LOG_FILE"
    echo ""
    echo -e "${RED}INFO: ${yl} Usuario Agregado EXITOSAMENTE e Iniciado Sesion en Log."
    echo ""
    sleep 2
else
    echo ""
    echo -e " ${RED}ERROR: ${yl} No se Pudo ACTUALIZAR config.json."
    echo ""
    sleep 2
fi
clear
setupmod
fi
if [[ $mod == "2" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│         ${WH}USUARIOS HYSTERIA REGISTRADOS    ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│       ${WH}USUARIOS │ ${WH}DIAS RESTANTES          ${NC}${COLOR1}│${WH}"
today=$(date +%s)
# قراءة الملف وتحليل البيانات
while IFS=":" read -r user date; do
    #Convierte la fecha registrada al formato de marca de tiempo en formato día/mes/año
    log_date=$(date -d "$(echo "$date" | awk -F'/' '{print $2"/"$1"/"$3}')" +%s)
    
    #Calcula la diferencia en días y hazle un valor absoluto.
    days_diff=$(( (today - log_date) / 86400 ))
    days_diff=${days_diff#-} # جعل القيمة موجبة

    # Muestra el resultado con el formato de espacio entre el nombre y la diferencia.
    printf "  -->>      %-10s %d\n" "$user" "$days_diff"

done < /root/UDPMOD/user.log

echo ""
read -n 1 -s -r -p "Presione [ Enter ] para Regresar al MENU"
setupmod
fi
if [[ $mod == "3" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│         ${WH}BORRAR USUARIO/PASSWORD          ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}EJEMPLO: [ Usbg:Psbg ] SIN ESPACIOS ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
CONFIG_FILE="/root/UDPMOD/config.json"
LOG_FILE="/root/UDPMOD/user.log"

usezi=$(cat /root/UDPMOD/config.json | awk 'NR==15 {print $2}')
echo -e "${COLOR1}│  -->>  ${COLOR1}ACTIVOS:  ${WH}$usezi"
echo ""
# Prompt the user for a username to delete
while true; do
    read -p " Introduzca el USUARIO/PASSWORD que desea ELIMINAR : " username
    # Check if username contains only letters
    if [[ "$username" =~ ^[a-zA-Z0-9:]+$ ]]; then
        # Check if username exists in both config.json and user.log
        if grep -q "\"$username\"" "$CONFIG_FILE" || grep -q "^$username:" "$LOG_FILE"; then
            # Remove the username from config.json without deleting the whole line
            sed -i "s/,\"$username\"/\"$username\"/; s/^,\"$username\",// s/\"$username\"//" "$CONFIG_FILE"

            # Remove the username from user.log
            sed -i "/^$username:/d" "$LOG_FILE"

            # Restart the VPN service to apply changes
            sudo systemctl daemon-reload &>/dev/null
            sudo systemctl restart udpmod &>/dev/null

            # Check if the update was successful
            if [ $? -eq 0 ]; then
            echo ""
            echo -e "${RED}INFO: ${yl}Usuario '$username' ELIMINADO con EXITO."
            echo ""
            sleep 2
            else
            echo ""
            echo -e " ${RED}ERROR: ${yl}No se Pudo ACTUALIZAR config.json."
            echo ""
            sleep 2
            fi
            break
        else
            echo ""
            echo -e " ${RED}ERROR: ${yl}Usuario '$username' No Existe."
            echo ""
            sleep 2
        fi
    else
            echo ""
            echo -e " ${RED}ERROR: ${yl}El Nombre de USUARIO debe Contener Solo Letras."
            echo ""
    fi
done
setupmod
fi
setupudp2
}

function setupslow(){
if [ ! -f /etc/slowdns/dnstt-server ]; then
rm -rf /etc/slowdns
wget -q https://raw.githubusercontent.com/Internetjm/personalScript/main/scripts/slowdns/installsl.sh -O installsl.sh 2>/dev/null
chmod +x installsl.sh && ./installsl.sh
rm -rf installsl.sh
else
slo=$( systemctl status server | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $slo == "running" ]]; then
    status_slo="${WH}ON${NC}"
else
    status_slo="${RED}OFF${NC}"
    systemctl daemon-reload &>/dev/null
    systemctl restart server &>/dev/null
fi
clear
figlet 'SlowDNS By JERRY-SBG' | lolcat
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
#echo -e "${COLOR1}│            ${COLOR1}MENU SLOWDNS By JERRY          ${NC}"
echo -e "${COLOR1}│            ${WH}STATUS SLOWDNS : ${status_slo} ${NC}"
echo -e "${COLOR1}│     ${WH}DOMINIO SLOWDNS : ${WH}$(cat /etc/xray/dns) ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 1 ${WH}] VER KEY SLOWDNS                ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 2 ${WH}] GENERAR NUEVA KEY SLOWDNS      ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 3 ${WH}] DESINSTALAR SLOWDNS            ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1}ENTER${WH}] REGRESAR AL MENU             ${COLOR1} │${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -n 1 -s -r -p "   Por Favor Selecciona una Opcion : " slow
clear
if [[ $slow == "1" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│             ${WH}KEY PARA USAR SLOWDNS        ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│      ${WH}KEY SLOWNDS :"
echo -e "${COLOR1}│  ${WH}$(cat /etc/slowdns/server.pub)"
echo ""
read -n 1 -s -r -p "   Presione [ Enter ] para Regresar al MENU"
setupslow
fi
if [[ $slow == "2" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│           ${WH}GENERAR NUEVA KEY SLOWNDS      ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│        ${WH}GENERANDO NUEVA KEY... ESPERA     ${NC}${COLOR1}│${NC}"
cd /etc/slowdns
rm -rf server.pub &> /dev/null
rm -rf server.key &> /dev/null
rm -rf /etc/systemd/system/server.service &> /dev/null
nameserver=$(cat /etc/xray/dns)
cat > /etc/systemd/system/server.service << END
[Unit]
Description=Server SlowDNS By @Jerry_SBG
Documentation=https://hidessh.com
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/etc/slowdns/dnstt-server -udp :5300 -privkey-file /etc/slowdns/server.key $nameserver 127.0.0.1:110
Restart=on-failure

[Install]
WantedBy=multi-user.target
END
chmod +x /etc/systemd/system/server.service
pkill dnstt-server
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub &> /dev/null
sleep 2
chmod 600 /etc/slowdns/server.pub
chmod 600 /etc/slowdns/server.key
echo -e "${COLOR1}│     ${WH}NUEVA KEY SLOWNDS CREADA CON EXITO"
echo -e "${COLOR1}│ ${WH}KEY: $(cat /etc/slowdns/server.pub)"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo " "
read -n 1 -s -r -p "   Presione [ Enter ] para Regresar al MENU"
systemctl daemon-reload &>/dev/null
systemctl restart server &>/dev/null
clear
setupslow
fi
if [[ $slow == "3" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│         ${WH}DESINTALAR PROTOCOLO SLOWDNS     ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${WH}"
clear
systemctl stop client &>/dev/null
systemctl stop server &>/dev/null
systemctl disable client &>/dev/null
systemctl disable server &>/dev/null
systemctl daemon-reload &>/dev/null
rm -rf /etc/systemd/system/client.service
rm -rf /etc/systemd/system/server.service
rm -rf /etc/slowdns
clear
sleep 1
echo -e "    ${RED}Desintalado Correctamente SLOWDNS"
setupslow
fi
menu
fi
menu
}

function setupzip(){
clear
figlet 'ZiVPN By JERRY-SBG' | lolcat
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│              ${WH}MENU UDP ZIVPN             ${COLOR1} │${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 1 ${WH}] AGREGAR USUARIO(s)             ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 2 ${WH}] LISTA DE USUARIO(s)            ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1} 3 ${WH}] BORRAR USUARIO(s)              ${COLOR1} │${NC}"
echo -e "${COLOR1}│    ${WH}[${COLOR1}ENTER${WH}] REGRESAR AL MENU             ${COLOR1} │${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -n 1 -s -r -p "   Por Favor Selecciona una Opcion : " zip
clear
if [[ $zip == "1" ]]; then
CONFIG_FILE="/etc/zivpn/config.json"
LOG_FILE="/etc/zivpn/user.log"

# Prompt the user for a username and validity period in days
while true; do
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│       ${WH}AGREGAR USUARIOS ZIVPN             ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│       ${WH}EJEMPLO: Manco123 SIN ESPACIOS     ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -p " Ingresa Nombre de USUARIO: " username
    # Check if username contains only letters
    if [[ "$username" =~ ^[a-zA-Z0-9]+$ ]]; then
        # Check if username already exists in config.json or user.log
        if grep -q "\"$username\"" "$CONFIG_FILE" || grep -q "^$username:" "$LOG_FILE"; then
        echo ""
        echo -e " ${RED}ERROR: ${yl}Usuario '$username' Ya EXISTE. Por Favor, Ingresa Otro."
        echo ""
        sleep 2
        else
            break  # Username is valid and doesn't exist, so exit the loop
        fi
    else
        echo ""
        echo -e " ${RED}ERROR: ${yl}El Nombre de USUARIO debe Contener solo letras."
        echo ""
        sleep 2
    fi
done

while true; do
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│            ${WH}INGRESA UNA CONTRASEÑA        ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│               ${WH}USUARIOS ZIVPN             ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -p " Ingresa Contraseña del USUARIO: " pw
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│          ${WH}FECHA DE VENCIMIENTO PARA       ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│               ${WH}USUARIOS ZIVPN             ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
echo ""
read -p " Ingrese DIAS de Expiracion : " days_valid
    # Check if days_valid contains only numbers
    if [[ "$days_valid" =~ ^[0-9]+$ ]]; then
        break
    else
        echo ""
        echo -e " ${RED}ERROR: ${yl} El Periodo de Validez debe ser un NUMERO."
        echo ""
        sleep 2
    fi
done

# Calculate the expiration date
expiry_date=$(date -d "+$days_valid days" +"%d/%m/%Y")

# Use sed to insert the username before the closing bracket of the config array
sed -i "/\"config\": \[/ s/\]/,\"$username:$pw\"\]/" "$CONFIG_FILE"
sudo systemctl restart zivpn &>/dev/null

# Check if the update was successful
if [ $? -eq 0 ]; then
    # Log the username and expiration date in user.log
    LOG_FILE="/etc/zivpn/user.log"
    echo "$username:$expiry_date" >> "$LOG_FILE"
    echo ""
    echo -e "${RED}INFO: ${yl} Usuario Agregado EXITOSAMENTE e Iniciado Sesion en Log."
    echo ""
    sleep 2
else
    echo ""
    echo -e " ${RED}ERROR: ${yl} No se Pudo ACTUALIZAR config.json."
    echo ""
    sleep 2
fi
clear
setupzip
fi
if [[ $zip == "2" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│          ${WH}USUARIOS ZIVPN REGISTRADOS      ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│       ${WH}USUARIOS │ ${WH}DIAS RESTANTES          ${NC}${COLOR1}│${WH}"
today=$(date +%s)
# قراءة الملف وتحليل البيانات
while IFS=":" read -r user date; do
    #Convierte la fecha registrada al formato de marca de tiempo en formato día/mes/año
    log_date=$(date -d "$(echo "$date" | awk -F'/' '{print $2"/"$1"/"$3}')" +%s)
    
    #Calcula la diferencia en días y hazle un valor absoluto.
    days_diff=$(( (today - log_date) / 86400 ))
    days_diff=${days_diff#-} # جعل القيمة موجبة

    # Muestra el resultado con el formato de espacio entre el nombre y la diferencia.
    printf "  -->>      %-10s %d\n" "$user" "$days_diff"

done < /etc/zivpn/user.log

echo ""
read -n 1 -s -r -p "Presione [ Enter ] para Regresar al MENU"
setupzip
fi
if [[ $zip == "3" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│         ${WH}BORRAR USUARIO/PASSWORD          ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}EJEMPLO: [ Usbg:Psbg ] SIN ESPACIOS ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}│      ${WH}PARA SALIR O CANCELAR( CTRL + C )   ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${WH}"
CONFIG_FILE="/etc/zivpn/config.json"
LOG_FILE="/etc/zivpn/user.log"

usezi=$(cat /etc/zivpn/config.json | awk 'NR==8 {print $2}')
echo -e "${COLOR1}│  -->>  ${COLOR1}ACTIVOS:  ${WH}$usezi"
echo ""
# Prompt the user for a username to delete
while true; do
    read -p " Introduzca el USUARIO que desea ELIMINAR : " username
    # Check if username contains only letters
    if [[ "$username" =~ ^[a-zA-Z0-9:]+$ ]]; then
        # Check if username exists in both config.json and user.log
        if grep -q "\"$username\"" "$CONFIG_FILE" || grep -q "^$username:" "$LOG_FILE"; then
            # Remove the username from config.json without deleting the whole line
            sed -i "s/,\"$username\"/\"$username\"/; s/^,\"$username\",//; s/\"$username\"//" "$CONFIG_FILE"

            # Remove the username from user.log
            sed -i "/^$username:/d" "$LOG_FILE"

            # Restart the VPN service to apply changes
            sudo systemctl restart zivpn &>/dev/null

            # Check if the update was successful
            if [ $? -eq 0 ]; then
            echo ""
            echo -e "${RED}INFO: ${yl}Usuario '$username' ELIMINADO con EXITO."
            echo ""
            sleep 2
            else
            echo ""
            echo -e " ${RED}ERROR: ${yl}No se Pudo ACTUALIZAR config.json."
            echo ""
            sleep 2
            fi
            break
        else
            echo ""
            echo -e " ${RED}ERROR: ${yl}Usuario '$username' No Existe."
            echo ""
            sleep 2
        fi
    else
            echo ""
            echo -e " ${RED}ERROR: ${yl}El Nombre de USUARIO debe Contener Solo Letras."
            echo ""
    fi
done
setupzip
fi
setupudp
}

function new(){
rm -f /etc/cron.d/reboot_otomatis
rm -f /etc/cron.d/autocpu
echo "Auto-Reinicio Apagado."
sleep 1
menu
}

function dess(){
echo -e "${COLOR1}╭═════════════════════════════════════════════════════════════╮${NC}"
echo -e " [ ${RED}ADVERTENCIA${NC} ] PRESTA ATENCION A LAS CONFIRMACIONES..."
echo -e " [ ${RED}ADVERTENCIA${NC} ] PRESIONA (y) PARA CONFIRMAR DESINSTALACION."
echo -e "${COLOR1}╰═════════════════════════════════════════════════════════════╯${NC}"
echo -e " "
echo -e "[ ${yl}ADVERTENCIA${NC} ] ¿Quieres DESINTALAR AUTOSCRIPT Ahora? ? (s/n)? "; read answer
if [ "$answer" == "${answer#[Ss]}" ] ;then
echo -e "    ${yl}Sigue Disfrutando de los Poderes"
sleep 1
menu
else
clear
pkill xray
pkill haproxy
pkill ws
pkill nginx
pkill udp-custom
pkill dropbear
pkill kyt
pkill webfsd
pkill apache2
pkill zivpn
pkill udp-custom
pkill udpmod
clear
systemctl disable apache2 &>/dev/null
systemctl disable xray &>/dev/null
systemctl disable haproxy &>/dev/null
systemctl disable ws &>/dev/null
systemctl disable nginx &>/dev/null
systemctl disable udp-custom &>/dev/null
systemctl disable zivpn &>/dev/null
systemctl disable udpmod &>/dev/null
systemctl disable dropbear &>/dev/null
systemctl disable kyt &>/dev/null
clear
rm -rf /root/log-install.txt
rm -rf /usr/local/sbin
rm -rf /usr/local/bin/autocpu
rm -rf /usr/local/bin/cleaner
rm -rf /usr/local/bin/ws
rm -rf /usr/local/bin/ssl_renew.sh
rm -rf /usr/local/bin/xray
rm -rf /etc/issue.net
rm -rf /etc/user.txt
echo "syslog" > /etc/user.txt
echo "ubuntu" >> /etc/user.txt
rm -rf /etc/systemd/system/limitshadowsocks.service
rm -rf /etc/systemd/system/limitvmess.service
rm -rf /etc/systemd/system/limitvless.service
rm -rf /etc/systemd/system/limittrojan.service
rm -rf /etc/systemd/system/udp-custom.service
rm -rf /etc/systemd/system/wondershaper.service
rm -rf /etc/systemd/system/ws.service
rm -rf /etc/systemd/system/xray.service
rm -rf /etc/systemd/system/badvpn3.service
rm -rf /etc/systemd/system/badvpn2.service
rm -rf /etc/systemd/system/badvpn1.service
rm -rf /etc/systemd/system/xray@.service.d
clear
rm -rf /etc/apache2
rm -rf /etc/trojan
rm -rf /etc/perlogin
rm -rf /etc/per
rm -rf /etc/limit
rm -rf /etc/crond.d/xraylimit
rm -rf /etc/crond.d/xp_otm
rm -rf /etc/crond.d/tendang
rm -rf /etc/crond.d/cleaner
rm -rf /etc/crond.d/bckp_otm
rm -rf /etc/crond.d/autocpu
rm -rf /etc/xray
rm -rf /etc/cron.d/limitvmess
rm -rf /etc/cron.d/limitvless
rm -rf /etc/cron.d/limittrojan
rm -rf /etc/cron.d/limitshadowsocks
rm -rf /etc/cron.d/xraylimit
rm -rf /etc/cron.d/xp_otm
rm -rf /etc/cron.d/tendang
rm -rf /etc/cron.d/cleaner
rm -rf /etc/cron.d/bckp_otm
rm -rf /etc/cron.d/autocpu
#rm -rf /etc/stunnel
rm -rf /etc/udp
rm -rf /etc/slowdns
rm -rf /usr/bin/kyt
rm -rf /etc/vmess
rm -rf /etc/vless
rm -rf /etc/haproxy
rm -rf /etc/nginx
rm -rf /root/.profile
rm -rf /etc/tele
rm -rf /etc/notiftele
rm -rf /etc/profil
rm -rf /etc/hostname
rm -rf /etc/*iptables
rm -rf /etc/*openvpn
rm -rf /etc/zivpn
rm -rf /root/UDPMODs
rm -rf /root/renew_ssl.log
rm -rf /var/www/html/*html
rm -rf /var/www/html/*txt
rm -rf /var/www/html/*APP
rm -rf /var/www/html/*SBG
rm -rf /var/www/html/*CheckUser
rm -rf /tmp/vl
rm -rf /tmp/vm
rm -rf /tmp/tr
rm -rf /tmp/expirelist.txt
rm -rf /tmp/tmp.*
clear
apt remove webfs -y
apt remove python3 -y
apt remove xray -y
apt remove dropbear -y
apt remove haproxy -y
apt remove nginx -y
apt remove apache2 -y
apt remove python3-pip -y
apt remove nodejs -y
#apt remove stunnel4 -y
sudo apt install --reinstall ca-certificates
sudo update-ca-certificates -f
mkdir /usr/local/sbin
iinfo
clear
echo ""
echo -e "    ${yl}Auto-Script Desintalado Correctamente BYE BYE"
echo ""
echo -e "    ${yl}VPS SERA REINICIADA EN UNOS SEGUNDOS"
sleep 1
reboot
exit 0
fi
}

function newx(){
clear
until [[ $usagee =~ ^[0-9]+$ ]]; do
read -p "Formato de Cuota de Usuario número 1, 2 o 3 (TERA): " usagee
done
echo "$usagee" > /etc/usagee
cat> /etc/cron.d/bantwidth << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/10 * * * * root /usr/local/sbin/bantwidth
END
echo "Auto-Shutdown $usagee TERA TURN ON."
sleep 1
menu
}
domain=$(cat /etc/xray/domain)
function restartservice(){    
clear
fun_bar() {
    CMD[0]="$1"
    CMD[1]="$2"
    (
        [[ -e $HOME/fim ]] && rm $HOME/fim
        ${CMD[0]} -y &>/dev/null
        ${CMD[1]} -y &>/dev/null
        touch $HOME/fim
    ) &>/dev/null &
    tput civis
    echo -ne "  \033[0;33mPor Favor Espere, Cargando \033[1;37m- \033[0;33m["
    while true; do
        for ((i = 0; i < 18; i++)); do
            echo -ne "\033[0;32m#"
            sleep 0.1s
        done
        [[ -e $HOME/fim ]] && rm $HOME/fim && break
        echo -e "\033[0;33m]"
        sleep 1
        tput cuu1
        tput dl1
        echo -ne "  \033[0;33mPor Favor Espere, Cargando \033[1;37m- \033[0;33m["
    done
    echo -e "\033[0;33m]\033[1;37m -\033[1;32m OK !\033[1;37m"
    tput cnorm
}
clear
echo -e "${COLOR1} ╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1} ${NC} ${COLBG1}        ${WH}  REINICIANDO SERVICIOS VPS       ${NC} ${COLOR1} $NC"
echo -e "${COLOR1} ╰══════════════════════════════════════════╯${NC}"
echo -e ""
echo -e "  \033[1;91m Reiniciando Todos los Servicios... \033[1;37m"
#fun_bar 'res1'
    systemctl daemon-reload &>/dev/null
    systemctl restart nginx &>/dev/null
    systemctl restart haproxy &>/dev/null
    systemctl restart trojan-go &>/dev/null
    systemctl restart xray &>/dev/null
    /etc/init.d/stunnel4 restart &>/dev/null
    #systemctl restart noobzvpns
    systemctl restart udp-custom &>/dev/null
    systemctl restart udpmod &>/dev/null
    systemctl restart zivpn &>/dev/null
    systemctl restart ws &>/dev/null
    systemctl restart openvpn &>/dev/null
    systemctl restart cron &>/dev/null
    systemctl restart netfilter-persistent &>/dev/null
    systemctl restart squid &>/dev/null
    systemctl restart badvpn1 &>/dev/null
    systemctl restart badvpn2 &>/dev/null
    systemctl restart badvpn3 &>/dev/null
echo -e ""
read -n 1 -s -r -p "Presione [ Enter ] para Regresar al MENU"
menu
}
function updatews(){
echo -e "  ${yl}Actualizacion no disponible en version local."
sleep 2
menu
}
function newdom(){
dom=$(head /etc/xray/domain)
echo "$dom" > /etc/xray/domain2
dom2=$(head /etc/xray/domain2)
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│          ${WH}CAMBIO DE DOMINIO               ${COLOR1}│${NC}"
echo -e  "${COLOR1}│           ${WH}By JERRY SBG                   ${COLOR1}│${NC}"
echo -e  "${COLOR1}│           ${WH}CTRL + C = SALIR               ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dnss =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio/IP Aquí : " -e dnss
done
rm -rf /etc/xray/domain
rm -rf /var/lib/ipvps.conf
echo "$dnss" > /etc/xray/domain
echo "IP=$dnss" > /var/lib/ipvps.conf
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "\033[41;37m [ INFORMACIÓN IMPORTANTE ] ${NC}"
echo -e " ${COLOR1}SI SALE ERROR DE CERTIFICADO O LETRAS ROJAS "
echo -e " ${COLOR1}DEBES DE CREAR NUEVO DOMINIO O SUBDOMINIO "
echo -e " ${COLOR1}YA QUE HAZ CERTIFICADO VARIAS VECES EL MISMO DOMINIO"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e ""
echo Iniciando...
sleep 2
source /var/lib/ipvps.conf
domain=$(head /etc/xray/domain)
STOPWEBSERVER=$(lsof -i:89 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
rm -rf /root/.acme.sh
mkdir /root/.acme.sh
systemctl stop $STOPWEBSERVER &>/dev/null
systemctl stop nginx &>/dev/null
#curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
curl https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
#/root/.acme.sh/acme.sh --register-account -m rmbl@slowapp.cfd
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
#chmod 777 /etc/xray/xray.key
cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/sbg.pem

ip=$(wget -qO- ipinfo.io/ip)
if [[ $dnss == $ip ]]; then
#echo "$dns" > /etc/xray/domain
rm -rf /etc/xray/xray.crt
rm -rf /etc/haproxy/*.pem
cat /root/sbg.pem > /etc/xray/xray.crt
cat /etc/xray/xray.crt /etc/xray/xray.key > /etc/haproxy/sbg.pem
domain=$(wget -qO- ipinfo.io/ip)
echo "$domain" > /etc/xray/domain
echo "IP=$domain" > /var/lib/ipvps.conf
echo -e " ${COLOR1}IP AGREGADA CORRECTAMENTE"
else
echo -e " ${COLOR1} AGREGADO DOMINIO PERSONALIZADO"
fi
sed -i "s/${dom2}/${domain}/g" /etc/nginx/conf.d/xray.conf
#sed -i "s/ServerAdmin/#ServerAdmin/g" /etc/apache2/sites-available/default-ssl.conf
#sed -i '/#ServerAdmin/a ServerName flo.jerrysbg.top' /etc/apache2/sites-available/default-ssl.conf
# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi
rm -rf /etc/xray/domain2
systemctl daemon-reload &>/dev/null
systemctl restart nginx &>/dev/null
systemctl restart xray &>/dev/null
systemctl restart haproxy &>/dev/null
#systemctl restart apache2
#clear
echo -e " ${COLOR1} CERTIFICADO APLICADO "
sleep 1
menu
}
serverV=""
localV=$(cat /opt/.ver 2>/dev/null | tr -d '[:space:]')
echo -e "${COLOR1}╭═══════════════════════════════════════════════════════════╮${NC}"
if [[ "$localV" == "$serverV" ]] || [[ -z "$serverV" ]]; then
    echo -e "${COLOR1}│$NC ${WH}❈ ᴠᴇʀꜱɪᴏɴ  ${NC}: ${WH}${localV} [ᴄᴏɴᴛʀᴏʟᴀᴅᴀ x ᴀᴅᴍ]${NC}"
else
    echo -e "${COLOR1}│$NC ${WH}❈ ᴠᴇʀꜱɪᴏɴ  ${NC}: ${WH}${localV} ${yl}ᴀᴄᴛᴜᴀʟɪᴢᴀᴄɪᴏɴ ᴅɪꜱᴘᴏɴɪʙʟᴇ ${WH}${serverV}${NC}"
    echo -e "${COLOR1}│                    ${yl}ᴘᴏʀ ꜰᴀᴠᴏʀ, ᴇꜱᴄʀɪʙᴇ:${WH}99${NC}"
fi
echo -e "${COLOR1}│$NC ${WH} ❈ ᴄʟɪᴇɴᴛᴇ  ${NC} : \e[1;32m$(cat /etc/profil)${NC}"
echo -e "${COLOR1}│$NC ${WH} ❈ ᴠᴇɴᴅᴇᴅᴏʀ  ${NC}: \e[1;32m$(cat /usr/bin/profil2)${NC}"
echo -e "${COLOR1}│$NC ${WH} ❈ ᴛᴇʟᴇɢʀᴀᴍ ${NC} : \e[1;32m@ᴊᴇʀʀʏ_ꜱʙɢ${NC}"
echo -e "${COLOR1}│$NC ${WH} ❈ ᴋᴇʏ ᴠᴇʀɪꜰɪᴄᴀᴅᴀ ${NC}: ${yl}$(cat /usr/bin/cred) ${NC}${COLOR1}"
echo -e "${COLOR1}│$NC ${WH} ❈ ${RED}𝐀𝐕𝐈𝐒𝐎${NC}: ${purple}ᴍᴀɴᴅᴀ ᴄᴀᴘᴛᴜʀᴀ ᴀʟ ᴀᴅᴍ ᴇᴠɪᴛᴀ ᴇʟ ʙᴀɴ ${NC}${COLOR1}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -e " ${COLOR1}[14]${NC} ${WH}HCR SERVER${NC}"
echo -ne " ${WH}Selecciona Opc MENU ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; m-sshovpn ;;
02 | 2) clear ; m-vmess ;;
03 | 3) clear ; m-vless ;;
04 | 4) clear ; m-ss ;;
05 | 5) clear ; m-trojan ;;
#06 | 6) clear ; m-trgo ;;
06 | 6) clear ; m-token ;;
07 | 7) clear ; xp ;;
08 | 8) clear ; m-bot  ;;
09 | 9) clear ; m-bot2 ;;
#99 | 99) clear ; wget -q -o /dev/null http://${JS}:3215/UpdateFREE --http-user=JerrySBG --http-password=BySBG && chmod +x UpdateFREE && ./UpdateFREE ;;
10 | 10) clear ; newdom ;;
11 | 11) clear ; m-system ;;
#12 | 12) clear ; m-backup;;
12 | 12) clear ; reboot ;;
#15 | 15) clear ; key ;;
13 | 13) clear ; restartservice ;;
14 | 14) clear ; m-hcr ;;
20 | 20) clear ; setupslow ;;
#21 | 21) clear ; $ressee2 ;;
#20 | 22) clear ; $ressee3 ;;
24 | 24) clear ; running;;
25 | 25) clear ; setupslow ;;
26 | 26) clear ; setupudp ;;
89 | 89) clear ; nano /etc/issue.net ;;
#88 | 88) clear ; m-noobz ;;
#77 | 77) clear ; newx ;;
66 | 66) clear ; dess ;;
#100) clear ; $up2u ;;
00 | 0) clear ; menu ;;
*) clear ; menu ;;
esac
