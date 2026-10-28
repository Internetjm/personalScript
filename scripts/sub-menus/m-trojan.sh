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
# REMOVED SBG CALL: URL="https://api.telegram.org/bot$KEY/sendMessage"
domain=`cat /etc/xray/domain`
patch=`cat /etc/xray/patch`
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
if [ ! -e /etc/trojan/akun ]; then
mkdir -p /etc/trojan/akun
fi
function add-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}              ${WH}• Add Trojan Account •           ${NC}${COLOR1} │ $NC"
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
add-tr
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
if [ ! -e /etc/trojan ]; then
mkdir -p /etc/trojan
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
cat > /var/www/html/trojan-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
Premium Trojan Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
UUID         : ${uuid}
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
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
UUID         : ${uuid}
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
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
UUID         : ${uuid}
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
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
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
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>   CUENTA TROJAN CON EXITO </b>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>CIUDAD     :</b> <code>$CITY </code>
<bFECHA       :</b> <code>${TIME2} HORA </code>
<b>DETALLES   :</b> <code>CUENTA TROJAN </code>
<b>USUARIO    :</b> <code>$user </code>
<b>IP         :</b> <code>${iplim} IP </code>
<b>FECHA EXP :</b> <code>$exp </code>
<b>EXPIRA EN :</b> <code>$masaaktif DIAS </code>
<code>◇━━━━━━━━━━━━━━━━━━━◇</code>
<i>Notif CUENTA CUENTA TROJAN..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Premium Trojan Account •  ${NC} ${COLOR1} $NC" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}User         ${COLOR1}: ${WH}${user}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ISP          ${COLOR1}: ${WH}$$ISP" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}City         ${COLOR1}: ${WH}$$CITY" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Host         ${COLOR1}: ${WH}${domain}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/trojan/akun/log-create-${user}.log
#if [ ${Quota} = '9999' ]; then
#echo -ne
#else
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/trojan/akun/log-create-${user}.log
#fi
echo -e "${COLOR1} ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Key          ${COLOR1}: ${WH}${uuid}" | tee -a /etc/trojan/akun/log-create-${user}.log
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
m-trojan
}
function trial-trojan(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC}${COLBG1}            ${WH}• Trial Trojan Account •             ${NC}${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e ""
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "EXPIRACION (MINUTOS): " timer
done
user=Trial-`</dev/urandom tr -dc X-Z-0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=0
iplim=1
Quota=10
if [ ! -e /etc/trojan ]; then
mkdir -p /etc/trojan
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/trojan/${user}
fi
echo "${iplim}" > /etc/trojan/${user}IP
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
sed -i '/#trojanws$/a\#tr '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
trojanlink1="trojan://${uuid}@${domain}:443?mode=gun&security=tls&type=grpc&serviceName=trgr-${patch}&sni=bug.com#${user}"
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
cat> /etc/cron.d/trialtrojan${user} << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root bash /usr/local/sbin/trial
END
cat > /var/www/html/trojan-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
Trial Premium Trojan Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Login Limit  : ${iplim} IP
Login Cuota  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path WS      : /tr-${patch}
Path GRPC    : /trgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${trojan2}
━━━━━━━━━━━━━━━━━━
Link gRPC    :
${trojan1}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/trojan-$user.txt
━━━━━━━━━━━━━━━━━━
Expira En    :  $timer Minutes
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
END
TEXT="
━━━━━━━━━━━━━━━━━━
Trial Premium Trojan Account
━━━━━━━━━━━━━━━━━━
USUARIO      : ${user}
DOMINIO      : ${domain}
Login Limit  : ${iplim} IP
Login Cuota  : ${Quota} GB
Port TLS     : 443
Port gRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path WS      : /tr-${patch}
Path GRPC    : /trgr-${patch}
━━━━━━━━━━━━━━━━━━
Link TLS     :
${trojan2}
━━━━━━━━━━━━━━━━━━
Link gRPC    :
${trojan1}
━━━━━━━━━━━━━━━━━━
Format OpenClash :
https://$domain:8888/trojan-$user.txt
━━━━━━━━━━━━━━━━━━
Expira En    :  $timer Minutes
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
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
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Trial Premium Trojan Account •  ${NC} ${COLOR1} $NC" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}USUARIO      ${COLOR1}: ${WH}${user}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ISP          ${COLOR1}: ${WH}$ISP" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}City         ${COLOR1}: ${WH}$CITY" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Host         ${COLOR1}: ${WH}${domain}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}UUID         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Path TLS     ${COLOR1}: ${WH}/tr-${patch}" | tee -a /etc/trojan/akun/log-create-${user}.log
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
echo -e "${COLOR1} ${NC} ${WH}Expira En    ${COLOR1}: ${WH}$timer Minutes" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• $author •${NC}     " | tee -a /etc/trojan/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/trojan/akun/log-create-${user}.log
echo "" | tee -a /etc/trojan/akun/log-create-${user}.log
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-trojan
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
m-trojan
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
m-trojan
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
sed -i "s/#tr $user $exp/#tr $user $exp4/g" /etc/xray/config.json
sed -i "s/#trg $user $exp/#trg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/trojan-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user:$exp/$user:$exp4/g" /var/www/html/CheckUser >/dev/null
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token >/dev/null
clear
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   XRAY TROJAN RENOVACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp4 </code>
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
user2=$(echo "$user" | cut -c 1-3)
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>◇━━━━━━━━━━━━━━━━◇</code>
<b>   RENOVACION TROJAN CON EXITO </b>
<code>◇━━━━━━━━━━━━━━━━◇</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>FECHA      :</b> <code>${TIME2} HORA </code>
<b>DETALLE    :</b> <code>CUENTA TROJAN </code>
<b>USUARIO    :</b> <code>$user2 </code>
<b>FECHA EXP :</b> <code>$exp </code>
<b>EXPIRA EN :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i> CUENTA TROJAN RENOVADA..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
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
m-trojan
}
function limit-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#tr " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Limit Trojan Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Limit Trojan Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
echo " Seleccione el Cliente Existente del cual Desea Cambiar la IP"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-trojan
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
if [ ! -e /etc/trojan ]; then
mkdir -p /etc/trojan
fi
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
user=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
echo "${iplim}" >/etc/trojan/${user}IP
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/trojan/${user}
fi
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY TROJAN LIMITE IP</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>USUARIO   :</b> <code>$user </code>
<b>IP LIMIT NEW :</b> <code>$iplim IP </code>
<b>CUOTA LIMIT NEW :</b> <code>$Quota GB </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>LIMITE IP CAMBIADO CON EXITO...</i>
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
echo " TROJAN Account Was Successfully Change Limit IP"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Limit IP    : $iplim IP"
echo " Limit Cuota : $Quota GB"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
}
function del-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#tr " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Delete Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Delete Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Usuario que Desea Eliminar"
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
m-trojan
fi
fi
done
user=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
if [ ! -e /etc/trojan/akundelete ]; then
echo "" > /etc/trojan/akundelete
fi
clear
echo "### $user $exp $uuid" >> /etc/trojan/akundelete
sed -i "/^#tr $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#trg $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#Trojan $uuid $exp $user/,/^},{/d" /etc/xray/token
clear
rm /var/www/html/trojan-$user.txt >/dev/null 2>&1
rm /var/www/html/APP/ssh-$user.txt >/dev/null 2>&1
rm  /etc/trojan/${user} >/dev/null 2>&1
rm  /etc/trojan/${user}IP >/dev/null 2>&1
rm /etc/trojan/${user}login >/dev/null 2>&1
rm /etc/trojan/akun/log-create-${user}.log >/dev/null 2>&1
grep -rl "${user}" /etc/trojan/akun/ | xargs rm -f 
clear
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY TROJAN BORRADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>USUARIO BORRADO CON EXITO...</i>
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
echo " Trojan Account Deleted Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Expira El   : $exp"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-trojan
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
function convert() {
local -i bytes=$1
if [[ $bytes -lt 1024 ]]; then
echo "${bytes} B"
elif [[ $bytes -lt 1048576 ]]; then
echo "$(((bytes + 1023) / 1024)) KB"
elif [[ $bytes -lt 1073741824 ]]; then
echo "$(((bytes + 1048575) / 1048576)) MB"
else
echo "$(((bytes + 1073741823) / 1073741824)) GB"
fi
}
function cek-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
xrayy=$(cat /var/log/xray/access.log | wc -l)
if [[ xrayy -le 5 ]]; then
systemctl restart xray
fi
xraylimit
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC}${COLBG1}             ${WH}• TROJAN USER ONLINE •              ${NC}${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
vm=($(cat /etc/xray/config.json | grep "^#trg" | awk '{print $2}' | sort -u))
echo -n >/tmp/vm
for db1 in ${vm[@]}; do
logvm=$(cat /var/log/xray/access.log | grep -w "email: ${db1}" | tail -n 100)
while read a; do
if [[ -n ${a} ]]; then
set -- ${a}
ina="${7}"
inu="${2}"
anu="${3}"
enu=$(echo "${anu}" | sed 's/tcp://g' | sed '/^$/d' | cut -d. -f1,2,3)
now=$(tim2sec ${timenow})
client=$(tim2sec ${inu})
nowt=$(((${now} - ${client})))
if [[ ${nowt} -lt 40 ]]; then
cat /tmp/vm | grep -w "${ina}" | grep -w "${enu}" >/dev/null
if [[ $? -eq 1 ]]; then
echo "${ina} ${inu} WIB : ${enu}" >>/tmp/vm
splvm=$(cat /tmp/vm)
fi
fi
fi
done <<<"${logvm}"
done
if [[ ${splvm} != "" ]]; then
for vmuser in ${vm[@]}; do
vmhas=$(cat /tmp/vm | grep -w "${vmuser}" | wc -l)
tess=0
if [[ ${vmhas} -gt $tess ]]; then
if [ -d '/etc/limit/trojan/${vmuser}' ]; then
byt=$(cat /etc/limit/trojan/${vmuser})
fi
gb=$(convert ${byt})
lim=$(cat /etc/trojan/${vmuser})
lim2=$(convert ${lim})
echo -e "   ${COLOR1}${NC} USUARIO  : \033[0;33m$vmuser"
echo -e "   ${COLOR1}${NC} IP LOGIN : \033[0;33m$vmhas"
echo -e "   ${COLOR1}${NC} USADO    : \033[0;33m$gb"
echo -e "   ${COLOR1}${NC} LIMITE   : \033[0;33m$lim2"
fi
done
fi
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "   Presione cualquier tecla para volver al MENU"
m-trojan
}
function list-trojan(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#tr " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Config Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Config Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente para ver la Configuración."
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
m-trojan
fi
fi
done
user=$(grep -E "^#tr " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
clear
cat /etc/trojan/akun/log-create-${user}.log
cat /etc/trojan/akun/log-create-${user}.log > /etc/NotifCuenta
sed -i 's/\x1B\[1;37m//g' /etc/NotifCuenta
sed -i 's/\x1B\[1;96m//g' /etc/NotifCuenta
sed -i 's/\x1B\[0m//g' /etc/NotifCuenta
#cat /etc/NotifCuenta > /root/trojan-${user}
#cd /root
#zip -r Trojan-${user}.zip trojan-${user} > /dev/null 2>&1
#rclone copy /root/Trojan-${user}.zip dr:/
#url=$(rclone link dr:/Trojan-${user}.zip)
#id=(`echo $url | grep '^https' | cut -d'=' -f2`)
#Log=`cat /etc/NotifCuenta`
#link="https://drive.google.com/u/4/uc?id=${id}&export=download"
#TEXT="
#$Log
#𝐀𝐫𝐜𝐡𝐢𝐯𝐨 𝐝𝐞 𝐂𝐮𝐞𝐧𝐭𝐚 𝐓𝐫𝐨𝐣𝐚𝐧
#𝕃𝕚𝕟𝕜 𝔻𝕖𝕤𝕔𝕒𝕣𝕘𝕒 : $link"
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
#rm -fr /root/trojan-${user} &> /dev/null
#rm -fr /root/Trojan-${user}.zip &> /dev/null
Log=`cat /etc/NotifCuenta`
TEXT="
$Log"
# REMOVED SBG CALL: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
rm -rf /etc/NotifCuenta
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
}
function login-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e "${COLOR1}┌───────────────────────────────────────────────┐${NC}"
echo -e "${COLOR1}│${NC}${COLBG1}           ${WH}• SETTING MULTI LOGIN •             ${NC}${COLOR1}│ $NC"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}┌───────────────────────────────────────────────┐${NC}"
echo -e "${COLOR1}│ $NC POR FAVOR ESCRIBA EL NÚMERO DE NOTIFICACIONES PARA BLOQUEO    ${NC}"
echo -e "${COLOR1}│ $NC CUENTAS DE USUARIOS DE INICIO DE SESIÓN MÚLTIPLE     ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
read -rp "   Si desea notificaciones 3x bloqueo, escriba 3, etc.: " -e notif
cd /etc/trojan
echo "$notif" > notif
clear
echo -e "${COLOR1}┌───────────────────────────────────────────────┐${NC}"
echo -e "${COLOR1}│${NC}${COLBG1}           ${WH}• SETTING MULTI LOGIN •             ${NC}${COLOR1}│ $NC"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}┌───────────────────────────────────────────────┐${NC}"
echo -e "${COLOR1}│ $NC CAMBIANDO CON ÉXITO LA NOTIFICACIÓN DE BLOQUEO PARA $notif $NC "
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
}
function lock-tr(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
if [ ! -e  /etc/trojan/listlock ]; then
echo "" > /etc/trojan/listlock
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/trojan/listlock")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún Usuario Existente Bloqueado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que desea Desbloquear"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar Todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/trojan/listlock" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-trojan
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/trojan/listlock
m-trojan
fi
fi
done
user=$(grep -E "^### " "/etc/trojan/listlock" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/trojan/listlock" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^### " "/etc/trojan/listlock" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#trojanws$/a\#tr '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i "/^### $user $exp $uuid/d" /etc/trojan/listlock
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY TROJAN UNLOCKED</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>CUENTA DESBLOQUEADA CON EXITO...</i>
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
echo " Trojan Account Unlock Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
}
clear
function res-user(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e /etc/trojan/akundelete ]; then
echo "" > /etc/trojan/akundelete
fi
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/trojan/akundelete")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}   ${WH}⇱ Restore Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún usuario existente Expirado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}   ${WH}⇱ Restore Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que desea Restaurar"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar Todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/trojan/akundelete" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-trojan
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/trojan/akundelete
m-trojan
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
read -p "Limite Cuota (GB) o 0 ILIMITADO: " Quota
done
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
user=$(grep -E "^### " "/etc/trojan/akundelete" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
uuid=$(grep -E "^### " "/etc/trojan/akundelete" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#trojanws$/a\#tr '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
echo "${iplim}" >/etc/trojan/${user}IP
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/trojan/${user}
fi
sed -i "/^### ${user} ${exp} ${uuid}/d" /etc/trojan/akundelete
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY TROJAN RESTAURACION</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>USUARIO    :</b> <code>$user </code>
<b>IP LIMIT   :</b> <code>$iplim IP </code>
<b>Quota LIMIT:</b> <code>$Quota GB </code>
<b>EXPIRACION :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>CUENTA RESTAURADA CON EXITO...</i>
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
echo " Trojan Account Restore Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " DOMINIO   : $domain"
echo " ISP       : $ISP $CITY"
echo " USUARIO   : $user"
echo " IP LIMIT  : $iplim IP"
echo " EXPIRACON : $exp"
echo " Restaurado con Exito"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
}
function quota-user(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e  /etc/trojan/userQuota ]; then
echo "" > /etc/trojan/userQuota
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/trojan/userQuota")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún Usuario Existente Bloqueado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Trojan Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que desea Desbloquear"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar Todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/trojan/userQuota" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-trojan
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/trojan/userQuota
m-trojan
fi
fi
done
user=$(grep -E "^### " "/etc/trojan/userQuota" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/trojan/userQuota" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^### " "/etc/trojan/userQuota" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#trojanws$/a\#tr '"$user $exp $uuid"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#trojangrpc$/a\#trg '"$user $exp"'\
},{"password": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i "/^### $user $exp $uuid/d" /etc/trojan/userQuota
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY TROJAN UNLOCKED</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>USUARIO DESBLOQUEADO CON EXITO...</i>
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
echo " Trojan Account Unlock Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
m-trojan
}
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│${NC} ${COLBG1}                ${WH}• TROJAN PANEL MENU •             ${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}01${WH}]${NC} ${COLOR1}• ${WH}CREAR CUENTA${NC}     ${WH}[${COLOR1}06${WH}]${NC} ${COLOR1}• ${WH}CHEC CONFIG USER${NC}   ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}02${WH}]${NC} ${COLOR1}• ${WH}TEMPORAL CUENTA${NC}  ${WH}[${COLOR1}07${WH}]${NC} ${COLOR1}• ${WH}CAMBIAR LIMIT USER${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}03${WH}]${NC} ${COLOR1}• ${WH}RENOVAR CUENTA${NC}   ${WH}[${COLOR1}08${WH}]${NC} ${COLOR1}• ${WH}SETTING LOCK LOGIN${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}04${WH}]${NC} ${COLOR1}• ${WH}BORRAR CUENTA${NC}    ${WH}[${COLOR1}09${WH}]${NC} ${COLOR1}• ${WH}UNLOCK USER LOGIN${NC}  ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}05${WH}]${NC} ${COLOR1}• ${WH}CEK USER LOGIN${NC}   ${WH}[${COLOR1}10${WH}]${NC} ${COLOR1}• ${WH}UNLOCK USER CUOTA ${NC} ${COLOR1}│ $NC"
echo -e " ${COLOR1}│ $NC ${WH}[${COLOR1}00${WH}]${NC} ${COLOR1}• ${WH}REGRESAR${NC}         ${WH}[${COLOR1}11${WH}]${NC} ${COLOR1}• ${WH}RESTAURAR CUENTA ${NC}  ${COLOR1}│ $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e " ${COLOR1}╭═════════════════════════ ${WH}BY${NC} ${COLOR1}═══════════════════════╮ ${NC}"
echo -e " ${COLOR1}${NC}               ${WH}        • $author •                 ${COLOR1} $NC"
echo -e " ${COLOR1}╰════════════════════════════════════════════════════╯${NC}"
echo -e ""
echo -ne " ${WH}Seleccione una Opcion ${COLOR1}: ${WH}"; read opt
case $opt in
01 | 1) clear ; add-tr ;;
02 | 2) clear ; trial-trojan ;;
03 | 3) clear ; renew-tr ;;
04 | 4) clear ; del-tr ;;
05 | 5) clear ; cek-tr ;;
06 | 6) clear ; list-trojan ;;
07 | 7) clear ; limit-tr ;;
08 | 8) clear ; login-tr ;;
09 | 9) clear ; lock-tr ;;
10 | 10) clear ; quota-user ;;
11 | 11) clear ; res-user ;;
00 | 0) clear ; menu ;;
x) exit ;;
*) echo "Lo Presionaste Mal" ; sleep 1 ; m-trojan ;;
esac
