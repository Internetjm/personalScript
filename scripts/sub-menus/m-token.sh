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
TIMES="10"
CHATID=$(cat /etc/per/id)
KEY=$(cat /etc/per/token)
# REMOVED: URL="https://api.telegram.org/bot$KEY/sendMessage"
domain=`cat /etc/xray/domain`
patch=`cat /etc/xray/patch`
CHATID2=$(cat /etc/perlogin/id)
KEY2=$(cat /etc/perlogin/token)
# REMOVED: URL2="https://api.telegram.org/bot$KEY2/sendMessage"
cd
if [ ! -e /etc/xray/sshx/akun ]; then
mkdir -p /etc/xray/sshx/akun
fi
checking_sc() {
clear
}
#checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
if [ ! -e /etc/xray/.passw ]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════════════════╮${NC}"
echo -e " [ ${WH}INFORMACION${NC} ] PARA USAR MODO TOKEN ES NECESARIO"
echo -e " [ ${WH}INFORMACION${NC} ] INGRESAR UNA CONTRASEÑA, LA CUAL NO PODRA"
echo -e " [ ${WH}INFORMACION${NC} ] SER CAMBIADA UNA VEZ INGRESADA EN LA BD"
echo -e "${COLOR1}╰═════════════════════════════════════════════════════════════╯${NC}"
echo ""
echo -ne "[ ${Yellow}ADVERTENCIA${NC} ] ¿QUIERES AGREGAR UNA CONTRASEÑA? (s/n)";  read answer
if [ "$answer" == "${answer#[Ss]}" ] ;then
clear
menu
else
if [ ! -e /var/www/html/CheckUser ]; then
touch /var/www/html/CheckUser
#screen python3 -m http.server 8888 --directory /root/
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│  ${COLOR1}INGRESA TU CONTRASEÑA PERSONALIZADA ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo ""
read -p " CONTRASEÑA (QUE USAS EN TU APP): " Pass
echo "${Pass}" >> /etc/xray/.passw
m-token
fi
fi
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
#until [[ $name =~ ^[a-zA-Z0-9_.-]+$ ]]; do
#read -p " INGRESA NOMBRE USUARIO  (TOKEN) :" user
#done
read -p " INGRESA NOMBRE USUARIO (TOKEN): " user
#uuid=$(cat /proc/sys/kernel/random/uuid)
until [[ $uuid =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -rp " TOKEN (COPIAR DE TU APP) :" -e uuid
CLIENT_EXISTS=$(grep -w $uuid /etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} -ge '1' ]]; then
clear 
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• Add Vmess Account •          ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│${WH} TOKEN duplicado Por favor Ingresa otro TOKEN    ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder"
add-vmess
fi
done
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p " EXPIRACION (DIAS): " masaaktif
done
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p " Limite Usuario (GB) o 0 ILIMITADO: " Quota
done
if [ ! -e /etc/vmess ]; then
mkdir -p /etc/vmess
fi
iplim="2"
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
"path": "/vmess",
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
#if [[ -e /var/www/html/CheckUser ]]; then
#echo -e "$user:$exp" >> /var/www/html/CheckUser
#fi
if [ -d '/var/www/html/APP/ssh-$user.txt' ]; then
cat > /var/www/html/APP/ssh-$user.txt <<-END
_______________________________
Format Vmess Account
_______________________________
Usuario TOKEN      : $user
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
else
cat >> /var/www/html/APP/ssh-$user.txt <<-END
_______________________________
Format Vmess Account
_______________________________
Usuario TOKEN      : $user
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
fi
cat > /var/www/html/vmess-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
  Premium Vmess Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
TOKEN        : ${uuid}
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
Format OpenClash :
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
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
TOKEN        : ${uuid}
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
Format OpenClash :
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
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
TOKEN        : ${uuid}
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
Format OpenClash :
https://$domain:8888/vmess-$user.txt
━━━━━━━━━━━━━━━━━━
EXPIRA EL    : $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
fi
# REMOVED: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
user2=$(echo "$user" | cut -c 1-3)
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   CREADO EXITOSO DE VMESS </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLE  :</b> <code>CUENTA VMESS </code>
<b>USUARIO  :</b> <code>${user2} </code>
<b>TOKEN    :</b> <code>${uuid} </code>
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
echo -e "${COLOR1} ${NC} ${WH}Domain        ${COLOR1}: ${WH}${domain}" | tee -a /etc/vmess/akun/log-create-${user}.log
if [ ${Quota} = '9999' ]; then
echo -ne
else
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/trojan/akun/log-create-${user}.log
fi
echo -e "${COLOR1} ${NC} ${WH}Port TLS      ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC     ${COLOR1}: ${WH}443" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}TOKEN         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vmess/akun/log-create-${user}.log
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
echo -e "${COLOR1} ${NC} ${WH}EXPIRA En    ${COLOR1}: ${WH}$exp" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• $author •${NC}     " | tee -a /etc/vmess/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vmess/akun/log-create-${user}.log
echo "" | tee -a /etc/vmess/akun/log-create-${user}.log
read -n 1 -s -r -p "Presione cualquier tecla para retroceder al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-token
}

