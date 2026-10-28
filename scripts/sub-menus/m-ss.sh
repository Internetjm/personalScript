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
rm -rf /root/checkIP*
rm -rf /tmp/tmp.*
clear
function add-ssws(){
checking_sc
rm -rf /tmp/tmp.*
clear
domain=`cat /etc/xray/domain`
echo -e "$COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}             ${WH}• CREATE SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭════════════════════════════════════════════════════╮${NC}"
until [[ $user =~ ^[a-zA-Z0-9_]+$ && ${CLIENT_EXISTS} == '0' ]]; do
read -rp "   Ingrese Usuario : " -e user
if [ -z $user ]; then
echo -e "$COLOR1 ${NC} [Error] Usuario No Disponible "
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭══════════════════════ ${WH}BY${NC} ${COLOR1}════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
menu
fi
CLIENT_EXISTS=$(grep -w $user /etc/xray/config.json | wc -l)

if [[ ${CLIENT_EXISTS} == '1' ]]; then
clear
echo -e "$COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}             ${WH}• CREATE SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} Por Favor, Elija otro Nombre."
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭══════════════════════ ${WH}BY${NC} ${COLOR1}════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
    fi
  done
cipher="aes-128-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
read -p "   Expiracion (Dias): " masaaktif
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#ssws$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#ssgrpc$/a\#ss '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
echo $cipher:$uuid > /tmp/log
shadowsocks_base64=$(cat /tmp/log)
echo -n "${shadowsocks_base64}" | base64 > /tmp/log1
shadowsocks_base64e=$(cat /tmp/log1)
shadowsockslink="ss://${shadowsocks_base64e}@${domain}:443?path=ss-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink1="ss://${shadowsocks_base64e}@${domain}:80?path=ss-ws&security=none&host=${domain}&type=ws#${user}"
shadowsockslink2="ss://${shadowsocks_base64e}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=ss-grpc&sni=bug.com#${user}"
rm -rf /tmp/log
rm -rf /tmp/log1
if [ -d '/var/www/html/APP/ssh-$uuid.txt' ]; then
cat > /var/www/html/APP/ssh-$uuid.txt <<-END
_______________________________
Format Shadowsock Account
_______________________________
Usuario HWID       : $uuid
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
else
cat >> /var/www/html/APP/ssh-$uuid.txt <<-END
_______________________________
Format Shadowsock Account
_______________________________
Usuario HWID       : $uuid
DIAS RESTANTES     : $masaaktif
Expiracion         : $exp
_______________________________
END
fi
cat > /var/www/html/ss-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
XRAY/SHADOWSOCKS Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Port TLS     : 443
Port WS      : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port gRPC    : 443
Password     : ${uuid}
Ciphers      : ${cipher}
Network      : ws/grpc
Path         : /ss-ws
ServiceName  : ss-grpc
━━━━━━━━━━━━━━━━━━
Link TLS     : 
${shadowsockslink}
━━━━━━━━━━━━━━━━━━
Link NTLS    : 
${shadowsockslink1}
━━━━━━━━━━━━━━━━━━
Link GRPC    : 
${shadowsockslink2}
━━━━━━━━━━━━━━━━━━
Expira El    :  $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
END
TEXT="
━━━━━━━━━━━━━━━━━━
XRAY/SHADOWSOCKS Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Port TLS     : 443
Port WS      : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port gRPC    : 443
Password     : ${uuid}
Ciphers      : ${cipher}
Network      : ws/grpc
Path         : /ss-ws
ServiceName  : ss-grpc
━━━━━━━━━━━━━━━━━━
Link TLS     : 
${shadowsockslink}
━━━━━━━━━━━━━━━━━━
Link NTLS    : 
${shadowsockslink1}
━━━━━━━━━━━━━━━━━━
Link GRPC    : 
${shadowsockslink2}
━━━━━━━━━━━━━━━━━━
Expira El    :  $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
# REMOVED: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${COLBG1}           ${WH}• SSWS ACCOUNT USERS •              ${NC} $COLOR1 $NC" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Remarks      ${COLOR1}: ${WH}${user}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Domain       ${COLOR1}: ${WH}${domain}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port none TLS${COLOR1}: ${WH}80" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Password     ${COLOR1}: ${WH} ${uuid}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Ciphers      ${COLOR1}: ${WH}${cipher}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Network      ${COLOR1}: ${WH}ws/grpc" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Path         ${COLOR1}: ${WH}/ss-ws" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}ServiceName  ${COLOR1}: ${WH}ss-grpc" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link TLS     ${COLOR1}: ${WH}${shadowsockslink}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link none TLS${COLOR1}: ${WH}${shadowsockslink1}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link gRPC    ${COLOR1}: ${WH}${shadowsockslink2}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Expira El    ${COLOR1}: ${WH}$exp" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭══════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo "$COLOR1 ${NC} "
echo "" | tee -a /etc/log-create-user.log
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
}
function trial-ssws(){
checking_sc
rm -rf /tmp/tmp.*
clear
user=Trial`</dev/urandom tr -dc X-Z0-9 | head -c4`
cipher="aes-128-gcm"
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=1
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#ssws$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#ssgrpc$/a\### '"$user $exp"'\
},{"password": "'""$uuid""'","method": "'""$cipher""'","email": "'""$user""'"' /etc/xray/config.json
echo $cipher:$uuid > /tmp/log
shadowsocks_base64=$(cat /tmp/log)
echo -n "${shadowsocks_base64}" | base64 > /tmp/log1
shadowsocks_base64e=$(cat /tmp/log1)
shadowsockslink="ss://${shadowsocks_base64e}@${domain}:443?path=ss-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink2="ss://${shadowsocks_base64e}@${domain}:80?path=ss-ws&security=tls&host=${domain}&type=ws#${user}"
shadowsockslink1="ss://${shadowsocks_base64e}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=ss-grpc&sni=bug.com#${user}"
clear
TEXT="
━━━━━━━━━━━━━━━━━━
XRAY/SHADOWSOCKS Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Port TLS     : 443
Port WS      : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port gRPC    : 443
Password     : ${uuid}
Ciphers      : ${cipher}
Network      : ws/grpc
Path         : /ss-ws
ServiceName  : ss-grpc
━━━━━━━━━━━━━━━━━━
Link TLS     : 
${shadowsockslink}
━━━━━━━━━━━━━━━━━━
Link NTLS    : 
${shadowsockslink1}
━━━━━━━━━━━━━━━━━━
Link GRPC    : 
${shadowsockslink2}
━━━━━━━━━━━━━━━━━━
Expira El    :  $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
# REMOVED: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
systemctl daemon-reload
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${COLBG1}           ${WH}• TRIAL ACCOUNT SSWS •              ${NC} $COLOR1 $NC" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Remarks      ${COLOR1}: ${WH}${user}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Domain       ${COLOR1}: ${WH}${domain}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port none TLS${COLOR1}: ${WH}80" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Password     ${COLOR1}: ${WH} ${uuid}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Ciphers      ${COLOR1}: ${WH}${cipher}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Network      ${COLOR1}: ${WH}ws/grpc" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Path         ${COLOR1}: ${WH}/ss-ws" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}ServiceName  ${COLOR1}: ${WH}ss-grpc" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link TLS     ${COLOR1}: ${WH}${shadowsockslink}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link none TLS${COLOR1}: ${WH}${shadowsockslink1}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link gRPC    ${COLOR1}: ${WH}${shadowsockslink2}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Expired On   ${COLOR1}: ${WH}$exp" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭══════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo "" | tee -a /etc/log-create-user.log
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
}

