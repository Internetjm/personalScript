#!/bin/bash
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
Yellow='\033[1;93m'     # Yellow
Green='\033[1;92m'      # Green
Blue='\033[1;94m'       # Blue
Purple='\033[1;95m'     # Purple
# ═════════ Helpers JM: puertos reales, OBFS y datos extra (Xray / HCR / BHTTP) ═════════
# jm_ports <proceso> <valor_si_no_hay>  -> puertos TCP reales del proceso, ej: "109, 110, 143"
jm_ports() {
    local p
    p=$(ss -H -ltnp 2>/dev/null | awk -v n="\"$1\"" 'index($0,n){print $4}' | grep -oE '[0-9]+$' | sort -n -u | paste -sd, - | sed 's/,/, /g')
    echo "${p:-$2}"
}
# OBFS de Hysteria: se lee del config real (antes se leia /usr/bin/obfs, que no existe)
jm_obfs() {
    local o="" f=/root/UDPMOD/config.json
    if [ -s "$f" ]; then
        o=$(jq -r '.obfs // empty' "$f" 2>/dev/null)
        [ -z "$o" ] && o=$(grep -oE '"obfs"[[:space:]]*:[[:space:]]*"[^"]*"' "$f" | head -n1 | sed -E 's/.*:[[:space:]]*"([^"]*)"/\1/')
    fi
    [ -z "$o" ] && [ -s /root/UDPMOD/data ] && o=$(sed 's/\x1b\[[0-9;]*m//g' /root/UDPMOD/data | awk -F': ' '/OBFS/{print $2; exit}' | tr -d '[:space:]')
    [ -z "$o" ] && [ -s /usr/bin/obfs ] && o=$(tr -d '[:space:]' < /usr/bin/obfs)
    echo "$o"
}
jm_hcr_port()   { grep -oE -- '--listen :[0-9]+' /etc/systemd/system/hcr-server.service 2>/dev/null | grep -oE '[0-9]+$' | head -n1; }
jm_bhttp_port() { ( . /etc/bhttp-panel.conf 2>/dev/null; echo "${BHTTP_PORT:-}" ); }

# Alta automatica del usuario SSH tambien en Xray (VMess, VLESS, Trojan; WS + gRPC).
# HCR y BHTTP autentican contra el mismo usuario SSH del sistema, no necesitan cuenta aparte.
jm_xray_add() {   # user exp uuid iplim
    local user=$1 exp=$2 uuid=$3 lim=${4:-0} cfg=/etc/xray/config.json q p
    [ -s "$cfg" ] && grep -q '^#vmessgrpc$' "$cfg" && grep -q '^#vlessgrpc$' "$cfg" && grep -q '^#trojangrpc$' "$cfg" || return 1
    grep -q "\"email\": \"$user\"" "$cfg" && return 0
    [ "$lim" = "0" ] && lim=9999
    q=$((9999 * 1024 * 1024 * 1024))
    for p in vmess vless trojan; do
        mkdir -p /etc/$p
        echo "$q" > /etc/$p/$user
        echo "$lim" > /etc/$p/${user}IP
    done
    sed -i '/#vmess$/a\#vm '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' "$cfg"
    sed -i '/#vmessgrpc$/a\#vmg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' "$cfg"
    sed -i '/#vless$/a\#vl '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' "$cfg"
    sed -i '/#vlessgrpc$/a\#vlg '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' "$cfg"
    sed -i '/#trojanws$/a\#tr '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' "$cfg"
    sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' "$cfg"
    systemctl is-active --quiet xray && systemctl restart xray >/dev/null 2>&1
    return 0
}
# Baja del usuario en Xray (se llama al borrar el usuario SSH)
jm_xray_del() {
    local user=$1 cfg=/etc/xray/config.json t
    [ -s "$cfg" ] || return 0
    for t in vm vmg vl vlg tr trg; do
        sed -i "/^#$t $user /,/^},{/d" "$cfg"
    done
    rm -f /etc/vmess/$user /etc/vmess/${user}IP /etc/vless/$user /etc/vless/${user}IP /etc/trojan/$user /etc/trojan/${user}IP
    systemctl is-active --quiet xray && systemctl restart xray >/dev/null 2>&1
    return 0
}

jm_sep()  { echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}"; }
jm_line() { echo -e "${COLOR1} $NC  ${WH}$1${COLOR1}: ${WH}$2"; }
jm_link() { echo -e "${COLOR1} $NC  ${WH}$1${COLOR1}: ${NC}"; echo -e "${WH}$2${NC}"; }