function add-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
#until [[ $user =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• Add Vless Account •           ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
#until [[ $name =~ ^[a-zA-Z0-9_.-]+$ ]]; do
#read -p " INGRESA NOMBRE USUARIO PARA TOKEN :" name
#done
read -p " INGRESA NOMBRE USUARIO (TOKEN): " user
#uuid=$(cat /proc/sys/kernel/random/uuid)
until [[ $uuid =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -rp " TOKEN (COPIAR DE TU APP) :" -e uuid
CLIENT_EXISTS=$(grep -w $uuid /etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} -ge '1' ]]; then
clear 
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• Add Vmess Account •          ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│${WH} TOKEN duplicado Por favor Ingresa otro TOKEN    ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder"
add-vless
fi
done
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p " EXPIRACION (DIAS): " masaaktif
done
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p " Limite Usuario (GB) o 0 ILIMITADO: " Quota
done
if [ ! -e /etc/vless ]; then
mkdir -p /etc/vless
fi
iplim="2"
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vless/${user}
fi
echo "${iplim}" >/etc/vless/${user}IP
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#vless$/a\#vl '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#vlg '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
vlesslink1="vless://${uuid}@${domain}:443?path=/vl-${patch}&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${user}"
vlesslink2="vless://${uuid}@${domain}:80?path=/vl-${patch}&security=none&encryption=none&host=${domain}&type=ws#${user}"
vlesslink3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgr-${patch}&sni=${domain}#${user}"
vless1="vless://${uuid}@${domain}:443?path=/vl-${patch}&security=tls&encryption=none&host=${domain}&type=ws&sni=${domain}#${user}"
vless2="vless://${uuid}@${domain}:80?path=/vl-${patch}&security=none&encryption=none&host=${domain}&type=ws#${user}"
vless3="vless://${uuid}@${domain}:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgr-${patch}&sni=${domain}#${user}"
echo -e "#Vless $user $exp $uuid" >> /etc/xray/token
CLIENT_EXISTS=$(grep -w $user /var/www/html/CheckUser | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
sed -i "/^$user/d" /var/www/html/CheckUser
echo -e "$user:$exp" >> /var/www/html/CheckUser
else
echo -e "$user:$exp" >> /var/www/html/CheckUser
fi
#if [[ -e /var/www/html/CheckUser ]]; then
#echo -e "$user:$exp" >> /var/www/html/CheckUser
#fi
if [ -d '/var/www/html/APP/ssh-$user.txt' ]; then
cat > /var/www/html/APP/ssh-$user.txt <<-END
_______________________________
Format Vless Account
_______________________________
Usuario TOKEN      : $user
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
else
cat >> /var/www/html/APP/ssh-$user.txt <<-END
_______________________________
Format Vless Account
_______________________________
Usuario TOKEN      : $user
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
fi 
cat > /var/www/html/vless-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
  Premium Vless Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
TOKEN        : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path vless   : /vl-${patch}
ServiceName  : /vlgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vlesslink1}
━━━━━━━━━━━━━━━━━━
Link NTLS    :
${vlesslink2}
━━━━━━━━━━━━━━━━━━
Link gRPC    :
${vlesslink3}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/vless-$user.txt
━━━━━━━━━━━━━━━━━━
Expira El    : $exp
━━━━━━━━━━━━━━━━━━
      $author
━━━━━━━━━━━━━━━━━━
END
if [ ${Quota} = '9999' ]; then
TEXT="
━━━━━━━━━━━━━━━━━━
  Premium Vless Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
TOKEN        : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path vless   : /vl-${patch}
ServiceName  : /vlgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vlesslink1}
━━━━━━━━━━━━━━━━━━
Link NTLS    :
${vlesslink2}
━━━━━━━━━━━━━━━━━━
Link gRPC    :
${vlesslink3}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/vless-$user.txt
━━━━━━━━━━━━━━━━━━
Expira El    : $exp
━━━━━━━━━━━━━━━━━━
      **$author
━━━━━━━━━━━━━━━━━━
"
else
TEXT="
━━━━━━━━━━━━━━━━━━
  Premium Vless Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