function renew-ssws(){
checking_sc
rm -rf /tmp/tmp.*
clear
echo -e "$COLOR1╭════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}              ${WH}• RENEW SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭════════════════════════════════════════════════╮${NC}"
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "$COLOR1 ${NC}  • No Tienes Clientes Existentes!"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭═════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
fi
clear
echo -e "$COLOR1╭════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}              ${WH}• RENEW SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭════════════════════════════════════════════════╮${NC}"
grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq | nl
echo -e "$COLOR1 ${NC}  ${COLOR1}• ${WH}[${COLOR1}NOTE${WH}] Presione Cualquier Tecla"
echo -e "$COLOR1 ${NC}  ${WH}Para Regresar al MENU"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭═════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}"
echo -e ""
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "  Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "  Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-ss
fi
fi
done
read -p "   Expiracion (Dias): " masaaktif
exp=$(grep -E "^### $user" "/etc/xray/config.json" | cut -d ' ' -f 3 | sort | uniq)
now=$(date +%Y-%m-%d)
d1=$(date -d "$exp" +%s)
d2=$(date -d "$now" +%s)
exp2=$(( (d1 - d2) / 86400 ))
exp3=$(($exp2 + $masaaktif))
exp4=`date -d "$exp3 days" +"%Y-%m-%d"`
sed -i "/### $user/c\### $user $exp4" /etc/xray/config.json
clear
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   XRAY SHADOW RENOVACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp4 </code>
<code>━━━━━━━━━━━━━━━━━━</code>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
clear
echo -e "$COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}              ${WH}• RENEW SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭════════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}   ${WH}[${COLOR1}INFO${WH}]${NC}  ${WH}$user Account Renewed Successfully"
echo -e "$COLOR1 ${NC}   "
echo -e "$COLOR1 ${NC}   ${WH}Nombre Cliente ${COLOR1}: ${WH}$user"
echo -e "$COLOR1 ${NC}   ${WH}Dias Agregados  ${COLOR1}: ${WH}$masaaktif Dias"
echo -e "$COLOR1 ${NC}   ${WH}Expira En  ${COLOR1}: ${WH}$exp4"
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭══════════════════════ ${WH}BY${NC} ${COLOR1}════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
}