# Bloque final de la cuenta: SlowDNS, ZIVPN, Hysteria, UDP Custom, HCR, BHTTP y Xray
jm_account_tail() {   # user pass exp uuid
    local u=$1 p=$2 id=$4 ns key hp bp st patch cfg=/etc/xray/config.json
    ns=$(cat /etc/xray/dns 2>/dev/null); key=$(cat /etc/slowdns/server.pub 2>/dev/null)
    if [ -n "$ns" ] && [ -n "$key" ]; then
        jm_line "SlowDNS    " "$ns:53@$u:$p"
        jm_line "PORT SLWDNS" "Todos los Puertos"
        jm_line "DOMINIO DNS" "1.1.1.1 / 8.8.8.8"
        jm_line "NAMESERVER " "$ns"
        jm_line "PUB KEY    " "$key"
    else
        jm_line "SlowDNS    " "no instalado (menu 25)"
    fi
    jm_sep
    if [ -s /etc/zivpn/config.json ]; then
        jm_line "SSH UDP ZIVPN " "$domain:1-19999"
        jm_line "USUARIO & PW  " "$u:$p"
    else
        jm_line "SSH UDP ZIVPN " "no instalado (menu 26)"
    fi
    jm_sep
    if [ -s /root/UDPMOD/config.json ]; then
        jm_line "DOM UDP HYSTERIA " "$domain"
        jm_line "USUARIO & PASSW  " "$u:$p"
        jm_line "OBFS HYSTERIA " "${OBFS:-?}"
        jm_line "PORT HYSTERIA " "20000-39999"
    else
        jm_line "UDP HYSTERIA " "no instalado (menu 26)"
    fi
    jm_sep
    if [ -f /etc/systemd/system/udp-custom.service ]; then
        jm_line "UDP CUSTOM " "$domain:40000-65535@$u:$p"
    else
        jm_line "UDP CUSTOM " "no instalado (menu 26)"
    fi
    jm_sep
    if systemctl cat hcr-server.service >/dev/null 2>&1; then
        hp=$(jm_hcr_port); st=""; systemctl is-active --quiet hcr-server || st=" (INACTIVO)"
        jm_line "HCR SERVER " "$domain:${hp:-8880}@$u:$p$st"
    else
        jm_line "HCR SERVER " "no instalado (menu 14)"
    fi
    if systemctl cat bhttp.service >/dev/null 2>&1; then
        bp=$(jm_bhttp_port); st=""; systemctl is-active --quiet bhttp || st=" (INACTIVO)"
        jm_line "BHTTP      " "$domain:${bp:-8888}@$u:$p$st"
    else
        jm_line "BHTTP      " "no instalado (menu 15)"
    fi
    jm_sep
    if [ -n "$id" ] && grep -q "\"email\": \"$u\"" "$cfg" 2>/dev/null; then
        patch=$(tr -d '\r\n' < /etc/xray/patch 2>/dev/null)
        local vm_tls vm_ntls vm_grpc
        vm_tls="vmess://$(printf '{"v":"2","ps":"%s","add":"%s","port":"443","id":"%s","aid":"0","net":"ws","path":"/vm-%s","type":"none","host":"%s","tls":"tls"}' "$u" "$domain" "$id" "$patch" "$domain" | base64 -w 0)"
        vm_ntls="vmess://$(printf '{"v":"2","ps":"%s","add":"%s","port":"80","id":"%s","aid":"0","net":"ws","path":"/vm-%s","type":"none","host":"%s","tls":"none"}' "$u" "$domain" "$id" "$patch" "$domain" | base64 -w 0)"
        vm_grpc="vmess://$(printf '{"v":"2","ps":"%s","add":"%s","port":"443","id":"%s","aid":"0","net":"grpc","path":"vmgr-%s","type":"none","host":"%s","tls":"tls"}' "$u" "$domain" "$id" "$patch" "$domain" | base64 -w 0)"
        jm_line "XRAY UUID  " "$id"
        jm_line "XRAY Port  " "TLS 443 | NTLS 80"
        jm_line "WS Path    " "/vm-$patch  /vl-$patch  /tr-$patch"
        jm_line "gRPC Name  " "vmgr-$patch  vlgr-$patch  trgr-$patch"
        jm_sep
        jm_link "VMESS WS TLS " "$vm_tls"
        jm_link "VMESS WS NTLS" "$vm_ntls"
        jm_link "VMESS gRPC   " "$vm_grpc"
        jm_link "VLESS WS TLS " "vless://${id}@${domain}:443?path=/vl-${patch}&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${u}"
        jm_link "VLESS WS NTLS" "vless://${id}@${domain}:80?path=/vl-${patch}&security=none&encryption=none&host=${domain}&type=ws#${u}"
        jm_link "VLESS gRPC   " "vless://${id}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgr-${patch}&sni=${domain}#${u}"
        jm_link "TROJAN WS TLS" "trojan://${id}@${domain}:443?path=%2Ftr-${patch}&security=tls&host=${domain}&type=ws&sni=${domain}#${u}"
        jm_link "TROJAN gRPC  " "trojan://${id}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trgr-${patch}&sni=${domain}#${u}"
    else
        jm_line "XRAY/V2RAY " "no instalado (menu 17)"
    fi
}
SSHP=$(jm_ports sshd 22)
DBP=$(jm_ports dropbear "109, 143")
OBFS=$(jm_obfs)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
# REMOVED jmscript CALL: URL="https://api.telegram.org/bot$KEY/sendMessage"
domain=`cat /etc/xray/domain`
CHATID2=$(cat /etc/perlogin/id)
KEY2=$(cat /etc/perlogin/token)
# REMOVED jmscript CALL: URL2="https://api.telegram.org/bot$KEY2/sendMessage"
cd
if [ ! -e /etc/xray/sshx/akun ]; then
mkdir -p /etc/xray/sshx/akun
fi
checking_sc() {
clear
}
rm -rf /root/checkIP*
rm -rf /tmp/tmp.*

