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
OBFS=$(cat /usr/bin/obfs)
ISP=$(cat /etc/xray/isp)
CITY=$(cat /etc/xray/city)
author=$(cat /etc/profil)
domain=`cat /etc/xray/domain`
patch=`cat /etc/xray/patch`
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
# REMOVED SBG CALL: URL="https://api.telegram.org/bot$KEY/sendMessage"
CHATID2=$(cat /etc/perlogin/id)
KEY2=$(cat /etc/perlogin/token)
# REMOVED SBG CALL: URL2="https://api.telegram.org/bot$KEY2/sendMessage"
cd
if [ ! -e /etc/xray/sshx/akun ]; then
mkdir -p /etc/xray/sshx/akun
fi
checking_sc() {
clear
}
#checking_sc
rm -rf /root/checkIP*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e /etc/vmess/akun ]; then
mkdir -p /etc/vmess/akun
fi
function add-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• Add Vmess Account •          ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
read -p " INGRESA NOMBRE DE USUARIO: " user
#uuid=$(cat /proc/sys/kernel/random/uuid)
until [[ $uuid =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -rp " CREAR ID (ENTER ID AUTOMATICO ALETORIO) :" -e uuid
CLIENT_EXISTS=$(grep -w $uuid /etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} -ge '1' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• Add Vless Account •          ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│${WH} ID duplicado Por favor cree otro ID o BORRE     ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar"
add-vmess
fi
done
[[ -z "$uuid" ]] && uuid=`cat /proc/sys/kernel/random/uuid`
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p "EXPIRACION (DIAS): " masaaktif
done
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (IP) o 0 ILIMITADO: " iplim
done
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (GB) o 0 ILIMITADO: " Quota
done
if [ ! -e /etc/vmess ]; then
mkdir -p /etc/vmess
fi
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vmess/${user}
fi
echo "${iplim}" >/etc/vmess/${user}IP
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\#vm '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\#vmg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
asu=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
ask=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "none"
}
EOF`
grpc=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "vmgr-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)
vmesslink1="vmess://$(echo $asu | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
VMESS_WS=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
VMESS_NON_TLS=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "none"
}
EOF`
VMESS_GRPC=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "/vmgr-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
VMESS_OPOK=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "http://tsel.me/worryfree",
"type": "none",
"host": "tsel.me",
"tls": "none"
}
EOF`
echo -e "#Vmess $user $exp $uuid" >> /etc/xray/token
CLIENT_EXISTS=$(grep -w $user /var/www/html/CheckUser | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
sed -i "/^$user/d" /var/www/html/CheckUser
echo -e "$user:$exp" >> /var/www/html/CheckUser
else
echo -e "$user:$exp" >> /var/www/html/CheckUser
fi
cat > /var/www/html/vmess-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
	Premium Vmess Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path         : /vm-${patch}
Path Support : https://bug.com/vmess
ServiceName  : vmgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vmesslink1}
━━━━━━━━━━━━━━━━━━
Link NTLS    :
${vmesslink2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${vmesslink3}
━━━━━━━━━━━━━━━━━━
Link Cuenta :
https://$domain:8888/vmess-$user.txt
━━━━━━━━━━━━━━━━━━
EXPIRA EL    : $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
END
if [ ${Quota} = '9999' ]; then
TEXT="
━━━━━━━━━━━━━━━━━━
	Premium Vmess Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path         : /vm-${patch}
Path Support : https://bug.com/vmess
ServiceName  : vmgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vmesslink1}
━━━━━━━━━━━━━━━━━━
Link NTLS    :
${vmesslink2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${vmesslink3}
━━━━━━━━━━━━━━━━━━
Link Cuenta :
https://$domain:8888/vmess-$user.txt
━━━━━━━━━━━━━━━━━━
EXPIRA EL    : $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
else
TEXT="
━━━━━━━━━━━━━━━━━━
	Premium Vmess Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path         : /vm-${patch}
Path Support : https://bug.com/vm-${patch}
ServiceName  : vmgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vmesslink1}
━━━━━━━━━━━━━━━━━━
Link NTLS    :
${vmesslink2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${vmesslink3}
━━━━━━━━━━━━━━━━━━
Link Cuenta :
https://$domain:8888/vmess-$user.txt
━━━━━━━━━━━━━━━━━━
EXPIRA EL    : $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
fi
# REMOVED SBG CALL: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
#user2=$(echo "$user" | cut -c 1-3)
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   CREADO EXITOSO DE VMESS </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>CIUDAD   :</b> <code>$CITY </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLE  :</b> <code>CUENTA VMESS </code>
<b>USUARIO  :</b> <code>${user} </code>
<b>IP       :</b> <code>${iplim} IP </code>
<b>FECHA EXP :</b> <code>$exp </code>
<b>EXPIRA EN :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>Notificación de creacion de cuenta Vmess..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Premium Vmess Account • ${NC} ${COLOR1} $NC" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}User          ${COLOR1}: ${WH}${user}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ISP           ${COLOR1}: ${WH}$ISP" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}City          ${COLOR1}: ${WH}$CITY" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Domain        ${COLOR1}: ${WH}${domain}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/vmess/akun/log-create-${user}.log
if [ ${Quota} = '9999' ]; then
echo -ne
else
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/vmess/akun/log-create-${user}.log
fi
echo -e "${COLOR1} ${NC} ${WH}Port TLS      ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC     ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}UUID         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}alterId       ${COLOR1}: ${WH}0" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Security      ${COLOR1}: ${WH}auto" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Network       ${COLOR1}: ${WH}ws" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path          ${COLOR1}: ${WH}/vm-${patch}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path Support  ${COLOR1}: ${WH}http://bug/vmess" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ServiceName   ${COLOR1}: ${WH}vmgr-${patch}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket TLS      ${WH}:${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vmesslink1}${NC}"  | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket NTLS ${WH}: ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vmesslink2}${NC}"  | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket gRPC     ${WH}: ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vmesslink3}${NC}"  | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Format Openclash ${COLOR1}:" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}https://$domain:8888/vmess-$user.txt${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}EXPIRA En    ${COLOR1}: ${WH}$exp" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• $author •${NC}     " | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo "" | tee -a /etc/vmess/akun/log-create-${user}.log
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-vmess
}

function trial-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}           ${WH}• Trial Vmess Account •             ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "EXPIRACION (MINUTOS): " timer
done
user=Trial-`</dev/urandom tr -dc X-Z0-9 | head -c4`
iplim=1
Quota=10
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=0
if [ ! -e /etc/vmess ]; then
mkdir -p /etc/vmess
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vmess/${user}
fi
echo "${iplim}" > /etc/vmess/${user}IP
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vmess$/a\#vm '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\#vmg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
cat> /etc/cron.d/trialvmess${user} << EOF
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root bash /usr/local/sbin/trial
EOF
asu=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
ask=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "none"
}
EOF`
grpc=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "vmgr-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
vmess_base641=$( base64 -w 0 <<< $vmess_json1)
vmess_base642=$( base64 -w 0 <<< $vmess_json2)
vmess_base643=$( base64 -w 0 <<< $vmess_json3)
vmesslink1="vmess://$(echo $asu | base64 -w 0)"
vmesslink2="vmess://$(echo $ask | base64 -w 0)"
vmesslink3="vmess://$(echo $grpc | base64 -w 0)"
VMESS_WS=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
VMESS_NON_TLS=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "/vm-${patch}",
"type": "none",
"host": "${domain}",
"tls": "none"
}
EOF`
VMESS_GRPC=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "443",
"id": "${uuid}",
"aid": "0",
"net": "grpc",
"path": "/vmgr-${patch}",
"type": "none",
"host": "${domain}",
"tls": "tls"
}
EOF`
VMESS_OPOK=`cat<<EOF
{
"v": "2",
"ps": "${user}",
"add": "${domain}",
"port": "80",
"id": "${uuid}",
"aid": "0",
"net": "ws",
"path": "http://tsel.me/worryfree",
"type": "none",
"host": "tsel.me",
"tls": "none"
}
EOF`
echo -e "#Vmess $user $exp $uuid" >> /etc/xray/token
CLIENT_EXISTS=$(grep -w $user /var/www/html/CheckUser | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
sed -i "/^$user/d" /var/www/html/CheckUser
echo -e "$user:$exp" >> /var/www/html/CheckUser
else
echo -e "$user:$exp" >> /var/www/html/CheckUser
fi
cat > /var/www/html/vmess-$user.txt <<-END
_______________________________________________________
Format Vmess WS (CDN)
_______________________________________________________
- name: vmess-$user-WS (CDN)
type: vmess
server: ${domain}
port: 443
uuid: ${uuid}
alterId: 0
cipher: auto
udp: true
tls: true
skip-cert-verify: true
servername: ${domain}
network: ws
ws-opts:
path: /vm-${patch}
headers:
Host: ${domain}
_______________________________________________________
Format Vmess WS (CDN) Non TLS
_______________________________________________________
- name: vmess-$user-WS (CDN) Non TLS
type: vmess
server: ${domain}
port: 80
uuid: ${uuid}
alterId: 0
cipher: auto
udp: true
tls: false
skip-cert-verify: false
servername: ${domain}
network: ws
ws-opts:
path: /vm-${patch}
headers:
Host: ${domain}
_______________________________________________________
Format Vmess gRPC (SNI)
_______________________________________________________
- name: vmess-$user-gRPC (SNI)
server: ${domain}
port: 443
type: vmess
uuid: ${uuid}
alterId: 0
cipher: auto
network: grpc
tls: true
servername: ${domain}
skip-cert-verify: true
grpc-opts:
grpc-service-name: vmgr-${patch}
_______________________________________________________
Format Vmess WS (CDN) Non TLS Opok TSEL
_______________________________________________________
- name: vmess-$user-WS (CDN) Non TLS
type: vmess
server: ${domain}
port: 80
uuid: ${uuid}
alterId: 0
cipher: auto
udp: true
tls: false
skip-cert-verify: true
servername: comunity.instagram.com
network: ws
ws-opts:
path: http://tsel.me/worryfree
headers:
Host: ${domain}
_______________________________________________________
Link Vmess Account
_______________________________________________________
Link TLS : vmess://$(echo $VMESS_WS | base64 -w 0)
_______________________________________________________
Link NTLS : vmess://$(echo $VMESS_NON_TLS | base64 -w 0)
_______________________________________________________
Link gRPC : vmess://$(echo $VMESS_GRPC | base64 -w 0)
_______________________________________________________
Link Opok : vmess://$(echo $VMESS_OPOK | base64 -w 0)
_______________________________________________________
END
TEXT="
━━━━━━━━━━━━━━━━━━
	Trial Premium Vmess Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path         : /vm-${patch}
Path Support : https://bug.com/vm-${patch}
ServiceName  : vmgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vmesslink1}
━━━━━━━━━━━━━━━━━━
Link NTLS    :
${vmesslink2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${vmesslink3}
━━━━━━━━━━━━━━━━━━
Link Cuenta :
https://$domain:8888/vmess-$user.txt
━━━━━━━━━━━━━━━━━━
EXPIRA En    : $timer Minutes
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
# REMOVED SBG CALL: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Trial Premium Vmess Account • ${NC} ${COLOR1} $NC" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}User          ${COLOR1}: ${WH}${user}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ISP           ${COLOR1}: ${WH}$ISP" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}City          ${COLOR1}: ${WH}$CITY" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Domain        ${COLOR1}: ${WH}${domain}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/log-create-.log
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/log-create-.log
echo -e "${COLOR1} ${NC} ${WH}Port TLS      ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC     ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}UUID         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}alterId       ${COLOR1}: ${WH}0" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Security      ${COLOR1}: ${WH}auto" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Network       ${COLOR1}: ${WH}ws" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path          ${COLOR1}: ${WH}/vm-${patch}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path Support  ${COLOR1}: ${WH}http://bug/vm-${patch}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ServiceName   ${COLOR1}: ${WH}vmgr-${patch}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket TLS      ${WH}:${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vmesslink1}${NC}"  | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket NTLS ${WH}: ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vmesslink2}${NC}"  | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket gRPC     ${WH}: ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vmesslink3}${NC}"  | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Format Openclash ${COLOR1}:" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}https://$domain:8888/vmess-$user.txt${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}EXPIRA En     ${COLOR1}: ${WH}$timer Minutes" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• $author •${NC}     " | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo "" | tee -a /etc/vmess/akun/log-create-${user}.log
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-vmess
}
function renew-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vmg " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Renovar Cuenta Vmess ⇲      ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes clientes existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Renovar Cuenta Vmess ⇲      ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el cliente existente que desea renovar"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vmess
fi
fi
done
read -p "EXPIRACION (DIAS): " masaaktif
user=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/#vm $user $exp/#vm $user $exp4/g" /etc/xray/config.json
sed -i "s/#vmg $user $exp/#vmg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/vmess-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user:$exp/$user:$exp4/g" /var/www/html/CheckUser >/dev/null
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token >/dev/null
clear
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   XRAY VMESS RENOVACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMAIN     :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>FECHA      :</b> <code>${TIME2} HORA </code>
<b>DETALLES   :</b> <code>CUENTA VMESS </code>
<b>USERNAME   :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp4 </code>
<b>AGREGARON  :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " La cuenta VMESS se Renovó Exitosamente"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Expira En   : $exp4"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-vmess
}
function limit-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vmg " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Limitar Cuenta Vmess ⇲      ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes clientes existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Limitar Cuenta Vmess ⇲      ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el cliente existente del cual desea cambiar la IP"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vmess
fi
fi
done
clear
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (IP) o 0 ILIMITADO: " iplim
done
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (GB) o 0 ILIMITADO: " Quota
done
if [ ! -e /etc/vmess ]; then
mkdir -p /etc/vmess
fi
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
user=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
echo "${iplim}" >/etc/vmess/${user}IP
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vmess/${user}
fi
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VMESS IP LIMITE</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>USUARIO   :</b> <code>$user </code>
<b>NUEVO LIMITE IP :</b> <code>$iplim IP </code>
<b>NUEVO LIMITE CUOTA :</b> <code>$Quota GB </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>Con Éxito, Cambiado Límite...</i>
"
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
echo " La cuenta VMESS cambió correctamente el límite de IP"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Limit IP    : $iplim IP"
echo " Limit Cuota : $Quota GB"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
}
function del-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vmg " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Delete Vmess Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes clientes existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Eliminar Cuenta Vmess ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el cliente existente que desea eliminar"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vmess
fi
fi
done
user=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
if [ ! -e /etc/vmess/akundelete ]; then
echo "" > /etc/vmess/akundelete
fi
clear
echo "### $user $exp $uuid" >> /etc/vmess/akundelete
sed -i "/^#vmg $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#vm $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#Vmess $uuid $exp $user/,/^},{/d" /etc/xray/token
clear
rm /var/www/html/vmess-$user.txt >/dev/null 2>&1
rm /var/www/html/APP/ssh-$user.txt >/dev/null 2>&1
rm /etc/vmess/${user} >/dev/null 2>&1
rm /etc/vmess/${user}IP >/dev/null 2>&1
rm /etc/vmess/${user}login >/dev/null 2>&1
rm /etc/vmess/akun/log-create-${user}.log >/dev/null 2>&1
grep -rl "${user}" /etc/vmess/akun/ | xargs rm -f
clear
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  BORRADO XRAY VMESS </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>Con Exito, Borrado de Cuenta...</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Cuenta de Vmess Eliminada Exitosamente"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Expira El   : $exp"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-vmess
}
tim2sec() {
mult=1
arg="$1"
inu=0
while [ ${#arg} -gt 0 ]; do
prev="${arg%:*}"
if [ "$prev" = "$arg" ]; then
curr="${arg#0}"
prev=""
else
curr="${arg##*:}"
curr="${curr#0}"
fi
curr="${curr%.*}"
inu=$((inu + curr * mult))
mult=$((mult * 60))
arg="$prev"
done
echo "$inu"
}
function cek-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
function con() {
    local -i bytes=$1;
    if [[ $bytes -lt 1024 ]]; then
        echo "${bytes}B"
    elif [[ $bytes -lt 1048576 ]]; then
        echo "$(( (bytes + 1023)/1024 ))KB"
    elif [[ $bytes -lt 1073741824 ]]; then
        echo "$(( (bytes + 1048575)/1048576 ))MB"
    else
        echo "$(( (bytes + 1073741823)/1073741824 ))GB"
    fi
}
echo -n > /tmp/other.txt
bash /usr/local/sbin/xraylimit
clear
data=( `cat /etc/xray/config.json | grep '^#vmg' | cut -d ' ' -f 2 | sort | uniq`);
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}            ${WH}• VMESS USER ONLINE •              ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/ipvmess.txt
data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 4 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 4 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipvmess.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipvmess.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/ipvmess.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
iplimit=$(cat /etc/vmess/${akun}IP)
jum2=$(cat /tmp/ipvmess.txt | wc -l)
byte=$(cat /etc/vmess/${akun})
lim=$(con ${byte})
wey=$(cat /etc/limit/vmess/${akun})
gb=$(con ${wey})
lastlogin=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 4 | tail -1)
echo -e "  ${COLOR1}═══════════════════════════════════════════════${NC}"
echo -e "   ${COLOR1}${NC} USUARIO  : \033[0;33m$akun"
echo -e "   ${COLOR1}${NC} IP LOGIN : \033[0;33m$lastlogin"
echo -e "   ${COLOR1}${NC} USADO CUOTA : \033[0;33m$gb"
echo -e "   ${COLOR1}${NC} LIMITE CUOTA : \033[0;33m$lim"
echo -e "   ${COLOR1}${NC} LIMITE IP : \033[0;33m$iplimit"
echo -e "   ${COLOR1}${NC} LOGIN IP : \033[0;33m$jum2"
#printf "  %-13s %-7s %-8s %2s\n" "  Usuario : ${akun}"
#printf "  %-13s %-7s %-8s %2s\n" "  Login    : $lastlogin"
#printf "  %-13s %-7s %-8s %2s\n" "  Usado Cuota : ${gb}"
#printf "  %-13s %-7s %-8s %2s\n" "  Limite Cuota : ${lim}"
#printf "  %-13s %-7s %-8s %2s\n" "  Limite IP : $iplimit"
#printf "  %-13s %-7s %-8s %2s\n" "  Login IP : $jum2" 
echo -e "  ${COLOR1}═══════════════════════════════════════════════${NC}"
fi 
rm -rf /tmp/ipvless.txt
done
rm -rf /tmp/other.txt
echo ""
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione cualquier tecla para retroceder al MENU"
m-vmess
}
function list-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vmg " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Config Vmess Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes clientes existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
fi
clear
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Configuracion Cuenta Vmess ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente para ver la Configuración."
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vmess
fi
fi
done
clear
user=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
cat /etc/vmess/akun/log-create-${user}.log
cat /etc/vmess/akun/log-create-${user}.log > /etc/NotifCuenta
sed -i 's/\x1B\[1;37m//g' /etc/NotifCuenta
sed -i 's/\x1B\[1;96m//g' /etc/NotifCuenta
sed -i 's/\x1B\[0m//g' /etc/NotifCuenta
#cat /etc/NotifCuenta > /root/vmess-${user}
#cd /root
#zip -r Vmess-${user}.zip vmess-${user} > /dev/null 2>&1
#rclone copy /root/Vmess-${user}.zip dr:/
#url=$(rclone link dr:/Vmess-${user}.zip)
#id=(`echo $url | grep '^https' | cut -d'=' -f2`)
#Log=`cat /etc/NotifCuenta`
#link="https://drive.google.com/u/4/uc?id=${id}&export=download"
#TEXT="
#$Log
#𝐀𝐫𝐜𝐡𝐢𝐯𝐨 𝐝𝐞 𝐂𝐮𝐞𝐧𝐭𝐚 𝐕𝐦𝐞𝐬𝐬
#𝕃𝕚𝕟𝕜 𝔻𝕖𝕤𝕔𝕒𝕣𝕘𝕒 : $link"
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
#rm -fr /root/vmess-${user} &> /dev/null
#rm -fr /root/Vmess-${user}.zip &> /dev/null
Log=`cat /etc/NotifCuenta`
TEXT="
$Log"
# REMOVED SBG CALL: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
rm -rf /etc/NotifCuenta
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
}
clear
function login-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear	
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│      \033[1;37mPor favor seleccione su Opción      ${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│  [ 1 ]  \033[1;37mAUTO BLOQUEADO DE USUARIO TODOS XRAY      ${NC}"
echo -e "${COLOR1}│  "
echo -e "${COLOR1}│  [ 2 ]  \033[1;37mAUTO BORRADO DE USUARIO TODOS XRAY    ${NC}"
echo -e "${COLOR1}│  "
echo -e "${COLOR1}│  "
echo -e "${COLOR1}│  [ 0 ]  \033[1;37mBACK TO MENU    ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
until [[ $lock =~ ^[0-2]+$ ]]; do
read -p "   Por favor seleccione los números 1 al 2 : " lock
done
if [[ $lock == "0" ]]; then
menu
elif [[ $lock == "1" ]]; then
clear
echo "lock" > /etc/typexray
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│$NC CON EXITO, Cuenta Auto Bloqueado  ${NC}"
echo -e "${COLOR1}│$NC Si el Usuario viola la Cuenta... Bloqueo Automático. ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
sleep 1
elif [[ $lock == "2" ]]; then
clear
echo "delete" > /etc/typexray
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│$NC CON EXITO, Cuenta Auto Borrado ${NC}"
echo -e "${COLOR1}│$NC Si el Usuario viola la Cuenta... Eliminación Automática. ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
sleep 1
fi
type=$(cat /etc/typexray)
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
echo "${notif2}" > /etc/waktulock
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC POR FAVOR ESCRIBA EL NÚMERO DE NOTIFICACIONES PARA AUTO BLOQUEO    ${NC}"
echo -e "${COLOR1}│ $NC CUENTAS DE USUARIOS DE INICIO DE SESIÓN MÚLTIPLE     ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Si desea Notificaciones 3x Bloqueo, Escriba 3, etc.: " -e notif
echo "$notif" > /etc/vless/notif
echo "$notif" > /etc/vmess/notif
echo "$notif" > /etc/trojan/notif
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC CAMBIANDO CON ÉXITO LA NOTIFICACIÓN DE BLOQUEO PARA $notif $NC "
echo -e "${COLOR1}│ $NC CAMBIANDO CON ÉXITO EL TIEMPO DE BLOQUEO DE NOTIF PARA $notif2 MINUTOS $NC "
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
else
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC POR FAVOR ESCRIBA LA CANTIDAD DE TIEMPO PARA USUARIOS DE INICIO DE SESIÓN MÚLTIPLE   ${NC}"
echo -e "${COLOR1}│ $NC CADA MINUTO POR LO QUE UNA NOTIFICACIÓN CADA POCOS MINUTOS. ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Jika Mau 3menit baru keNotif tulis 3, dst: " -e notif2
echo "# Autokill" >/etc/cron.d/xraylimit
echo "SHELL=/bin/sh" >>/etc/cron.d/xraylimit
echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >>/etc/cron.d/xraylimit
echo "*/$notif2 * * * *  root bash /usr/local/sbin/xraylimit" >>/etc/cron.d/xraylimit
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1} $NC POR FAVOR ESCRIBA EL NÚMERO DE NOTIFICACIONES PARA BLOQUEO    ${NC}"
echo -e "${COLOR1} $NC CUENTAS DE USUARIOS DE INICIO DE SESIÓN MÚLTIPLE     ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Si quieres que se bloqueen 3 notificaciones, escribe 3, etc.: " -e notif
echo "$notif" > /etc/vless/notif
echo "$notif" > /etc/vmess/notif
echo "$notif" > /etc/trojan/notif
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}          ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC CAMBIANDO CON ÉXITO LA NOTIFICACIÓN DE BLOQUEO PARA $notif $NC "
echo -e "${COLOR1}│ $NC CAMBIANDO CON ÉXITO EL TIEMPO DE BLOQUEO DE NOTIF PARA $notif2 MINUTOS $NC "
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
fi
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
}
function lock-vmess(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e /etc/vmess/listlock ]; then
echo "" > /etc/vmess/listlock
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/vmess/listlock")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vmess Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún Usuario Existente Bloqueado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vmess Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el cliente existente que desea desbloquear"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/vmess/listlock" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vmess
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/vmess/listlock
m-vmess
fi
fi
done
user=$(grep -E "^### " "/etc/vmess/listlock" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/vmess/listlock" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^### " "/etc/vmess/listlock" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#vmess$/a\#vm '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\#vmg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i "/^### $user $exp $uuid/d" /etc/vmess/listlock
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VMESS DESBLOQUEADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>USUARIO   :</b> <code>$user </code>
<b>EXPIRACION:</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>Con Exito, desbloqueado este Cuenta...</i>
"
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
echo " Vmess Account Unlock Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
}
function res-user(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e /etc/vmess/akundelete ]; then
echo "" > /etc/vmess/akundelete
fi
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/vmess/akundelete")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Restore Vmess Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún usuario existente Expirado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Restore Vmess Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Select the existing client you want to Restore"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/vmess/akundelete" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vmess
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/vmess/akundelete
m-vmess
fi
fi
done
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p "EXPIRACION (DIAS): " masaaktif
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (IP) o 0 ILIMITADO: " iplim
done
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p "Limite Cuota (GB) or 0 ILIMITADO: " Quota
done
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
user=$(grep -E "^### " "/etc/vmess/akundelete" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
uuid=$(grep -E "^### " "/etc/vmess/akundelete" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#vmess$/a\#vm '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\#vmg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
echo "${iplim}" >/etc/vmess/${user}IP
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vmess/${user}
fi
sed -i "/### ${user} ${exp} ${uuid}/d" /etc/vmess/akundelete
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VMESS RESTAURACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO     :</b> <code>${domain} </code>
<b>ISP         :</b> <code>$ISP $CITY </code>
<b>USUARIO     :</b> <code>$user </code>
<b>LIMITE IP   :</b> <code>$iplim IP </code>
<b>LIMITE CUOTA:</b> <code>$Quota GB </code>
<b>EXPIRACION  :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>Cuneta Restaurada con Exito...</i>
"
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
echo " Vmess Account Restore Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " DOMINIO  : $domain"
echo " ISP      : $ISP $CITY"
echo " USUARIO  : $user"
echo " LIMITE IP: $iplim IP"
echo " EXPIRA   : $exp"
echo " Restaurado con Exito"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
}
function quota-user(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e /etc/vmess/userQuota ]; then
echo "" > /etc/vmess/userQuota
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/vmess/userQuota")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vmess Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún Usuario Existente Bloqueado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vmess Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el cliente existente que desea desbloquear"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/vmess/userQuota" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vmess
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/vmess/userQuota
m-vmess
fi
fi
done
user=$(grep -E "^### " "/etc/vmess/userQuota" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/vmess/userQuota" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^### " "/etc/vmess/userQuota" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#vmess$/a\#vm '"$user $exp"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vmessgrpc$/a\#vmg '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","alterId": '"0"',"email": "'""$user""'"' /etc/xray/config.json
sed -i "/^### $user $exp $uuid/d" /etc/vmess/userQuota
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VMESS DESBLOQUEADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>USUARIO   :</b> <code>$user </code>
<b>EXPIRACION:</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>Con Exito, Desbloqueado de Cuenta...</i>
"
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
echo " Vmess Account Unlock Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
m-vmess
}
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear	
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│${NC} ${COLBG1}                  ${WH}• VMESS PANEL MENU •            ${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}CREAR CUENTA${NC}     ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}CHECAR CONFIG USER${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}TEMPORAL CUENTA${NC}  ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}CAMBIAR LIMIT USER${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}RENOVAR CUENTA${NC}   ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}SETTING LOCK LOGIN${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}BORRAR CUENTA${NC}    ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}UNLOCK USER LOGIN${NC}  ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}CEK USER LOGIN${NC}   ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}• ${WH}UNLOCK USER CUOTA ${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}REGRESAR${NC}         ${WH}[${COLOR1}11${WH}]${NC} ${COLOR1}• ${WH}RESTAURAR CUENTA  ${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭═════════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮ ${NC}"
echo -e " ${COLOR1}${NC}               ${WH}        • $author •                 ${COLOR1} $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; add-vmess ;;
02 | 2) clear ; trial-vmess ;;
03 | 3) clear ; renew-vmess ;;
04 | 4) clear ; del-vmess ;;
05 | 5) clear ; cek-vmess ;;
06 | 6) clear ; list-vmess ;;
07 | 7) clear ; limit-vmess ;;
08 | 8) clear ; login-vmess ;;
09 | 9) clear ; lock-vmess ;;
10 | 10) clear ; quota-user ;;
11 | 11) clear ; res-user ;;
00 | 0) clear ; menu ;;
*) clear ; m-vmess ;;
esac