function del-ssws(){
checking_sc
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "$COLOR1╭═════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}           ${WH}• DELETE SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}  ${COLOR1}• ${WH}Tu No Tienes Clientes Existentes!${NC}"
echo -e "$COLOR1╰═════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭══════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}              ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
fi
clear
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}           ${WH}• DELETE SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | column -t | sort | uniq | nl
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}${COLOR1}• ${WH}[${COLOR1}NOTE${WH}]${NC} ${WH}Presione Cualquier Tecla${NC}"
echo -e "$COLOR1          ${WH}Para Regresar al MENU${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo ""
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "  Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "  Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-ss
fi
fi
done
user=$(grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^### " "/etc/xray/config.json" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i "/^### $user $exp/,/^},{/d" /etc/xray/config.json
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
rm /var/www/html/ss-$user.txt >/dev/null 2>&1
rm /var/www/html/APP/ssh-$user.txt >/dev/null 2>&1
clear
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY SHADOW BORRADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>USUARIO BORRADO CON EXITO...</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
systemctl daemon-reload
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}           ${WH}• DELETE SSWS USER •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}   ${COLOR1}• ${WH}Cuenta Borrada con Exito"
echo -e "$COLOR1 ${NC}   ${COLOR1}• ${WH}Nombre Cliente ${COLOR1}: ${WH}$user${NC}"
echo -e "$COLOR1 ${NC}   ${COLOR1}• ${WH}Expira En  ${COLOR1}: ${WH}$exp${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰═══════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
}