function usernew(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
sldomain=`cat /etc/xray/dns 2>/dev/null`
slkey=`cat /etc/slowdns/server.pub 2>/dev/null`
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}              ${WH}• SSH PANEL MENU •               ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
until [[ $Login =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -p "USUARIO : " Login
CLIENT_EXISTS=$(grep -w $Login /etc/xray/ssh | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}             ${WH}• SSH PANEL MENU •               ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│${WH}   Nombre duplicado Por favor cree otro nombre.  ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar"
usernew
fi
done
read -p "CONTRASEÑA (ENTER GENERAR ALETORIAMENTE): " Pass
[[ -z "$Pass" ]] && Pass=`tr -cd 'a-z0-9' < /dev/urandom | fold -w 6 | head -n 1`
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p "Expiracion (DIAS): " masaaktif
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limite Usuarios (IP): " iplim
done
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
if [ -z ${iplim} ]; then
iplim="0"
fi
echo "${iplim}" >/etc/xray/sshx/${Login}IP
IP=$(curl -sS ipinfo.io/ip);
if [[ -e /etc/cloudfront ]]; then
cloudfront=$(cat /etc/cloudfront)
else
cloudfront="-"
fi
sleep 1
clear
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "### $Login $expi $Pass" >> /etc/xray/ssh
JM_UUID=$(cat /proc/sys/kernel/random/uuid)
jm_xray_add "$Login" "$expi" "$JM_UUID" "$iplim" || JM_UUID=""
#CLIENT_EXISTS=$(grep -w $User /var/www/html/CheckUser | wc -l)
#if [[ ${CLIENT_EXISTS} == '1' ]]; then
#sed -i "/^$Login/d" /var/www/html/CheckUser
echo -e "$Login:$expi" >> /var/www/html/CheckUser
#else
#echo -e "$Login:$expi" >> /var/www/html/CheckUser
#fi
####################################################################################
if [[ -e /root/UDPMOD/config.json ]]; then
CONFIG_FILE="/root/UDPMOD/config.json"
sed -i "/\"config\": \[/ s/\]/,\"$Login:$Pass\"\]/" "$CONFIG_FILE" >/dev/null
sudo systemctl daemon-reload
sudo systemctl restart udpmod
fi
if [[ -e /etc/zivpn/config.json ]]; then
CONFIG_FILE="/etc/zivpn/config.json"
sed -i "/\"config\": \[/ s/\]/,\"$Login:$Pass\"\]/" "$CONFIG_FILE" >/dev/null
sudo systemctl daemon-reload
sudo systemctl restart zivpn
fi
#####################################################################################
#cat > /home/vps/public_html/ssh-$Login.txt <<-END
cat > /var/www/html/APP/ssh-$Login.txt <<-END
_______________________________
Format SSH OVPN Account
_______________________________
Usuario         : $Login
Creado El       : $(date "+%D %I:%M%p")
Vencimiento     : $expi
_______________________________
END
cat > /var/www/html/ssh-$Login.txt <<-END
━━━━━━━━━━━━━━━━━━
  SSH Premium Account
━━━━━━━━━━━━━━━━━━
Usuario         :  $Login
Contraseña      :  $Pass
Expira El       :  $expi
━━━━━━━━━━━━━━━━━━
CITY             :  $CITY
Host             :  $domain
Login Limit      :  ${iplim} IP
Port OpenSSH     :  $SSHP
Port Dropbear    :  $DBP
Port SSH WS      :  80,8080,8088,8280,8880,2052,2082,2086,2095
Port SSH SSL WS  :  443
Port SSL/TLS     :  443
Port OVPN SSL    :  443
Port OVPN TCP    :  1194
Port OVPN UDP    :  2200
Proxy Squid      :  3128
BadVPN UDP       :  7100, 7300, 7300
━━━━━━━━━━━━━━━━━━
SSH UDP ZIVPN    : $domain:1-19999
USUARIO/PW       : $Login:$Pass
━━━━━━━━━━━━━━━━━━
DOM UDP HYSTERIA : $domain
USUARIO/PASSW  : $Login:$Pass
OBFS HYSTERIA    : $OBFS
PORT HYSTERIA    : 20000-39999
━━━━━━━━━━━━━━━━━━
SSH UDP CUSTOM   : $domain:40000-65535@$Login:$Pass
━━━━━━━━━━━━━━━━━━
SSH WS : $domain:80@$Login:$Pass
SSH SSL : $domain:443@$Login:$Pass
SSH SlowDNS : $sldomain:53@$Login:$Pass
━━━━━━━━━━━━━━━━━━
Host Slowdns     :  $sldomain
Port Slowdns     :  Todos los Puertos
Domain DNS      :  1.1.1.1 / 8.8.8.8
Pub Key          :   $slkey
━━━━━━━━━━━━━━━━━━
Payload WS/WSS   :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]
━━━━━━━━━━━━━━━━━━
OpenVPN SSL      :  https://$domain:8888/ssl-1196.ovpn
OpenVPN DIRECTO  :  https://$domain:8888/direct-1194.ovpn
OpenVPN PAYLOAD  :  https://$domain:8888/payload-1195.ovpn
━━━━━━━━━━━━━━━━━━
Link Cuenta : https://$domain:8888/ssh-$Login.txt
━━━━━━━━━━━━━━━━━━
        $author
━━━━━━━━━━━━━━━━━━
END
TEXT="
━━━━━━━━━━━━━━━━━━
  SSH Premium Account
━━━━━━━━━━━━━━━━━━
Usuario         :  $Login
Contraseña      :  $Pass
Expira El       :  $expi
━━━━━━━━━━━━━━━━━━
CITY             :  $CITY
Host             :  $domain
Login Limit      :  ${iplim} IP
Port OpenSSH     :  $SSHP
Port Dropbear    :  $DBP
Port SSH WS      :  80,8080,8088,8280,8880,2052,2082,2086,2095
Port SSH SSL WS  :  443
Port SSL/TLS     :  443
Port OVPN SSL    :  443
Port OVPN TCP    :  1194
Port OVPN UDP    :  2200
Proxy Squid      :  3128
BadVPN UDP       :  7100, 7300, 7300
━━━━━━━━━━━━━━━━━━
SSH UDP ZIVPN    : $domain:1-19999
USUARIO/PW       : $Login:$Pass
━━━━━━━━━━━━━━━━━━
DOM UDP HYSTERIA : $domain
USUARIO/PASSW  : $Login:$Pass
OBFS HYSTERIA    : $OBFS
PORT HYSTERIA    : 20000-39999
━━━━━━━━━━━━━━━━━━
SSH UDP CUSTOM   : $domain:40000-65535@$Login:$Pass
━━━━━━━━━━━━━━━━━━
SSH WS : $domain:80@$Login:$Pass
SSH SSL : $domain:443@$Login:$Pass
SSH SlowDNS : $sldomain:53@$Login:$Pass
━━━━━━━━━━━━━━━━━━
Host Slowdns     :  $sldomain
Port Slowdns     :  Todos los Puertos
Domain DNS      :  1.1.1.1 / 8.8.8.8
Pub Key          :   $slkey
━━━━━━━━━━━━━━━━━━
Payload WS/WSS   :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]
━━━━━━━━━━━━━━━━━━
OpenVPN SSL      :  https://$domain:8888/ssl-1196.ovpn
OpenVPN DIRECTO  :  https://$domain:8888/direct-1194.ovpn
OpenVPN PAYLOAD  :  https://$domain:8888/payload-1195.ovpn
━━━━━━━━━━━━━━━━━━
Link Cuenta : https://$domain:8888/ssh-$Login.txt
━━━━━━━━━━━━━━━━━━
        $author
━━━━━━━━━━━━━━━━━━
"
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT2}" > /dev/null
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   CUENTA SSH CON EXITO </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMAIN  :</b> <code>${domain} </code>
<b>CITY    :</b> <code>$CITY </code>
<b>DATE    :</b> <code>${TIME2} HORA </code>
<b>DETAIL  :</b> <code>SSH </code>
<b>USER    :</b> <code>$Login</code>
<b>IP      :</b> <code>${iplim} IP </code>
<b>FECHA EXP :</b> <code>$exp </code>
<b>DURACION :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>NOTIFICACION CUENTA SSH..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC} ${WH}• SSH Premium Account  • " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Usuario    ${COLOR1}: ${WH}$Login"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Contraseña ${COLOR1}: ${WH}$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Expira En  ${COLOR1}: ${WH}$expi"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
#echo -e "${COLOR1} $NC  ${WH}ISP        ${COLOR1}: ${WH}$ISP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}City       ${COLOR1}: ${WH}$CITY" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Host       ${COLOR1}: ${WH}$domain" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Login Limit${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OpenSSH    ${COLOR1}: ${WH}$SSHP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Dropbear   ${COLOR1}: ${WH}$DBP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH-WS     ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH-SSL-WS ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSL/TLS    ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port TCP   ${COLOR1}: ${WH}1194" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port UDP   ${COLOR1}: ${WH}1-65535" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port SSL   ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OVPN TCP   ${COLOR1}: ${WH}https://$domain:8888/tcp.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OVPN UDP   ${COLOR1}: ${WH}https://$domain:8888/udp.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OVPN SSL   ${COLOR1}: ${WH}https://$domain:8888/ssl.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}UDPGW      ${COLOR1}: ${WH}7100-7300" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
jm_account_tail "$Login" "$Pass" "$expi" "$JM_UUID" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log >(sed -E 's/\x1b\[[0-9;]*m//g' >> /var/www/html/ssh-$Login.txt)
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH WS     ${COLOR1}: ${WH}$domain:80@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH SSL    ${COLOR1}: ${WH}$domain:443@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}Payload WS/WSS${COLOR1}: ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1}${NC}${WH} GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}Save Link Acount    : " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}https://$domain:8888/ssh-$Login.txt${NC}${COLOR1} $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}    ${WH}• $author •${NC}                 ${COLOR1} $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo "" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
read -n 1 -s -r -p "PRESIONE CUALQUIER TECLA PARA REGRESAR AL MENU"
m-sshovpn
}