TOKEN        : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path vless   : /vl-${patch}
ServiceName  : /vlgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vlesslink1}
━━━━━━━━━━━━━━━━━━
Link NTLS    :
${vlesslink2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${vlesslink3}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/vless-$user.txt
━━━━━━━━━━━━━━━━━━
Expira El    : $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
fi
# REMOVED: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
user2=$(echo "$user" | cut -c 1-16)
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   CREACION VLESS CON EXITO </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLES :</b> <code>CUENTA VLESS </code>
<b>USUARIO  :</b> <code>$user </code>
<b>TOKEN    :</b> <code>$uuid </code>
<b>FECHA EXP :</b> <code>$exp </code>
<b>EXPIRA EN :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>NOTIFICACION DE CUENTA VLESS..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Premium Vless Account •${NC} ${COLOR1} $NC" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}User         ${COLOR1}: ${WH}${user}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Domain       ${COLOR1}: ${WH}${domain}" | tee -a /etc/vless/akun/log-create-${user}.log
if [ ${Quota} = '9999' ]; then
echo -ne
else
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/trojan/akun/log-create-${user}.log
fi
echo -e "${COLOR1} ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}TOKEN        ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Encryption   ${COLOR1}: ${WH}none" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Network      ${COLOR1}: ${WH}ws" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path         ${COLOR1}: ${WH}/vl-${patch}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path grpc    ${COLOR1}: ${WH}/vlgr-${patch}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket TLS      ${WH}:${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vlesslink1}${NC}"  | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link Websocket NTLS  ${WH}:${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vlesslink2}${NC}"  | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${COLOR1}Link gRPC               ${WH}:${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1}${NC}${WH}${vlesslink3}${NC}"  | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Format Openclash ${COLOR1}: " | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}https://$domain:8888/vless-$user.txt${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Expira El   ${COLOR1}: ${WH}$exp" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• $author •${NC}    " | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo "" | tee -a /etc/vless/akun/log-create-${user}.log
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-token
}

function add-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
#until [[ $user =~ ^[a-zA-Z0-9_.-]+$ && ${user_EXISTS} == '0' ]]; do
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}              ${WH}• Add Trojan Account •           ${NC}${COLOR1} │ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
read -p " INGRESA NOMBRE USUARIO (TOKEN): " user
#uuid=$(cat /proc/sys/kernel/random/uuid)
until [[ $uuid =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -rp " TOKEN (COPIAR DE TU APP) :" -e uuid
CLIENT_EXISTS=$(grep -w $uuid /etc/xray/config.json | wc -l)
if [[ ${CLIENT_EXISTS} -ge '1' ]]; then
clear 
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• Add Vmess Account •          ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│${WH} TOKEN duplicado Por favor Ingresa otro TOKEN    ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para retroceder"
add-vmess
fi
done
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p " EXPIRACION (DIAS): " masaaktif
done
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p " Limite Usuario (GB) o 0 ILIMITADO: " Quota
done
if [ ! -e /etc/trojan ]; then
mkdir -p /etc/trojan
fi
iplim="2"
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/trojan/${user}
fi
echo "${iplim}" >/etc/trojan/${user}IP
sed -i '/#trojanws$/a\#tr '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trgr-${patch}&sni=${domain}#${user}"
trojanlink="trojan://${uuid}@${domain}:443?path=%2Ftr-${patch}&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
trojan1="trojan://${uuid}@${domain}:443?mode=gun%26security=tls%26type=grpc%26serviceName=trgr-${patch}%26sni=${domain}#${user}"
trojan2="trojan://${uuid}@${domain}:443?path=%2Ftr-${patch}%26security=tls%26host=${domain}%26type=ws%26sni=${domain}#${user}"
echo -e "#Trojan $user $exp $uuid" >> /etc/xray/token
CLIENT_EXISTS=$(grep -w $user /var/www/html/CheckUser | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
sed -i "/^$user/d" /var/www/html/CheckUser
echo -e "$user:$exp" >> /var/www/html/CheckUser
else
echo -e "$user:$exp" >> /var/www/html/CheckUser
fi
#if [[ -e /var/www/html/CheckUser ]]; then
#echo -e "$user:$exp" >> /var/www/html/CheckUser
#fi
if [ -d '/var/www/html/APP/ssh-$user.txt' ]; then
cat > /var/www/html/APP/ssh-$user.txt <<-END
_______________________________
Format Trojan Account
_______________________________
Usuario TOKEN      : $user
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
else
cat >> /var/www/html/APP/ssh-$user.txt <<-END
_______________________________
Format Trojan Account
_______________________________
Usuario TOKEN      : $user
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
fi
cat > /var/www/html/trojan-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
Premium Trojan Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
TOKEN        : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path TLS     : /tr-${patch}
Path gRPC    : /trgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${trojan2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${trojan1}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/trojan-$user.txt
━━━━━━━━━━━━━━━━━━
Expira El    :  $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
END
if [ ${Quota} = '9999' ]; then
TEXT="
━━━━━━━━━━━━━━━━━━
Premium Trojan Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
TOKEN        : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path TLS     : /tr-${patch}
Path gRPC    : /trgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${trojan2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${trojan1}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/trojan-$user.txt
━━━━━━━━━━━━━━━━━━
Expira El    :  $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
else
TEXT="
━━━━━━━━━━━━━━━━━━
Premium Trojan Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
TOKEN        : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path TLS     : /tr-${patch}
Path gRPC    : /trgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${trojan2}
━━━━━━━━━━━━━━━━━━
Link GRPC    :
${trojan1}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/trojan-$user.txt
━━━━━━━━━━━━━━━━━━
Expira El    :  $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
fi
# REMOVED: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
#user2=$(echo "$user" | cut -c 1-16)
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>   CUENTA TROJAN CON EXITO </b>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<bFECHA       :</b> <code>${TIME2} HORA </code>
<b>DETALLES   :</b> <code>CUENTA TROJAN </code>
<b>USUARIO    :</b> <code>$user </code>
<b>TOKEN      :</b> <code>$uuid </code>
<b>FECHA EXP :</b> <code>$exp </code>
<b>DURACION :</b> <code>$masaaktif DIAS </code>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<i>Notif CUENTA CUENTA TROJAN..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Premium Trojan Account •  ${NC} ${COLOR1} $NC" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}User         ${COLOR1}: ${WH}${user}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Host         ${COLOR1}: ${WH}${domain}" | tee -a /etc/trojan/akun/log-create-${user}.log
if [ ${Quota} = '9999' ]; then
echo -ne
else
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/trojan/akun/log-create-${user}.log
fi
echo -e "${COLOR1} ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}TOKEN        ${COLOR1}: ${WH}${uuid}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path WS      ${COLOR1}: ${WH}/tr-${patch}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path gRPC    ${COLOR1}: ${WH}/trgr-${patch}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Link TLS     ${COLOR1}: " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}${trojanlink}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Link gRPC    ${COLOR1}: " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}${trojanlink1}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Format Openclash ${COLOR1}: " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}https://$domain:8888/trojan-$user.txt${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Expira El    ${COLOR1}: ${WH}$exp" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• $author •${NC}     " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo "" | tee -a /etc/trojan/akun/log-create-${user}.log
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-token
}

function cek-v2(){
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
clear
data=( `cat /etc/xray/config.json | grep -E "^#vmg|^#vl|^#tr" | cut -d ' ' -f 2 | sort | uniq`);
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}            ${WH}• V2RAY USER ONLINE •              ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/ipvmess.txt
data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
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
if [ -d '/etc/vmess/${akun}IP' ]; then
iplimit=$(cat /etc/vmess/${akun}IP)
elif [ -d '/etc/vless/${akun}IP' ]; then
iplimit=$(cat /etc/vless/${akun}IP)
elif [ -d '/etc/trojan/${akun}IP' ]; then
iplimit=$(cat /etc/trojan/${akun}IP)
fi

jum2=$(cat /tmp/ipvmess.txt | wc -l)

if [ -d '/etc/vmess/${akun}' ]; then
byte=$(cat /etc/vmess/${akun})
elif [ -d '/etc/vless/${akun}' ]; then
byte=$(cat /etc/vless/${akun})
elif [ -d '/etc/trojan/${akun}' ]; then
byte=$(cat /etc/trojan/${akun})
fi
lim=$(con ${byte})
if [ -d '/etc/limit/vmess/${akun}' ]; then
wey=$(cat /etc/limit/vmess/${akun})
elif [ -d '/etc/limit/vless/${akun}' ]; then
wey=$(cat /etc/limit/vless/${akun})
elif [ -d 'cat /etc/limit/trojan/${akun}' ]; then
wey=$(cat /etc/limit/trojan/${akun})
fi
gb=$(con ${wey})
lastlogin=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 4 | tail -1)
echo -e "${COLOR1}═════════════════════════════════════════════════${NC}"
printf "  %-13s %-7s %-8s %2s\n" "  Usuario : ${akun}"
printf "  %-13s %-7s %-8s %2s\n" "  Login    : $lastlogin"
printf "  %-13s %-7s %-8s %2s\n" "  Usado Cuota : ${gb}" 
printf "  %-13s %-7s %-8s %2s\n" "  Limite Cuota : ${lim}" 
printf "  %-13s %-7s %-8s %2s\n" "  Login IP : $jum2" 
echo -e "${COLOR1}═════════════════════════════════════════════════${NC}"
fi 
rm -rf /tmp/ipvless.txt
done
rm -rf /tmp/other.txt
echo ""
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione cualquier tecla para retroceder al MENU"
m-token
}