function cek-ssws(){
checking_sc
rm -rf /tmp/tmp.*
clear
echo -n > /tmp/other.txt
data=( `cat /etc/xray/config.json | grep '^###' | cut -d ' ' -f 2 | sort | uniq`);
echo -e "$COLOR1╭════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}${COLBG1}           ${WH}• SSWS USER ONLINE •             ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭════════════════════════════════════════════╮${NC}"

for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi

echo -n > /tmp/ipssws.txt
data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do

jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipssws.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipssws.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done

jum=$(cat /tmp/ipssws.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
jum2=$(cat /tmp/ipssws.txt | nl)
echo -e "$COLOR1 ${NC}   user : $akun";
echo -e "$COLOR1 ${NC}   $jum2";
TEXT="
<code>◇━━━━━━━━━━━━━━◇</code>
<b>  ⚠️ XRAY SHADOWSOCKS NOTIF ⚠️</b>
<b>         User Login</b>
<code>◇━━━━━━━━━━━━━━◇</code>
<b>DOMAIN :</b> <code>${domain} </code>
<b>ISP AND CITY :</b> <code>$ISP $CITY </code>
<b>USERNAME :</b> <code>$akun </code>
<b>TOTAL IP :</b> <code>${jum2} </code>
<code>◇━━━━━━━━━━━━━━◇</code>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
fi
rm -rf /tmp/ipssws.txt
done
rm -rf /tmp/other.txt
echo -e "$COLOR1╰════════════════════════════════════════════╯${NC}" 
echo -e "$COLOR1╭══════════════════ ${WH}BY${NC} ${COLOR1}══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                ${WH}• $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════╯${NC}"
echo "$COLOR1 ${NC} "
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
}

function list-ssws(){
checking_sc
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^###" "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "$COLOR1╭═════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}      ⇱ Check XRAY SHADOWSOCKS Config ⇲     ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════╮${NC}"
echo ""
echo "       No tienes Clientes Existentes!"
echo ""
echo -e "$COLOR1╰═════════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "  Presione Cualquier Tecla para Regresar al MENU"
m-ss
fi
clear
echo ""
echo -e "$COLOR1╭═════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}      ⇱ Check XRAY SHADOWSOCKS Config ⇲     ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═════════════════════════════════════════════╮${NC}"
echo " Seleccione el Cliente Existente para ver la Configuración."
echo " Escriba [0] Regresar al MENU"
echo -e "$COLOR1═════════════════════════════════════════════${NC}"
echo "     No  User   Expired"
grep -E "^#ss " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
echo -e "$COLOR1╰═════════════════════════════════════════════╯${NC}"
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-ss
fi
fi
done
clear
user=$(grep -E "^#ss " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^#ss " "/etc/xray/config.json" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#ss " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
cipher="aes-128-gcm"
echo $cipher:$uuid > /tmp/log
shadowsocks_base64e=$(cat /tmp/log1)
shadowsockslink="ss://${shadowsocks_base64e}@${domain}:443?path=ss-ws&security=tls&host=${domain}&type=ws&sni=${domain}#${user}"
shadowsockslink2="ss://${shadowsocks_base64e}@${domain}:80?path=ss-ws&security=tls&host=${domain}&type=ws#${user}"
shadowsockslink1="ss://${shadowsocks_base64e}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=ss-grpc&sni=bug.com#${user}"
clear
TEXT="
━━━━━━━━━━━━━━━━━━
XRAY/SHADOWSOCKS Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Port TLS     : 443
Port WS      : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port gRPC    : 443
Password     : ${uuid}
Ciphers      : ${cipher}
Network      : ws/grpc
Path         : /ss-ws
ServiceName  : ss-grpc
━━━━━━━━━━━━━━━━━━
Link TLS     : 
${shadowsockslink}
━━━━━━━━━━━━━━━━━━
Link NTLS    : 
${shadowsockslink1}
━━━━━━━━━━━━━━━━━━
Link GRPC    : 
${shadowsockslink2}
━━━━━━━━━━━━━━━━━━
Expira El    :  $exp
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
"
# REMOVED: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
clear
systemctl daemon-reload
systemctl restart xray > /dev/null 2>&1
service cron restart > /dev/null 2>&1
clear
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${COLBG1}           ${WH}• TRIAL ACCOUNT SSWS •              ${NC} $COLOR1 $NC" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Remarks      ${COLOR1}: ${WH}${user}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Domain       ${COLOR1}: ${WH}${domain}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port none TLS${COLOR1}: ${WH}80" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Password     ${COLOR1}: ${WH} ${uuid}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Ciphers      ${COLOR1}: ${WH}${cipher}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Network      ${COLOR1}: ${WH}ws/grpc" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Path         ${COLOR1}: ${WH}/ss-ws" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}ServiceName  ${COLOR1}: ${WH}ss-grpc" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link TLS     ${COLOR1}: ${WH}${shadowsockslink}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link none TLS${COLOR1}: ${WH}${shadowsockslink1}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Link gRPC    ${COLOR1}: ${WH}${shadowsockslink2}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} "
echo -e "$COLOR1╭═════════════════════════════════════════════════╮${NC}" | tee -a /etc/log-create-user.log
echo -e "$COLOR1 ${NC} ${WH}Expira El    ${COLOR1}: ${WH}$exp" | tee -a /etc/log-create-user.log
echo -e "$COLOR1╭══════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰═════════════════════════════════════════════════╯${NC}"
echo "$COLOR1 ${NC} "
echo "" | tee -a /etc/log-create-user.log
read -n 1 -s -r -p "   Presione Cualquier Tecla para Regresar al MENU"
m-ss
}
clear
author=$(cat /etc/profil)
echo -e "$COLOR1╭════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1 ${NC} ${COLBG1}              ${WH}• SSWS PANEL MENU •              ${NC} $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭════════════════════════════════════════════════╮${NC}"
echo -e "$COLOR1  $NC${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}CREAR SSWS${NC}    ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}BORRAR SSWS${NC}     $COLOR1 $NC"
echo -e "$COLOR1  $NC${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}TEMPORAL SSWS${NC} ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}USUARIOS ONLINE${NC}     $COLOR1 $NC"
echo -e "$COLOR1  $NC${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}RENOVAR SSWS${NC}  ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}CONFIG USUARIOS SSWS${NC}     $COLOR1 $NC"
echo -e "$COLOR1  $NC${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}REGRESAR${NC}"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭══════════════════════ ${WH}BY${NC} ${COLOR1}══════════════════════╮${NC}"
echo -e "$COLOR1 ${NC}                 ${WH}  • $author •${NC}                 $COLOR1 $NC"
echo -e "$COLOR1╰════════════════════════════════════════════════╯${NC}"
echo ""
echo -ne " ${WH}Select menu ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; add-ssws ;;
02 | 2) clear ; trial-ssws ;;
03 | 3) clear ; renew-ssws ;;
04 | 4) clear ; del-ssws ;;
05 | 5) clear ; cek-ssws ;;
06 | 6) clear ; list-ssws ;;
00 | 0) clear ; menu ;;
*) clear ; m-ss ;;
esac