function trial(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
sldomain=`cat /etc/xray/dns 2>/dev/null`
slkey=`cat /etc/slowdns/server.pub 2>/dev/null`
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}               ${WH}• TRIAL SSH Account •           ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
read -p "Expiracion (Hora [1-23]): " timer
Login=jmscript-`</dev/urandom tr -dc X-Z0-9 | head -c5`
Pass=By$author
iplim=2
masaaktif=1
echo "${iplim}" >/etc/xray/sshx/${Login}IP
IP=$(curl -sS ipinfo.io/ip);
if [[ -e /etc/cloudfront ]]; then
cloudfront=$(cat /etc/cloudfront)
else
cloudfront="-"
fi
sleep 1
clear
expi=`date -d "$masaaktif days" +"%Y-%m-%d"`
useradd -e `date -d "$masaaktif days" +"%Y-%m-%d"` -s /bin/false -M $Login
exp="$(chage -l $Login | grep "Account expires" | awk -F": " '{print $2}')"
echo -e "$Pass\n$Pass\n"|passwd $Login &> /dev/null
echo -e "### $Login $expi $Pass" >> /etc/xray/ssh
JM_UUID=$(cat /proc/sys/kernel/random/uuid)
jm_xray_add "$Login" "$expi" "$JM_UUID" "$iplim" || JM_UUID=""
#CLIENT_EXISTS=$(grep -w $User /var/www/html/CheckUser | wc -l)
#if [[ ${CLIENT_EXISTS} == '1' ]]; then
#sed -i "/^$User/d" /var/www/html/CheckUser
echo -e "$Login:$expi" >> /var/www/html/CheckUser
#else
#echo -e "$Login:$expi" >> /var/www/html/CheckUser
#fi
####################################################################################
if [[ -e /root/UDPMOD/config.json ]]; then
CONFIG_FILE="/root/UDPMOD/config.json"
sed -i "/\"config\": \[/ s/\]/,\"$Login:$Pass\"\]/" "$CONFIG_FILE" >/dev/null
sudo systemctl daemon-reload
sudo systemctl restart udpmod
fi
if [[ -e /etc/zivpn/config.json ]]; then
CONFIG_FILE="/etc/zivpn/config.json"
sed -i "/\"config\": \[/ s/\]/,\"$Login:$Pass\"\]/" "$CONFIG_FILE" >/dev/null
sudo systemctl daemon-reload
sudo systemctl restart zivpn
fi
#####################################################################################

cat > /var/www/html/ssh-$Login.txt <<-END
━━━━━━━━━━━━━━━━━━
  Trial SSH Premium Account
━━━━━━━━━━━━━━━━━━
Usuario         :  $Login
Contraseña      :  $Pass
Expira En       :  $timer Minuto(s)
━━━━━━━━━━━━━━━━━━
CITY             :  $CITY
Host             :  $domain
Login Limit      :  ${iplim} IP
Port OpenSSH     :  $SSHP
Port Dropbear    :  $DBP
Port SSH WS      :  80,8080,8088,8280,8880,2052,2082,2086,2095
Port SSH SSL WS  :  443
Port SSL/TLS     :  443
Port OVPN SSL    :  443
Port OVPN TCP    :  1194
Port OVPN UDP    :  2200
Proxy Squid      :  3128
BadVPN UDP       :  7100, 7300, 7300
━━━━━━━━━━━━━━━━━━
SSH UDP ZIVPN    : $domain:1-19999
USUARIO/PW       : $Login:$Pass
━━━━━━━━━━━━━━━━━━
DOM UDP HYSTERIA : $domain
USUARIO/PASSW  : $Login:$Pass
OBFS HYSTERIA    : $OBFS
PORT HYSTERIA    : 20000-39999
━━━━━━━━━━━━━━━━━━
SSH UDP CUSTOM   : $domain:40000-65535@$Login:$Pass
━━━━━━━━━━━━━━━━━━
SSH WS : $domain:80@$Login:$Pass
SSH SSL : $domain:443@$Login:$Pass
SSH SlowDNS : $sldomain:53@$Login:$Pass
━━━━━━━━━━━━━━━━━━
Host Slowdns     :  $sldomain
Port Slowdns     :  Todos los Puertos
Domain DNS      :  1.1.1.1 / 8.8.8.8
Pub Key          :   $slkey
━━━━━━━━━━━━━━━━━━
Payload WS/WSS   :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]
━━━━━━━━━━━━━━━━━━
OpenVPN SSL      :  https://$domain:8888/ssl-1196.ovpn
OpenVPN DIRECTO  :  https://$domain:8888/direct-1194.ovpn
OpenVPN PAYLOAD  :  https://$domain:8888/payload-1195.ovpn
━━━━━━━━━━━━━━━━━━
Link Cuenta : https://$domain:8888/ssh-$Login.txt
━━━━━━━━━━━━━━━━━━
        $author
━━━━━━━━━━━━━━━━━━
END
TEXT="
━━━━━━━━━━━━━━━━━━
  Trial SSH Premium Account
━━━━━━━━━━━━━━━━━━
Usuario         :  $Login
Contraseña      :  $Pass
Expira En       :  $timer Minuto(s)
━━━━━━━━━━━━━━━━━━
CITY             :  $CITY
Host             :  $domain
Login Limit      :  ${iplim} IP
Port OpenSSH     :  $SSHP
Port Dropbear    :  $DBP
Port SSH WS      :  80,8080,8088,8280,8880,2052,2082,2086,2095
Port SSH SSL WS  :  443
Port SSL/TLS     :  443
Port OVPN SSL    :  443
Port OVPN TCP    :  1194
Port OVPN UDP    :  2200
Proxy Squid      :  3128
BadVPN UDP       :  7100, 7300, 7300
━━━━━━━━━━━━━━━━━━
SSH UDP ZIVPN    : $domain:1-19999
USUARIO/PW       : $Login:$Pass
━━━━━━━━━━━━━━━━━━
DOM UDP HYSTERIA : $domain
USUARIO/PASSW  : $Login:$Pass
OBFS HYSTERIA    : $OBFS
PORT HYSTERIA    : 20000-39999
━━━━━━━━━━━━━━━━━━
SSH UDP CUSTOM   : $domain:40000-65535@$Login:$Pass
━━━━━━━━━━━━━━━━━━
SSH WS : $domain:80@$Login:$Pass
SSH SSL : $domain:443@$Login:$Pass
SSH SlowDNS : $sldomain:53@$Login:$Pass
━━━━━━━━━━━━━━━━━━
Host Slowdns     :  $sldomain
Port Slowdns     :  Todos los Puertos
Domain DNS      :  1.1.1.1 / 8.8.8.8
Pub Key          :   $slkey
━━━━━━━━━━━━━━━━━━
Payload WS/WSS   :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]
━━━━━━━━━━━━━━━━━━
OpenVPN SSL      :  https://$domain:8888/ssl.ovpn
OpenVPN TCP      :  https://$domain:8888/tcp.ovpn
OpenVPN UDP      :  https://$domain:8888/udp.ovpn
━━━━━━━━━━━━━━━━━━
Link Cuenta : https://$domain:8888/ssh-$Login.txt
━━━━━━━━━━━━━━━━━━
        $author