function usernew(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
sldomain=`cat /etc/xray/dns`
slkey=`cat /etc/slowdns/server.pub`
clear
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}             ${WH}• TOKEN PANEL MENU •              ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
read -p "  INGRESA NOMBRE USUARIO PARA TOKEN: " User
until [[ $Login =~ ^[a-zA-Z0-9_.-]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -p "  INGRESA EL TOKEN : " Login
CLIENT_EXISTS=$(grep -w $Login /etc/xray/token | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}              ${WH}• SSH PANEL MENU •               ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│${WH}    TOKEN duplicado Por favor cree otro nombre.  ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "  Presione Cualquier Tecla para Regresar"
usernew
fi
done
Pass=$(cat /etc/xray/.passw)
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p "  Expiracion (DIAS): " masaaktif
done
if [ ! -e /etc/xray/sshx ]; then
mkdir -p /etc/xray/sshx
fi
iplim=2
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
echo -e "### $Login $expi $Pass $User" >> /etc/xray/token
CLIENT_EXISTS=$(grep -w $Login /var/www/html/CheckUser | wc -l)
if [[ ${CLIENT_EXISTS} == '1' ]]; then
sed -i "/^$Login/d" /var/www/html/CheckUser
echo -e "$Login:$expi" >> /var/www/html/CheckUser
else
echo -e "$Login:$expi" >> /var/www/html/CheckUser
fi
#if [[ -e /var/www/html/CheckUser ]]; then
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
cat > /var/www/html/APP/ssh-$Login.txt <<-END
_______________________________
Format SSH OVPN Account
_______________________________
TOKEN           : $Login
Usuario         : $User
Creado El       : $(date "+%D %I:%M%p")
Vencimiento     : $expi
_______________________________
END
cat > /var/www/html/sshx-$Login.txt <<-END
_______________________________
Format SSH OVPN Account
_______________________________
Username         : $Login
Password         : $Pass
Expired          : $exp
_______________________________
Host             : $domain
CITY             : $CITY
Login Limit      : ${iplim} IP
Port OpenSSH     : 22
Port Dropbear    : 143, 109
Port SSH WS      : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port SSH SSL WS  : 443
Port SSL/TLS     : 443
Port OVPN SSL    : 443
Port OVPN TCP    : 1194
Port OVPN UDP    : 2200,
BadVPN UDP       : 7100, 7300, 7300
_______________________________
Port Slowdns     : Todos los Puertos
Host Slowdns     : $sldomain
Pub Key          : $slkey
Domain DNS       :  1.1.1.1 / 8.8.8.8
SSH SlowDNS      : $sldomain:53@$Login:$Pass
_______________________________
SSH UDP ZIVPN    : $domain:1-19999
USUARIO & PW     : $Login:$Pass
_______________________________
DOM UDP HYSTERIA : $domain
USUARIO HYSTERIA : $Login:$Pass
OBFS HYSTERIA    : $OBFS
_______________________________
SSH UDP CUSTOM   : $domain:40000-65535@$Login:$Pass
_______________________________
SSH WS           : $domain:80@$Login:$Pass
SHH WS + SSL     : $domain:443@$Login:$Pass
SHH SSL          : $domain:443@$Login:$Pass
_______________________________
Payload WS/WSS   :
GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]
_______________________________
OpenVPN SSL      : https://$domain:8888/ssl.ovpn
OpenVPN TCP      : https://$domain:8888/tcp.ovpn
OpenVPN UDP      : https://$domain:8888/udp.ovpn
_______________________________
END
if [[ -e /etc/cloudfront ]]; then
TEXT="
━━━━━━━━━━━━━━━━━━
  SSH Premium Account
━━━━━━━━━━━━━━━━━━
TOKEN           :  $Login
Usuario         :  $User
Expira El       :  $exp
━━━━━━━━━━━━━━━━━━
Host             :  $domain
Port OpenSSH     :  22
Port Dropbear    :  109, 143
Port SSH WS      :  80,8080,8088,8280,8880,2052,2082,2086,2095
Port SSH SSL WS  :  443
Port SSL/TLS     :  443
Port OVPN SSL    :  443
BadVPN UDP       :  7100, 7300, 7300
━━━━━━━━━━━━━━━━━━
Host Slowdns     :  $sldomain
Domain DNS       :  1.1.1.1 / 8.8.8.8
Pub Key          :   $slkey
━━━━━━━━━━━━━━━━━━
Save Link Account: https://$domain:8888/sshx-$Login.txt
LINK CHECKUSER SBG: https://$domain:8888/CheckUser
━━━━━━━━━━━━━━━━━━
                  $author
━━━━━━━━━━━━━━━━━━
"
else
TEXT="
━━━━━━━━━━━━━━━━━━
  SSH Premium Account
━━━━━━━━━━━━━━━━━━
TOKEN           :  $Login
Usuario         :  $User
Expira El       :  $expi
━━━━━━━━━━━━━━━━━━
Host             :  $domain
Port OpenSSH     :  22
Port Dropbear    :  109, 143
Port SSH WS      :  80,8080,8088,8280,8880,2052,2082,2086,2095
Port SSH SSL WS  :  443
Port SSL/TLS     :  443
Port OVPN SSL    :  443
BadVPN UDP       :  7100, 7300, 7300
━━━━━━━━━━━━━━━━━━
Host Slowdns     :  $sldomain
Domain DNS       :  1.1.1.1 / 8.8.8.8
Pub Key          :   $slkey
━━━━━━━━━━━━━━━━━━
Save Link Account: https://$domain:8888/sshx-$Login.txt
LINK CHECKUSER SBG: https://$domain:8888/CheckUser
━━━━━━━━━━━━━━━━━━
                  $author
━━━━━━━━━━━━━━━━━━
"
fi
# REMOVED: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
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
<b>DETALLE  :</b> <code>SSH </code>
<b>TOKEN    :</b> <code>$Login</code>
<b>USUARIO  :</b> <code>${User}</code>
<b>DURACION :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>NOTIFICACION CUENTA SSH..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC} ${WH}• SSH Premium Account  • " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Token      ${COLOR1}: ${WH}$Login"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Usuario    ${COLOR1}: ${WH}$User"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Expira El  ${COLOR1}: ${WH}$expi"  | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}OpenSSH    ${COLOR1}: ${WH}22" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Dropbear   ${COLOR1}: ${WH}109, 143" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH-WS     ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSH-SSL-WS ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}SSL/TLS    ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port TCP   ${COLOR1}: ${WH}1194" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}Port SSL   ${COLOR1}: ${WH}443" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}UDPGW      ${COLOR1}: ${WH}7100-7300" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}DOMINIO DNS${COLOR1}: ${WH}1.1.1.1 / 8.8.8.8" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}NAMESERVER ${COLOR1}: ${WH}$sldomain" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} $NC  ${WH}PUB KEY    ${COLOR1}: ${WH}$slkey" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}Save Link Acount    : " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}https://$domain:8888/sshx-$Login.txt${NC}${COLOR1} $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}Link CHECK USER SBG : " | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}  ${WH}https://$domain:8888/CheckUser${NC}${COLOR1} $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ${NC}    ${WH}• $author •${NC}                 ${COLOR1} $NC" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
echo "" | tee -a /etc/xray/sshx/akun/log-create-${Login}.log
read -n 1 -s -r -p "PRESIONE CUALQUIER TECLA PARA REGRESAR AL MENU"
m-token
}