━━━━━━━━━━━━━━━━━━
"
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT2}" > /dev/null
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
cat> /etc/cron.d/trialssh${Login} << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root bash /usr/local/sbin/trial ssh $Login $Pass $expi
EOF
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC} ${WH}• Trial SSH Premium Account • " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Username   ${COLOR1}: ${WH}$Login"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Password   ${COLOR1}: ${WH}$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Expira En  ${COLOR1}: ${WH}$timer Minuto(s)"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
#echo -e "${COLOR1} $NC  ${WH}ISP        ${COLOR1}: ${WH}$ISP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}City       ${COLOR1}: ${WH}$CITY" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Host       ${COLOR1}: ${WH}$domain" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Login Limit${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OpenSSH    ${COLOR1}: ${WH}$SSHP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Dropbear   ${COLOR1}: ${WH}$DBP" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH-WS     ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH-SSL-WS ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSL/TLS    ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port TCP   ${COLOR1}: ${WH}1194" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port UDP   ${COLOR1}: ${WH}1-65535" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port SSL   ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OVPN TCP   ${COLOR1}: ${WH}https://$domain:8888/tcp.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OVPN UDP   ${COLOR1}: ${WH}https://$domain:8888/udp.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OVPN SSL   ${COLOR1}: ${WH}https://$domain:8888/ssl.ovpn" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}UDPGW      ${COLOR1}: ${WH}7100-7300" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
jm_account_tail "$Login" "$Pass" "$expi" "$JM_UUID" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log >(sed -E 's/\x1b\[[0-9;]*m//g' >> /var/www/html/ssh-$Login.txt)
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}HTTP WS    ${COLOR1}: ${WH}$domain:80@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}HTTP SSL   ${COLOR1}: ${WH}$domain:443@$Login:$Pass" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}Payload WS/WSS${COLOR1}: ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1}${NC}${WH}GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}Save Link Acount    : " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}https://$domain:8888/ssh-$Login.txt${NC}${COLOR1} $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}    ${WH}• $author •${NC}                 ${COLOR1} $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo "" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
read -n 1 -s -r -p "PRESIONE CUALQUIER TECLA PARA REGRESAR AL MENU"
m-sshovpn
}
function renew(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}            ${WH}• RENEW USERS •                   ${NC}${COLOR1}│$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│              ${WH}El usuario no existe!              ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU" 
m-sshovpn
fi 
echo -e "${COLOR1}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• RENOVAR USUARIOS •             ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ ${WH}Por favor seleccione el usuario que desea renovar${COLOR1} │"
echo -e "${COLOR1}│ ${WH}Escriba [0] Regresar al MENU                     ${COLOR1} │"
echo -e "${COLOR1}╰═══════════════════════════════════════════════════╯${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
User=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
Pass=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
egrep "^$User" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "Day Extend : " Days
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $Days))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
passwd -u $User
usermod -e  $exp4 $User
egrep "^$User" /etc/passwd >/dev/null
echo -e "$Pass\n$Pass\n"|passwd $User &> /dev/null
sed -i "s/### $User $exp/### $User $exp4/g" /etc/xray/ssh >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/ssh-$User.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$User.txt >/dev/null
#if [[ -e /var/www/html/CheckUser ]]; then
sed -i "s/$User:$exp/$User:$exp4/g" >> /var/www/html/CheckUser
#fi
####################################################################################
if [[ -e /root/UDPMOD/config.json ]]; then
CONFIG_FILE="/root/UDPMOD/config.json"
sed -i -E "s/\"config\": ?\[[[:space:]]*\"$User:$Pass\"[[:space:]]*\]/\"config\": [$(printf "\"%s\"," "$User:$Pass" | sed 's/,$//')]/g" "$CONFIG_FILE"
sudo systemctl daemon-reload
sudo systemctl restart udpmod
fi
if [[ -e /etc/zivpn/config.json ]]; then
CONFIG_FILE="/etc/zivpn/config.json"
sed -i -E "s/\"config\": ?\[[[:space:]]*\"$User:$Pass\"[[:space:]]*\]/\"config\": [$(printf "\"%s\"," "$User:$Pass" | sed 's/,$//')]/g" "$CONFIG_FILE"
sudo systemctl daemon-reload
sudo systemctl restart zivpn
fi
####################################################################################
clear
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  SSH RENOVACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>FECHA      :</b> <code>${TIME2} HORA </code>
<b>DETALLES   :</b> <code>CUENTA SSH </code>
<b>USUARIO   :</b> <code>$User </code>
<b>EXPIRA    :</b> <code>$exp4 </code>
<b>AGREGARON :</b> <code>$Days DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
"
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   TRANSACCIÓN EXITOSA </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$CITY </code>
<b>FECHA     :</b> <code>${TIME2} HORA</code>
<b>DETALLE   :</b> <code>Trx SSH </code>
<b>USUARIO   :</b> <code>$User</code>
<b>DURACION  :</b> <code>$Days DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>RENOVACION DE CUNETA..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}            ${WH}• RENOVACION DE USUARIOS •          ${NC}${COLOR1}│$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│"
echo -e "${COLOR1}│ ${WH}USUARIO    : $User"  
echo -e "${COLOR1}│ ${WH}Days Added : $Days Days"
echo -e "${COLOR1}│ ${WH}Expira En  : $exp4"
echo -e "${COLOR1}│"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
fi
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
}

show_api_user_info() {
local account="$1" response="" api_key="" account_file=""
api_key=$(cat /etc/jm-api/api.key 2>/dev/null || true)
if [ -n "$api_key" ] && command -v curl >/dev/null 2>&1; then
response=$(curl -fsS --max-time 5 -H "X-API-Key: ${api_key}" "http://127.0.0.1:8085/api/v1/users/${account}" 2>/dev/null || true)
fi
if [ -z "$response" ]; then
account_file="/etc/jm-api/accounts/${account}.json"
[ -f "$account_file" ] && response=$(cat "$account_file")
fi
[ -n "$response" ] || return 1
printf '%s' "$response" | python3 -c '
import json, sys
try:
    data = json.load(sys.stdin)
except Exception:
    raise SystemExit(1)
if not data.get("ok", True):
    raise SystemExit(1)
def val(obj, key, default="-"):
    value = obj.get(key, default) if isinstance(obj, dict) else default
    return default if value in (None, "") else str(value)
print("╭════════════════════════════════════════════════════════════╮")
print("│              CONFIGURACIÓN DE USUARIO (API)                │")
print("╰════════════════════════════════════════════════════════════╯")
for label, key in (("USUARIO", "username"), ("CONTRASEÑA", "password"), ("UUID", "uuid"), ("CREADO", "created_at"), ("EXPIRA", "expires_at"), ("LÍMITE IP", "ip_limit")):
    print(f"{label:<12}: {val(data, key)}")
protocols = data.get("protocols", {})
for name, info in protocols.items():
    if not isinstance(info, dict):
        continue
    state = "ACTIVO" if info.get("installed") else "NO INSTALADO"
    print(f"\n[{name.upper()}] {state}")
    for key in ("host", "port", "port_range", "username", "password", "uri", "ws_uri", "ssl_uri", "payload_ws"):
        if key in info and info[key] not in (None, ""):
            value = info[key]
            if isinstance(value, (dict, list)):
                value = json.dumps(value, ensure_ascii=False, separators=(", ", ": "))
            print(f"  {key}: {value}")
'
}

function cekconfig(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
CITY=$(curl -sS https://ipinfo.io/city)
ISP=$(curl -sS https://ipinfo.io/org)
author=$(cat /etc/profil)
IP=$(curl -sS ipinfo.io/ip);
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• CONFIGURACION DE USUARIOS •        ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│               ${WH}El usuario no existe!             ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
fi
echo -e "${COLOR1}╭═════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}             ${WH}• CONFIGURACION DE USUARIOS •          ${NC}${COLOR1}│$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ ${WH}Por favor seleccione el Usuario que desea Verificar ${COLOR1}│"
echo -e "${COLOR1}│ ${WH}Escriba [0] Regresar al MENU                        ${COLOR1}│"
echo -e "${COLOR1}╰═════════════════════════════════════════════════════╯${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
Login=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
log_file="/etc/xray/sshx/akun/log-create-${Login}.log"
if [ -f "$log_file" ]; then
cat "$log_file"
elif ! show_api_user_info "$Login"; then
echo -e "${RED}No se encontró información para ${Login}.${NC}"
echo -e "El usuario no tiene log antiguo ni registro API legible."
fi
read -n 1 -s -r -p "   Presione cualquier tecla para volver al MENU"
menu
}
function hapus(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}              ${WH}• BORRAR USUARIOS •             ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│              ${WH}El usuario no existe!              ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
fi
echo -e "${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                 ${WH}• BORRAR USUARIOS •              ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ ${WH}Por favor seleccione el usuario que desea eliminar ${COLOR1}│"
echo -e "${COLOR1}│ ${WH}Escriba [0] Regresar al MENU                       ${COLOR1}│"
echo -e "${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
Pengguna=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
Days=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
Pass=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^### $Pengguna $Days $Pass/d" /etc/xray/ssh
#if [[ -e /var/www/html/CheckUser ]]; then
sed -i "/^$Pengguna:$Days/d" /var/www/html/CheckUser
#fi
####################################################################################
if [[ -e /root/UDPMOD/config.json ]]; then
#CONFIG_FILE="/root/UDPMOD/config.json"
sed -i "s/,\"$Pengguna:$Pass\"//g" /root/UDPMOD/config.json
#sed -i "s/,\"$Pengguna:$Pass\"/\"$Pengguna:$Pass\"/; s/\"$Pengguna:$Pass\"//; s/\"$Pengguna:$Pass\"//" "$CONFIG_FILE" >/dev/null
sudo systemctl daemon-reload
sudo systemctl restart udpmod
fi
if [[ -e /etc/zivpn/config.json ]]; then
#CONFIG_FILE="/etc/zivpn/config.json"
#sed -i "s/,\"$Pengguna:$Days\"/\"$Pengguna:$Pass\"/; s/\"$Pengguna:$Pass\"//; s/\"$Pengguna:$Pass\"//" "$CONFIG_FILE" >/dev/null
sed -i "s/,\"$Pengguna:$Pass\"//g" /etc/zivpn/config.json
sudo systemctl daemon-reload
sudo systemctl restart zivpn
fi
####################################################################################
rm /var/www/html/ssh-$Pengguna.txt >/dev/null 2>&1
rm /var/www/html/APP/ssh-$Pengguna.txt >/dev/null 2>&1
rm /etc/xray/sshx/${Pengguna}IP >/dev/null 2>&1
rm /etc/xray/sshx/${Pengguna}login >/dev/null 2>&1
#rm /etc/xray/sshx/akun/log-create-${Pengguna}.log >/dev/null 2>&1
grep -rl "log-create-${Pengguna}.log" /etc/xray/sshx/akun/ | xargs rm -f
grep -rl "trialssh" /etc/cron.d | xargs rm -f 
if getent passwd $Pengguna > /dev/null 2>&1; then
userdel $Pengguna > /dev/null 2>&1
jm_xray_del "$Pengguna"
echo -e "Usuario $Pengguna fue Eliminado."
else
echo -e "Falla: Usuario $Pengguna No Existe."
fi
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  DELETE SSH OVPN</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>USUARIO   :</b> <code>$Pengguna </code>
<b>EXPIRA    :</b> <code>$Days </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>BORRADO DE CUENTA...</i>
"
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
}
function cek(){
checking_sc
rm -rf /tmp/systemd-*
rm -rf /tmp/tpm.*
rm -rf /tmp/ssh
clear
echo -e "$COLOR1╭════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC}         ${WH}SSH USUARIOS ACTIVOS${NC}           ${COLOR1}│${NC}"
echo -e "$COLOR1╰════════════════════════════════════════╯${NC}"
#echo -e "${COLOR1}╭═══════════════════════════════════════╮${NC}"
echo -e "$COLOR1╭════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${WH}USUARIO  |  ${Green}IP LOGIN  |  \033[0;33mID REGISTRADAS${COLOR1}│${NC}"
echo -e "$COLOR1╰════════════════════════════════════════╯${NC}"
echo -e " \E[0;41;36m         Dropbear User Login            ${NC}"
LOG="/var/log/auth.log";
cat $LOG | grep -i dropbear | grep -i "Password auth succeeded" > /tmp/log-db.txt
proc=( `ps aux | grep -i dropbear | awk '{print $2}'`);
for PID in "${proc[@]}"
do
cat /tmp/log-db.txt | grep "dropbear\[$PID\]" > /tmp/log-db-pid.txt
NUM=`cat /tmp/log-db-pid.txt | wc -l`;
USER=`cat /tmp/log-db-pid.txt | awk '{print $12}' | sed 's/'\''//g'`;
IP=`cat /tmp/log-db-pid.txt | awk '{print $14}' | sed 's/'\''//g'`;
TIME=`cat /tmp/log-db-pid.txt | grep -i "Password auth succeeded" | awk '{print $7}' | sed 's/.$//'`;
if [ $NUM -eq 1 ]; then
echo "$USER $TIME $IP $PID" >>/tmp/ssh
echo -e "    ${WH}$USER   ${Green}$IP  \033[0;33m$PID";
fi
done
echo -e " \E[0;41;36m         OpenSSH User Login             ${NC}"
cat $LOG | grep -i sshd | grep -i "Accepted password for" > /tmp/log-db.txt
data=( `ps aux | grep "\[priv\]" | sort -k 72 | awk '{print $2}'`);
for PID in "${data[@]}"
do
cat /tmp/log-db.txt | grep "sshd\[$PID\]" > /tmp/log-db-pid.txt;
NUM=`cat /tmp/log-db-pid.txt | wc -l`;
USER=`cat /tmp/log-db-pid.txt | awk '{print $7}'`;
IP=`cat /tmp/log-db-pid.txt | awk '{print $9}'`;
if [ $NUM -eq 1 ]; then
TIME=$(date +'%H:%M:%S')
echo "$USER $TIME $IP $PID" >>/tmp/ssh
echo -e "    ${WH}$USER   ${Green}$IP   \033[0;33m$PID";
fi
done
if [ ! -f "/tmp/ssh" ]; then
rm -rf /tmp/ip
rm -rf /tmp/ssh2
rm -rf /tmp/*.txt
TOTAL=00
echo -e "$COLOR1│${NC} \033[0;33mNO TIENES NINGUN USUARIO";
else
TOTAL=`cat /tmp/ssh | wc -l`;
rm -rf /tmp/ip
rm -rf /tmp/ssh2
rm -rf /tmp/*.txt
fi
#echo -e ""
echo -e "${COLOR1}╰═══════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${WH} Total Usuarios Activos: ${Green}[${NC}${Purple}$TOTAL${NC}${Green}]${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════╯${NC}"
if [ ! -f "/etc/openvpn/server/openvpn" ]; then
echo -e ""
else
echo -e "${COLOR1}╭═══════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│            ${WH}OVPN USUARIOS ACTIVOS${NC}       ${COLOR1}│${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════╮${NC}"
# Process OpenVPN
cat /etc/openvpn/server/openvpn-tcp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-tcp.txt
cat /tmp/vpn-login-tcp.txt
cat /etc/openvpn/server/openvpn-udp.log | grep -w "^CLIENT_LIST" | cut -d ',' -f 2,3,8 | sed -e 's/,/      /g' > /tmp/vpn-login-udp.txt
cat /tmp/vpn-login-udp.txt
echo -e "${COLOR1}╰═══════════════════════════════════════╯${NC}"
echo ""
fi
#read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
#m-sshovpn
echo -e "${Blue} FIX USUARIOS PRESIONA ( f ) "
echo -e "${Purple} ELIMINAR USUARIO O CERRAR SESION \033[0;33mID ${Purple}PRESIONA ( k )${COLOR1}"
echo -e "${Purple} ELIMINAR USUARIOS O CERRAR SESIONES \033[0;33mID ${Purple}PRESIONA ( a )${COLOR1}"
#echo -e "${COLOR1} CUALQUIER TECLA REGRESAR AL MENU "; read answer
read -p " CUALQUIER TECLA REGRESAR AL MENU " answer
if [[ $answer == "k" ]] ;then
echo -e "$COLOR1╭════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${WH}INGRESA ID PARA ELIMINAR UNA SESION${NC}    ${COLOR1}│${NC}"
echo -e "${COLOR1}│${NC} ${WH}EJEMPLO: 825715${NC}          ${COLOR1}│${NC}"
echo -e "$COLOR1╰════════════════════════════════════════╯${Purple}"
echo ""
#echo -e "${Purple} INGRESA ID A ELIMINAR (EJEMPLO: 232323): "; read ids
read -p " INGRESA ID A ELIMINAR (EJEMPLO: 232323): " ids
#kill -s SIGINT $ids
#kill -HUP $ids
kill -9 $ids >/dev/null 2>&1
echo -e "${Yellow} SESION CERRADA CORRECTAMENTE JM SCRIPT"
echo -e "${Yellow} REGRESANDO AL MENU"
sleep 1
systemctl daemon-reload
m-sshovpn
elif [[ $answer == "a" ]] ;then
echo -e "$COLOR1╭════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${WH}INGRESA ID PARA ELIMINAR UNA SESION${NC}    ${COLOR1}│${NC}"
echo -e "${COLOR1}│${NC} ${WH}SI DESEAS CERRAR MAS DE UN PROCESO${NC}     ${COLOR1}│${NC}"
echo -e "${COLOR1}│${NC} ${WH}ESCIBRE ID MAS ESPACIO Y SIGUIENTE ID${NC}  ${COLOR1}│${NC}"
echo -e "${COLOR1}│${NC} ${WH}EJEMPLO: 322332 423242 825715${NC}          ${COLOR1}│${NC}"
echo -e "$COLOR1╰════════════════════════════════════════╯${Purple}"
echo ""
#echo -e "${Purple} INGRESA ID A ELIMINAR (EJEMPLO: 232323): "; read ids
read -p " INGRESA IDs A ELIMINAR (EJEMPLO: 232323): " ids
#kill -s SIGINT $ids
#kill -HUP $ids 1698638,
kill -9 $ids >/dev/null 2>&1
echo -e "${Yellow} SESIONES CERRADAS CORRECTAMENTE JM SCRIPT"
echo -e "${Yellow} REGRESANDO AL MENU"
sleep 1
systemctl daemon-reload
m-sshovpn
elif [[ $answer == "f" ]] ;then
rm -rf /tmp/*
rm -rf /var/log/haproxy.log
rm -rf /var/log/auth.log
apt-get purge -y rsyslog > /dev/null
apt-get install -y rsyslog > /dev/null
sed -i 's/#module(load="imudp")/module(load="imudp")/g' /etc/rsyslog.conf
sed -i 's/#input(type="imudp" port="514"")/input(type="imudp" port="514"/g' /etc/rsyslog.conf
sed -i 's/#module(load="imtcp")/module(load="imtcp")/g' /etc/rsyslog.conf
sed -i 's/#input(type="imtcp" port="514"")/input(type="imctp" port="514"/g' /etc/rsyslog.conf
echo "dropbear.err;dropbear.crit @127.0.0.1:514" >> /etc/rsyslog.conf
sed -i '/auth,authpriv\.\*/c\*.*;auth,authpriv.*             /var/log/auth.log' /etc/rsyslog.d/50-default.conf
systemctl daemon-reload
systemctl restart rsyslog
systemctl restart haproxy
echo -e "${yell}  FIX APLICADO CORRECTAMENTE JM SCRIPT"
echo -e "${yell}  ESPERA UNOS SEGUNDOS PARA VER LOS USUARIOS"
sleep 1
m-sshovpn
else
m-sshovpn
fi
}
function limitssh(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/ssh")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Limit SSH Account ⇲        ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "No tienes clientes existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Limit SSH Account ⇲        ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Seleccione el cliente existente que desea cambiar Limite IP"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
fi
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (IP) Nuevo: " iplim
done
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
if [ -z ${iplim} ]; then
iplim="0"
fi
user=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/ssh" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
echo "${iplim}" >/etc/xray/sshx/${user}IP
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  SSH IP LIMIT</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>USUARIO   :</b> <code>$user </code>
<b>EXPIRA    :</b> <code>$exp </code>
<b>IP LIMIT NEW :</b> <code>$iplim IP </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>CAMBIADO LIMITE DE IP...</i>
"
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " La cuenta SSH cambió correctamente el límite de IP"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Limit IP    : $iplim IP"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
}
clear
function listssh(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│      \033[1;37mPor favor seleccione su opción      ${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│  [ 1 ]  \033[1;37mAUTO BLOQUEAR USUARIO SSH      ${NC}"
echo -e "${COLOR1}│  [ 2 ]  \033[1;37mAUTO BORRAR USUARIO SSH    ${NC}"
echo -e "${COLOR1}│  "
echo -e "${COLOR1}│  [ 0 ]  \033[1;37mREGRESAR AL MENU    ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
until [[ $lock =~ ^[0-2]+$ ]]; do
read -p "   Por favor seleccione los números 1 al 2 : " lock
done
if [[ $lock == "0" ]]; then
menu
elif [[ $lock == "1" ]]; then
clear
echo "lock" > /etc/typessh
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│$NC CON EXITO AUTOBLOQUEO AUTOMATICO  ${NC}"
echo -e "${COLOR1}│$NC Si el usuario viola la cuenta de bloqueo automático. ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
sleep 1
elif [[ $lock == "2" ]]; then
clear
echo "delete" > /etc/typessh
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│$NC Con Éxito Eliminación Automática de Cuenta ${NC}"
echo -e "${COLOR1}│$NC Si el usuario viola la cuenta de eliminación automática. ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
sleep 1
fi
type=$(cat /etc/typessh)
if [ $type = "lock" ]; then
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│$NC POR FAVOR ESCRIBA LA CANTIDAD DE TIEMPO PARA ESTAR BLOQUEADO  ${NC}"
echo -e "${COLOR1}│$NC PUEDE ESCRIBIR EN 15 MINUTOS ETC.. ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Tiempo Total de Bloqueo: " -e notif2
echo "${notif2}" > /etc/waktulockssh
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC POR FAVOR ESCRIBA EL NÚMERO DE NOTIFICACIONES PARA AUTO BLOQUEO    ${NC}"
echo -e "${COLOR1}│ $NC CUENTAS DE USUARIOS DE INICIO DE SESIÓN MÚLTIPLE     ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Si desea notificaciones 3x bloqueo, escriba 3, etc.: " -e notif
cd /etc/xray/sshx
echo "$notif" > notif
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC CAMBIADO CON ÉXITO LA NOTIFICACIÓN DE BLOQUEO  $notif $NC "
echo -e "${COLOR1}│ $NC CAMBIADO CON ÉXITO EL TIEMPO DE BLOQUEO DE NOTIF PARA $notif2 MINUTO $NC "
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
else
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│$NC POR FAVOR ESCRIBA LA CANTIDAD DE TIEMPO PARA ESCANEAR ${NC}"
echo -e "${COLOR1}│$NC USUARIOS QUE SON MULTI LOGIN . ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Escribir tiempo de Escaneo (MINUTOS) : " -e notif2
echo "# Autokill" >/etc/cron.d/tendang
echo "SHELL=/bin/sh" >>/etc/cron.d/tendang
echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >>/etc/cron.d/tendang
echo "*/$notif2 * * * *  root bash /usr/local/sbin/tendang" >>/etc/cron.d/tendang
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC POR FAVOR ESCRIBA EL NÚMERO DE NOTIFICACIONES PARA AUTO BLOQUEO    ${NC}"
echo -e "${COLOR1}│ $NC CUENTAS DE USUARIOS DE INICIO DE SESIÓN MÚLTIPLE     ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Si desea notificaciones 3x bloqueo, escriba 3, etc.: " -e notif
cd /etc/xray/sshx
echo "$notif" > notif
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯{NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC CAMBIADO CON ÉXITO LA NOTIFICACIÓN DE BLOQUEO PARA $notif $NC "
echo -e "${COLOR1}│ $NC CAMBIANDO CON ÉXITO EL TIEMPO DE BLOQUEO DE NOTIF PARA $notif2 MINUTOS $NC "
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
fi
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
}
function lockssh(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e /etc/xray/sshx/listlock ]; then
echo "" > /etc/xray/sshx/listlock
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/sshx/listlock")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock SSH Account ⇲       ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún usuario existente bloqueado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock SSH Account ⇲       ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el cliente existente que desea desbloquear"
echo " Escriba [0] Regresar al MENU"
echo " Escribe CLEAR para Eliminar todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User      Expired"
grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-sshovpn
fi
if [[ ${CLIENT_NUMBER} == 'clear' ]]; then
rm /etc/xray/sshx/listlock
m-sshovpn
fi
fi
done
user=$(grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
pass=$(grep -E "^### " "/etc/xray/sshx/listlock" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
passwd -u $user &> /dev/null
echo -e "### $Login $exp $Pass" >> /etc/xray/ssh
sed -i "/^### $user $exp $pass/d" /etc/xray/sshx/listlock &> /dev/null
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  SSH UNLOCK </b>
<code>━━━━━━━━━━━━━━━━━━
<b>DOMINIO   :</b> <code>${domain} </code>
<b>USUARIO   :</b> <code>$user </code>
<b>IP LIMIT  :</b> <code>$iplim IP </code>
<b>EXPIRA    :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>DESBLOQUEO DE CUENTA...</i>
"
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " SSH Account Unlock Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-sshovpn
}
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│${NC} ${COLBG1}                 ${WH}• SSH PANEL MENU •               ${NC}${COLOR1} │$NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}CREAR CUENTA${NC}    ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}CEK USER ONLINE${NC}    ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}CUENTA TEMPORAL${NC} ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}CEK CONFIG USER ${NC}   ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}RENOVAR CUENTA${NC}  ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}CAMBIAR LIMITE IP${NC}  ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}BORRAR CUENTA${NC}   ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}CONFIG BLOQ SESION${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}REGRESAR${NC}        ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}DESBLOQUEAR SESION${NC} ${COLOR1}│$NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭═════════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮ ${NC}"
echo -e " ${COLOR1}${NC}               ${WH}        • $author •                 ${COLOR1} $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; usernew ; exit ;;
02 | 2) clear ; trial ; exit ;;
03 | 3) clear ; renew ; exit ;;
04 | 4) clear ; hapus ; exit ;;
05 | 5) clear ; cek ; exit ;;
06 | 6) clear ; cekconfig ; exit ;;
07 | 7) clear ; limitssh; exit ;;
08 | 8) clear ; listssh ; exit ;;
09 | 9) clear ; lockssh ; exit ;;
#10 | 10) clear ; hapuslama ; exit ;;
00 | 0) clear ; menu ; exit ;;
X  | 0) clear ; m-sshovpn ;;
x) exit ;;
*) echo "Lo presionaste mal " ; sleep 1 ; m-sshovpn ;;
esac