function renew(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#" "/etc/xray/token")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}            ${WH}• RENOVAR TOKEN •                   ${NC}${COLOR1}│$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│               ${WH}El TOKEN no Existe!               ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU" 
m-token
fi 
echo -e "${COLOR1}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                 ${WH}• RENOVAR TOKEN •               ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ ${WH}Por favor Seleccione el TOKEN que desea Renovar  ${COLOR1} │"
echo -e "${COLOR1}│ ${WH}Escriba [0] Regresar al MENU                     ${COLOR1} │"
echo -e "${COLOR1}╰═══════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}|${WH}         Token      | Expiracion | Usuario        ${COLOR1} │"
grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 2-3,5 | nl -s ') '
echo -e "${COLOR1}╰═══════════════════════════════════════════════════╯${NC}"
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-token
fi
fi
done
User=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
Pass=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
Name=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 5 | sed -n "${CLIENT_NUMBER}"p)
egrep "^$User" /etc/passwd >/dev/null
if [ $? -eq 0 ]; then
read -p "  Agregar Dias Vencimiento : " Days
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
sed -i "s/### $User $exp/### $User $exp4/g" /etc/xray/token >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/sshx-$User.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$User.txt >/dev/null
#if [[ -e /var/www/html/CheckUser ]]; then
sed -i "s/$User:$exp/$User:$exp4/g" /var/www/html/CheckUser
#fi
##########################################################################################################
user=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#vmg " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/^#vm $user $exp/#vm $user $exp4/g" /etc/xray/config.json
sed -i "s/^#vmg $user $exp/#vmg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/vmess-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token
##########################################################################################################
user=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/^#vl $user $exp/#vl $user $exp4/g" /etc/xray/config.json
sed -i "s/^#vlg $user $exp/#vlg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/vless-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token
##########################################################################################################
user=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/^#tr $user $exp/#tr $user $exp4/g" /etc/xray/config.json
sed -i "s/^#trg $user $exp/#trg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/trojan-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token >/dev/null
##########################################################################################################
clear
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  SSH RENOVACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>FECHA      :</b> <code>${TIME2} HORA </code>
<b>DETALLES   :</b> <code>CUENTA TOKEN </code>
<b>TOKEN   :</b> <code>$User </code>
<b>EXPIRA    :</b> <code>$exp4 </code>
<b>AGREGARON :</b> <code>$Days DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
"
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
<b>FECHA     :</b> <code>${TIME2} HORA</code>
<b>DETALLE   :</b> <code>RENEW SSH </code>
<b>USUARIO   :</b> <code>$Name</code>
<b>TOKEN     :</b> <code>$User</code>
<b>DURACION  :</b> <code>$Days DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>RENOVACION DE CUENTA..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}             ${WH}• RENOVACION DE TOKEN •            ${NC}${COLOR1}│$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│"
echo -e "${COLOR1}│ ${WH}USUARIO    : $Name"
echo -e "${COLOR1}│ ${WH}TOKEN      : $User"  
echo -e "${COLOR1}│ ${WH}Dias Added : $Days Days"
echo -e "${COLOR1}│ ${WH}Expira En  : $exp4"
echo -e "${COLOR1}│"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
fi
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-token
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
m-token
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
m-token
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
sed -i "s/^#vm $user $exp/#vm $user $exp4/g" /etc/xray/config.json
sed -i "s/^#vmg $user $exp/#vmg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/vmess-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user:$exp/$user:$exp4/g" /var/www/html/CheckUser
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token
clear
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   XRAY VMESS RENOVACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMAIN    :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLES :</b> <code>CUENTA VMESS </code>
<b>USERNAME  :</b> <code>$user </code>
<b>EXPIRACION:</b> <code>$exp4 </code>
<b>AGREGARON :</b> <code>$masaaktif DIAS </code>
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
m-token
}
function renew-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vl " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Renew Vless Account ⇲      ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-token
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}     ${WH}⇱ Renew Vless Account ⇲      ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que Desea Renovar"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-token
fi
fi
done
read -p "EXPIRACION (DIAS): " masaaktif
user=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/^#vl $user $exp/#vl $user $exp4/g" /etc/xray/config.json
sed -i "s/^#vlg $user $exp/#vlg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/vless-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user:$exp/$user:$exp4/g" /var/www/html/CheckUser
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token
clear
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   RENOVADO VLESS CON EXITO </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLES :</b> <code>CUENTA VLESS </code>
<b>USUARIO  :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp4 </code>
<b>AGREGARON :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>RENOVACION DE CUENTA VLESS..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   RENOVADO VLESS CON EXITO </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLES :</b> <code>CUENTA VLESS </code>
<b>USUARIO  :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp4 </code>
<b>AGREGARON :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>RENOVACION DE CUENTA VLESS..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " VLESS Account Was Successfully Renewed"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Expira El   : $exp4"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-token
}
function renew-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#tr " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Renew Trojan Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-token
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Renew Trojan Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que Desea Renovar"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-token
fi
fi
done
read -p "EXPIRACION (DIAS): " masaaktif
user=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "s/^#tr $user $exp/#tr $user $exp4/g" /etc/xray/config.json
sed -i "s/^#trg $user $exp/#trg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/trojan-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user:$exp/$user:$exp4/g" /var/www/html/CheckUser
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token
clear
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   XRAY TROJAN RENOVACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>DETALLE    :</b> <code>CUENTA TROJAN </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp4 </code>
<b>AGREGARON  :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Trojan Account Was Successfully Renewed"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Expira El   : $exp4"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-token
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
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/token")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}           ${WH}• CONFIGURACION DE TOKEN •          ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│               ${WH}El TOKEN no Existe!               ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-token
fi
echo -e "${COLOR1}╭═════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}              ${WH}• CONFIGURACION DE TOKEN •            ${NC}${COLOR1}│$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ ${WH}Por favor seleccione el TOKEN que desea Verificar.  ${COLOR1}│"
echo -e "${COLOR1}│ ${WH}Escriba [0] Regresar al MENU                        ${COLOR1}│"
echo -e "${COLOR1}╰═════════════════════════════════════════════════════╯${NC}"
grep -E "^### " "/etc/xray/token" | cut -d ' ' -f 2-3,5 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-token
fi
fi
done
Login=$(grep -E "^### " "/etc/xray/token" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
cat /etc/xray/sshx/akun/log-create-${Login}.log
read -n 1 -s -r -p "   Presione cualquier tecla para volver al MENU"
menu
}
function hapus(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#" "/etc/xray/token")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                ${WH}• BORRAR TOKEN •               ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}│               ${WH}El TOKEN no Existe!               ${COLOR1}│"
echo -e "${COLOR1}│                                                 │"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-token
fi
echo -e "${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}                  ${WH}• BORRAR TOKEN •                ${NC}${COLOR1} │$NC"
echo -e "${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ ${WH}Por favor seleccione el TOKEN que desea Eliminar.  ${COLOR1}│"
echo -e "${COLOR1}│ ${WH}Escriba [0] Regresar al MENU                       ${COLOR1}│"
echo -e "${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 2-3,5 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-token
fi
fi
done
Pengguna=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
Days=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
Pass=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
Name=$(grep -E "^#" "/etc/xray/token" | cut -d ' ' -f 5 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^# $Pengguna $Days $Pass $Name/d" /etc/xray/token
sed -i "/$Pengguna/d" /etc/xray/token
#if [[ -e /var/www/html/CheckUser ]]; then
sed -i "/^$Pengguna:$Days/d" /var/www/html/CheckUser
#fi
####################################################################################
sed -i "/^#vmg $Pengguna $Days/,/^},{/d" /etc/xray/config.json
sed -i "/^#vm $Pengguna $Days/,/^},{/d" /etc/xray/config.json
sed -i "/^#vl $Pengguna $Days/,/^},{/d" /etc/xray/config.json
sed -i "/^#vlg $Pengguna $Days/,/^},{/d" /etc/xray/config.json
sed -i "/^#tr $Pengguna $Days/,/^},{/d" /etc/xray/config.json
sed -i "/^#trg $Pengguna $Days/,/^},{/d" /etc/xray/config.json
sed -i "/^## $Pengguna $Days/,/^},{/d" /etc/xray/config.json
####################################################################################
if [[ -e /root/UDPMOD/config.json ]]; then
CONFIG_FILE="/root/UDPMOD/config.json"
sed -i "s/,\"$Pengguna:$Pass\"//" "$CONFIG_FILE"  >/dev/null
sudo systemctl daemon-reload
sudo systemctl restart udpmod
fi
if [[ -e /etc/zivpn/config.json ]]; then
CONFIG_FILE="/etc/zivpn/config.json"
sed -i "s/,\"$Pengguna:$Pass\"//" "$CONFIG_FILE"  >/dev/null
#sed -i "s/,\"$Pengguna:$Days\"/\"$Pengguna:$Pass\"/; s/\"$Pengguna:$Pass\",//; s/\"$Pengguna:$Pass\"//" "$CONFIG_FILE" >/dev/null
sudo systemctl daemon-reload
sudo systemctl restart zivpn
fi
####################################################################################
rm /var/www/html/sshx-$Pengguna.txt >/dev/null 2>&1
rm /var/www/html/APP/ssh-$Pengguna.txt >/dev/null 2>&1
rm /var/www/html/vmess-$Pengguna.txt >/dev/null 2>&1
rm /var/www/html/vless-$Pengguna.txtt >/dev/null 2>&1
rm /var/www/html/trojan-$Pengguna.txt >/dev/null 2>&1
rm /etc/xray/sshx/${Pengguna}IP >/dev/null 2>&1
rm /etc/xray/sshx/${Pengguna}login >/dev/null 2>&1
#rm /etc/xray/sshx/akun/log-create-${Pengguna}.log >/dev/null 2>&1
grep -rl "log-create-${Pengguna}.log" /etc/xray/sshx/akun/ | xargs rm -f
grep -rl "trialssh" /etc/cron.d | xargs rm -f 
#if getent passwd $Pengguna > /dev/null 2>&1; then
userdel $Pengguna > /dev/null 2>&1
echo -e "TOKEN $Pengguna fue Eliminado."
#else
#echo -e "Falla: TOKEN $Pengguna No Existe."
#fi
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  CUENTA TOKEN BORRADA</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>USUARIO   :</b> <code>$Name </code>
<b>TOKEN     :</b> <code>$Pengguna </code>
<b>EXPIRA    :</b> <code>$Days </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>BORRADO DE CUENTA...</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
cd
if [ ! -e /etc/tele ]; then
echo -ne
else
echo "$TEXT" > /etc/notiftele
bash /etc/tele
fi
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-token
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
#ID=`cat /tmp/log-db-pid.txt | awk '{print $5}' | sed 's/[^0-9]//g'`;
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
#m-token
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
echo -e "${Yellow} SESION CERRADA CORRECTAMENTE By JERRY"
echo -e "${Yellow} REGRESANDO AL MENU"
sleep 1
systemctl daemon-reload
m-token
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
echo -e "${Yellow} SESIONES CERRADAS CORRECTAMENTE By JERRY"
echo -e "${Yellow} REGRESANDO AL MENU"
sleep 1
systemctl daemon-reload
m-token
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
echo -e "${yell}  FIX APLICADO CORRECTAMENTE By JERRY"
echo -e "${yell}  ESPERA UNOS SEGUNDOS PARA VER LOS USUARIOS"
sleep 1
m-token
else
m-token
fi
}
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│${NC} ${COLBG1}                ${WH}• TOKEN PANEL MENU •              ${NC}${COLOR1} │$NC"
if [[ -e /var/www/html/CheckUser ]]; then
echo -e " ${COLOR1}│${NC} ${COLBG1}                 ${WH}• LINK CHECKUSER •               ${NC}${COLOR1} │$NC"
echo -e " ${COLOR1}│${NC} ${COLBG1}    ${WH}• https://$domain:8888/CheckUser •  ${NC}${COLOR1}"
fi
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}CREAR TOKEN ${NC}    ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}SSH TOKEN ONLINE${NC}   ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}RENOVAR TOKEN ${NC}  ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}SSH CONFIG TOKEN${NC}   ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}TOKEN VMESS${NC}     ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}TOKEN VLESS${NC}        ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}TOKEN TROJAN${NC}    ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}• ${WH}V2R TOKEN ONLINE${NC}   ${COLOR1}│ $NC"
echo -e " ${COLOR1}│          $NC  ${NC} ${COLOR1}• ${WH}RENOVACION TOKEN V2RAY ${NC}              ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}RENEW VMESS${NC}     ${WH}[${COLOR1}11${WH}]${NC} ${COLOR1}• ${WH}RENEW VLESS${NC}        ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}RENEW TROJAN${NC}    ${WH}[${COLOR1}12${WH}]${NC} ${COLOR1}• ${WH}BORRAR TOKEN${NC}       ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC  ${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}REGRESAR ${NC}                                 ${COLOR1}│ $NC"
#echo -e " ${COLOR1}│     $NC  ${NC} ${COLOR1}• ${WH}RENOVACION TOKEN V2RAY EN SU MENU${NC}         ${COLOR1}│ $NC"
#echo -e " ${COLOR1}│       $NC  ${NC} ${COLOR1}• ${WH}BORRAR TOKEN V2RAY EN SU MENU${NC}           ${COLOR1}│ $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭═════════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮ ${NC}"
echo -e " ${COLOR1}${NC}               ${WH}        • $author •                 ${COLOR1} $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; usernew ;;
02 | 2) clear ; renew ;;
03 | 3) clear ; add-vmess ;;
04 | 4) clear ; add-tr ;;
05 | 5) clear ; renew-vmess ;;
06 | 6) clear ; renew-tr ;;
07 | 7) clear ; cek ;;
08 | 8) clear ; cekconfig ;;
09 | 9) clear ; add-vless ;;
10 | 10) clear ; cek-v2 ;;
11 | 11) clear ; renew-vless ;;
12 | 12) clear ; hapus ;;
#10 | 10) clear ; hapuslama ; exit ;;
00 | 0) clear ; menu ; exit ;;
X  | 0) clear ; m-token ;;
x) exit ;;
*) echo "Lo presionaste mal " ; sleep 1 ; m-token ;;
esac
