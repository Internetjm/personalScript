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
patch=`head /etc/xray/patch`
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
if [ ! -e /etc/vless/akun ]; then
mkdir -p /etc/vless/akun
fi
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
add-vless
fi
done
[[ -z "$uuid" ]] && uuid=`cat /proc/sys/kernel/random/uuid`
until [[ $masaaktif =~ ^[0-9]+$ ]]; do
read -p "EXPIRACION (DIAS): " masaaktif
done
until [[ $iplim =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (IP) o 0 ILIMITADO: " iplim
done
until [[ $Quota =~ ^[0-9]+$ ]]; do
read -p "Limite Usuario (GB) o 0 ILIMITADO: " Quota
done
if [ ! -e /etc/vless ]; then
mkdir -p /etc/vless
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
rm -rf /tmp/*
if [ -d '/var/www/html/APP/ssh-$uuid.txt' ]; then
cat > /var/www/html/APP/ssh-$uuid.txt <<-END
_______________________________
Format Vless Account
_______________________________
Usuario HWID       : $uuid
Expiracion         : $exp
_______________________________
END
else
cat >> /var/www/html/APP/ssh-$uuid.txt <<-END
_______________________________
Format Vless Account
_______________________________
Usuario HWID       : $uuid
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
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
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
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
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
Login Limit  : ${iplim} IP
Cuota Limit  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
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
#curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
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
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   CREACION VLESS CON EXITO </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>CIUDAD   :</b> <code>$CITY </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLES :</b> <code>CUENTA VLESS </code>
<b>USUARIO  :</b> <code>$user2 </code>
<b>IP       :</b> <code>${iplim} IP </code>
<b>EXPIRA EN :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>NOTIFICACION DE CUENTA VLESS..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID2&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL2 >/dev/null
#cat /etc/vless/akun/log-create-${user}.log
#cat /etc/vless/akun/log-create-${user}.log > /etc/NotifCuenta
#sed -i 's/\x1B\[1;37m//g' /etc/NotifCuenta
#sed -i 's/\x1B\[1;96m//g' /etc/NotifCuenta
#sed -i 's/\x1B\[0m//g' /etc/NotifCuenta
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Premium Vless Account •${NC} ${COLOR1} $NC" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}User         ${COLOR1}: ${WH}${user}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ISP          ${COLOR1}: ${WH}$ISP" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}City         ${COLOR1}: ${WH}$CITY" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Domain       ${COLOR1}: ${WH}${domain}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/vless/akun/log-create-${user}.log
#if [ ${Quota} = '9999' ]; then
#echo -ne
#else
echo -e "${COLOR1} ${NC} ${WH}Cuota Limit  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/vless/akun/log-create-${user}.log
#fi
echo -e "${COLOR1} ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}UUID         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vless/akun/log-create-${user}.log
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
m-vless
}
function trial-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}            ${WH}• Trial Vless Account •             ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
until [[ $timer =~ ^[0-9]+$ ]]; do
read -p "EXPIRACION (MINUTOS): " timer
done
user=Trial-`</dev/urandom tr -dc X-Z0-9 | head -c4`
uuid=$(cat /proc/sys/kernel/random/uuid)
masaaktif=0
iplim=1
Quota=10
if [ ! -e /etc/vless ]; then
mkdir -p /etc/vless
fi
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vless/${user}
fi
echo "${iplim}" > /etc/vless/${user}IP
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
clear
cat> /etc/cron.d/trialvless${user} << END
SHELL=/bin/sh
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
*/$timer * * * * root bash /usr/local/sbin/trial
END
cat > /var/www/html/vless-$user.txt <<-END
━━━━━━━━━━━━━━━━━━
    Trial Premium Vless Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Login Limit  : ${iplim} IP
Login Cuota  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path vless   : /vl-${patch}</code>
ServiceName  : /vlgr-${patch}</code>
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vlesslink1}</code>
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
Expira En    : $timer Minutos
━━━━━━━━━━━━━━━━━━
    $author
━━━━━━━━━━━━━━━━━━
END
TEXT="
━━━━━━━━━━━━━━━━━━
	Trial Premium Vless Account
━━━━━━━━━━━━━━━━━━
User         : ${user}
Domain       : ${domain}
Login Limit  : ${iplim} IP
Login Cuota  : ${Quota} GB
Port TLS     : 443
Port NTLS    : 80,8080,8088,8280,8880,2052,2082,2086,2095
Port GRPC    : 443
UUID         : ${uuid}
AlterId      : 0
Security     : auto
Network      : WS or gRPC
Path vless   : /vl-${patch}</code>
ServiceName  : /vlgr-${patch}</code>
━━━━━━━━━━━━━━━━━━
Link TLS     :
${vlesslink1}</code>
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
Expira En    : $timer Minutos
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
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT2="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   CREACION EXITOSA DE VLESS </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>CIUDAD   :</b> <code>$CITY </code>
<b>FECHA    :</b> <code>${TIME2} HORA </code>
<b>DETALLE  :</b> <code>CUENTA VLESS </code>
<b>USUARIO  :</b> <code>$user </code>
<b>IP       :</b> <code>${iplim} IP </code>
<b>EXPIRA EN :</b> <code>$timer MINUTOS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>Notificacion de Cuenta Vless..</i>"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT2&parse_mode=html" $URL >/dev/null
#cat /etc/vless/akun/log-create-${user}.log
#cat /etc/vless/akun/log-create-${user}.log > /etc/NotifCuenta
#sed -i 's/\x1B\[1;37m//g' /etc/NotifCuenta
#sed -i 's/\x1B\[1;96m//g' /etc/NotifCuenta
#sed -i 's/\x1B\[0m//g' /etc/NotifCuenta
clear
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• Trial Premium Vless Account •${NC} ${COLOR1} $NC" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}User         ${COLOR1}: ${WH}${user}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}ISP          ${COLOR1}: ${WH}$ISP" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}City         ${COLOR1}: ${WH}$CITY" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Domain       ${COLOR1}: ${WH}${domain}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Login Limit  ${COLOR1}: ${WH}${iplim} IP" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Login Cuota  ${COLOR1}: ${WH}${Quota} GB" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port TLS     ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port NTLS    ${COLOR1}: ${WH}80,8080,8088,8280,8880,2052,2082,2086,2095" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}Port gRPC    ${COLOR1}: ${WH}443" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}UUID         ${COLOR1}: ${WH}${uuid}" | tee -a /etc/vless/akun/log-create-${user}.log
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
echo -e "${COLOR1} ${NC} ${WH}Expira En   ${COLOR1}: ${WH}$timer Minutes" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ${NC} ${WH}• $author •${NC}    " | tee -a /etc/vless/akun/log-create-${user}.log
echo -e "${COLOR1} ━━━━━━━━━━━━━━━ ${NC}" | tee -a /etc/vless/akun/log-create-${user}.log
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-vless
}
function limit-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vlg " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}     ${WH}⇱ Limit Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}     ${WH}⇱ Limit Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "Seleccione el Cliente Existente del cual Desea Cambiar la IP"
echo " Escriba [0] Regresar al MENU"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^#vlg " "/etc/xray/config.json" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}]: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vless
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
if [ ! -e /etc/vless ]; then
mkdir -p /etc/vless
fi
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
user=$(grep -E "^#vlg " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
echo "${iplim}" >/etc/vless/${user}IP
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vless/${user}
fi
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VLESS LIMITE IP</b>
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
echo " VLESS Account Was Successfully Change Limit IP"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " Client Name : $user"
echo " Limit IP    : $iplim IP"
echo " Limit Cuota : $Quota GB"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
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
m-vless
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
m-vless
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
sed -i "s/#vl $user $exp/#vl $user $exp4/g" /etc/xray/config.json
sed -i "s/#vlg $user $exp/#vlg $user $exp4/g" /etc/xray/config.json
sed -i "s/$exp/$exp4/g" /var/www/html/vless-$user.txt >/dev/null
sed -i "s/$exp/$exp4/g" /var/www/html/APP/ssh-$user.txt >/dev/null
sed -i "s/$user:$exp/$user:$exp4/g" /var/www/html/CheckUser >/dev/null
sed -i "s/$user $exp/$user $exp4/g" /etc/xray/token >/dev/null
clear
TIME2=$(date +'%d-%m-%Y %I:%M:%S')
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>   RENOVADO VLESS CON EXITO </b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO    :</b> <code>${domain} </code>
<b>ISP        :</b> <code>$ISP $CITY </code>
<b>FECHA      :</b> <code>${TIME2} HORA </code>
<b>DETALLES   :</b> <code>CUENTA VLESS </code>
<b>USUARIO    :</b> <code>$user </code>
<b>EXPIRACION :</b> <code>$exp4 </code>
<b>AGREGARON  :</b> <code>$masaaktif DIAS </code>
<code>━━━━━━━━━━━━━━━━━━</code>
<i>RENOVACION DE CUENTA VLESS..</i>
"
curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
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
m-vless
}
function del-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vl " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Delete Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Delete Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Usuario que Desea Eliminar"
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
m-vless
fi
fi
done
user=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
if [ ! -e /etc/vless/akundelete ]; then
echo "" > /etc/vless/akundelete
fi
clear
echo "### $user $exp $uuid" >> /etc/vless/akundelete
sed -i "/^#vl $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#vlg $user $exp/,/^},{/d" /etc/xray/config.json
sed -i "/^#Vless $uuid $exp $user/,/^},{/d" /etc/xray/token
clear
rm /var/www/html/vless-$user.txt >/dev/null 2>&1
rm /var/www/html/APP/ssh-$user.txt >/dev/null 2>&1
rm /etc/vless/${user} >/dev/null 2>&1
rm /etc/vless/${user}IP >/dev/null 2>&1
rm /etc/vless/${user}login >/dev/null 2>&1
rm /etc/vless/akundelete >/dev/null 2>&1
rm /etc/vless/akun/log-create-${user}.log >/dev/null 2>&1
grep -rl "${user}" /etc/vless/akun/ | xargs rm -f
clear
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VLESS BORRADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>USUARIO   :</b> <code>$user </code>
<b>EXPIRABA  :</b> <code>$exp </code>
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
echo " Vless Account Deleted Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Expira El   : $exp"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
systemctl daemon-reload > /dev/null 2>&1
systemctl restart xray > /dev/null 2>&1
m-vless
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
function cek-vless(){
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
data=( `cat /etc/xray/config.json | grep '^#vl' | cut -d ' ' -f 2 | sort | uniq`);
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}             ${WH}• VLESS USER ONLINE •              ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
for akun in "${data[@]}"
do
if [[ -z "$akun" ]]; then
akun="tidakada"
fi
echo -n > /tmp/ipvless.txt
data2=( `cat /var/log/xray/access.log | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | sort | uniq`);
for ip in "${data2[@]}"
do
jum=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 3 | sed 's/tcp://g' | cut -d ":" -f 1 | grep -w "$ip" | sort | uniq)
if [[ "$jum" = "$ip" ]]; then
echo "$jum" >> /tmp/ipvless.txt
else
echo "$ip" >> /tmp/other.txt
fi
jum2=$(cat /tmp/ipvless.txt)
sed -i "/$jum2/d" /tmp/other.txt > /dev/null 2>&1
done
jum=$(cat /tmp/ipvless.txt)
if [[ -z "$jum" ]]; then
echo > /dev/null
else
iplimit=$(cat /etc/vless/${akun}IP)
jum2=$(cat /tmp/ipvless.txt | wc -l)
byte=$(cat /etc/vless/${akun})
lim=$(con ${byte})
wey=$(cat /etc/limit/vless/${akun})
gb=$(con ${wey})
lastlogin=$(cat /var/log/xray/access.log | grep -w "$akun" | tail -n 500 | cut -d " " -f 4 | tail -1)
echo -e "  ${COLOR1}═══════════════════════════════════════════════${NC}"
echo -e "   ${COLOR1}${NC} USUARIO  : \033[0;33m$akun"
echo -e "   ${COLOR1}${NC} IP LOGIN : \033[0;33m$lastlogin"
echo -e "   ${COLOR1}${NC} USADO CUOTA : \033[0;33m$gb"
echo -e "   ${COLOR1}${NC} LIMITE CUOTA : \033[0;33m$lim"
echo -e "   ${COLOR1}${NC} LIMITE IP : \033[0;33m$iplimit"
echo -e "   ${COLOR1}${NC} LOGIN IP : \033[0;33m$jum2"
echo -e "  ${COLOR1}═══════════════════════════════════════════════${NC}"
fi 
rm -rf /tmp/ipvless.txt
done
rm -rf /tmp/other.txt
echo ""
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo ""
read -n 1 -s -r -p "Presione [ Enter ] para regresar al MENU"
m-vless
}
function list-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^#vl " "/etc/xray/config.json")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Config Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes Clientes Existentes!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
fi
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Config Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente para ver la Configuración."
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
m-vless
fi
fi
done
clear
user=$(grep -E "^#vl " "/etc/xray/config.json" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
cat /etc/vless/akun/log-create-${user}.log
cat /etc/vless/akun/log-create-${user}.log > /etc/NotifCuenta
sed -i 's/\x1B\[1;37m//g' /etc/NotifCuenta
sed -i 's/\x1B\[1;96m//g' /etc/NotifCuenta
sed -i 's/\x1B\[0m//g' /etc/NotifCuenta
#cat /etc/NotifCuenta > /root/vless-${user}
#cd /root
#zip -r Vless-${user}.zip vless-${user} > /dev/null 2>&1
#rclone copy /root/Vless-${user}.zip dr:/
#url=$(rclone link dr:/Vless-${user}.zip)
#id=(`echo $url | grep '^https' | cut -d'=' -f2`)
#Log=`cat /etc/NotifCuenta`
#link="https://drive.google.com/u/4/uc?id=${id}&export=download"
#TEXT="
#$Log
#𝐀𝐫𝐜𝐡𝐢𝐯𝐨 𝐝𝐞 𝐂𝐮𝐞𝐧𝐭𝐚 𝐕𝐥𝐞𝐬𝐬
#𝕃𝕚𝕟𝕜 𝔻𝕖𝕤𝕔𝕒𝕣𝕘𝕒 : $link"
#curl -s --max-time $TIMES -d "chat_id=$CHATID&disable_web_page_preview=1&text=$TEXT&parse_mode=html" $URL >/dev/null
#rm -fr vless-${user} &> /dev/null
#rm -fr Vless-${user}.zip &> /dev/null
Log=`cat /etc/NotifCuenta`
TEXT="
$Log"
# REMOVED SBG CALL: curl -s -X POST https://api.telegram.org/bot$KEY/sendMessage -d chat_id=$CHATID -d text="${TEXT}" > /dev/null
rm -rf /etc/NotifCuenta
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
}
function login-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}           ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC POR FAVOR ESCRIBA EL NÚMERO DE NOTIFICACIONES PARA BLOQUEO    ${NC}"
echo -e "${COLOR1}│ $NC CUENTAS DE USUARIOS DE INICIO DE SESIÓN MÚLTIPLE     ${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
read -rp "   Si desea notificaciones 3x bloqueo, Escriba 3, etc.: " -e notif
cd /etc/vless
echo "$notif" > notif
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│${NC} ${COLBG1}           ${WH}• SETTING MULTI LOGIN •            ${NC} ${COLOR1}│ $NC"
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═══════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ $NC CAMBIANDO CON ÉXITO LA NOTIFICACIÓN DE BLOQUEO PARA $notif $NC "
echo -e "${COLOR1}╰═══════════════════════════════════════════════╯${NC}"
m-vless
}
function lock-vless(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
if [ ! -e /etc/vless/listlock ]; then
echo "" > /etc/vless/listlock
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/vless/listlock")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún Usuario Existente Bloqueado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que desea Desbloquear"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/vless/listlock" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vless
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/vless/listlock
m-vless
fi
fi
done
user=$(grep -E "^### " "/etc/vless/listlock" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/vless/listlock" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^### " "/etc/vless/listlock" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#vless$/a\#vl '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#vlg '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i "/^### $user $exp $uuid/d" /etc/vless/listlock
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VLESS DESBLOQUEADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO  :</b> <code>${domain} </code>
<b>ISP      :</b> <code>$ISP $CITY </code>
<b>USUARIO  :</b> <code>$user </code>
<b>EXPIRA   :</b> <code>$exp </code>
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
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Vless Account Unlock Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
}
function res-user(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
cd
if [ ! -e /etc/vless/akundelete ]; then
echo "" > /etc/vless/akundelete
fi
clear
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/vless/akundelete")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Restore Vless Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún usuario existente Expirado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Restore Vless Account ⇲    ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que desea Restaurar"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/vless/akundelete" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vless
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/vless/akundelete
m-vless
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
read -p "Limite Usuario (GB) o 0 ILIMITADO: " Quota
done
if [ ${iplim} = '0' ]; then
iplim="9999"
fi
if [ ${Quota} = '0' ]; then
Quota="9999"
fi
user=$(grep -E "^### " "/etc/vless/akundelete" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=`date -d "$masaaktif days" +"%Y-%m-%d"`
uuid=$(grep -E "^### " "/etc/vless/akundelete" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#vless$/a\#vl '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#vlg '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
echo "${iplim}" >/etc/vless/${user}IP
c=$(echo "${Quota}" | sed 's/[^0-9]*//g')
d=$((${c} * 1024 * 1024 * 1024))
if [[ ${c} != "0" ]]; then
echo "${d}" >/etc/vless/${user}
fi
sed -i "/^### ${user} ${exp} ${uuid}/d" /etc/vless/akundelete
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VLESS RESTAURADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>USUARIO   :</b> <code>$user </code>
<b>LIMITE IP :</b> <code>$iplim IP </code>
<b>LIMITE CUOTA:</b> <code>$Quota GB </code>
<b>EXPIRA    :</b> <code>$exp </code>
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
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Vless Account Restore Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Expira      : $exp"
echo " Restaurada con Exito"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
}
function quota-user(){
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
if [ ! -e /etc/vless/userQuota ]; then
echo "" > /etc/vless/userQuota
fi
NUMBER_OF_CLIENTS=$(grep -c -E "^### " "/etc/vless/userQuota")
if [[ ${NUMBER_OF_CLIENTS} == '0' ]]; then
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo " No tienes ningún Usuario Existente Bloqueado!"
echo ""
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
fi
clear
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${COLOR1} ${NC}${COLBG1}    ${WH}⇱ Unlock Vless Account ⇲     ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Seleccione el Cliente Existente que desea Desbloquear"
echo " Escriba [0] Regresar al MENU"
echo " Escriba [999] para Eliminar todas las Cuentas"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo "     No  User   Expired"
grep -E "^### " "/etc/vless/userQuota" | cut -d ' ' -f 2-3 | nl -s ') '
until [[ ${CLIENT_NUMBER} -ge 1 && ${CLIENT_NUMBER} -le ${NUMBER_OF_CLIENTS} ]]; do
if [[ ${CLIENT_NUMBER} == '1' ]]; then
read -rp "Seleccione un Cliente [1]: " CLIENT_NUMBER
else
read -rp "Seleccione un Cliente [1-${NUMBER_OF_CLIENTS}] to Unlock: " CLIENT_NUMBER
if [[ ${CLIENT_NUMBER} == '0' ]]; then
m-vless
fi
if [[ ${CLIENT_NUMBER} == '999' ]]; then
rm /etc/vless/userQuota
m-vless
fi
fi
done
user=$(grep -E "^### " "/etc/vless/userQuota" | cut -d ' ' -f 2 | sed -n "${CLIENT_NUMBER}"p)
exp=$(grep -E "^### " "/etc/vless/userQuota" | cut -d ' ' -f 3 | sed -n "${CLIENT_NUMBER}"p)
uuid=$(grep -E "^### " "/etc/vless/userQuota" | cut -d ' ' -f 4 | sed -n "${CLIENT_NUMBER}"p)
sed -i '/#vless$/a\#vl '"$user $exp $uuid"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i '/#vlessgrpc$/a\#vlg '"$user $exp"'\
},{"id": "'""$uuid""'","email": "'""$user""'"' /etc/xray/config.json
sed -i "/^### $user $exp $uuid/d" /etc/vless/userQuota
systemctl restart xray
TEXT="
<code>━━━━━━━━━━━━━━━━━━</code>
<b>  XRAY VLESS DESBLOQUEADO</b>
<code>━━━━━━━━━━━━━━━━━━</code>
<b>DOMINIO   :</b> <code>${domain} </code>
<b>ISP       :</b> <code>$ISP $CITY </code>
<b>USUARIO   :</b> <code>$user </code>
<b>EXPIRA    :</b> <code>$exp </code>
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
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Vless Account Unlock Successfully"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo " Client Name : $user"
echo " Status  : Unlocked"
echo -e "${COLOR1}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
read -n 1 -s -r -p "Presione Cualquier Tecla para Regresar al MENU"
m-vless
}
checking_sc
rm -rf /root/checkIP.*
rm -rf /tmp/tmp.*
clear
echo -e " ${COLOR1}╭════════════════════════════════════════════════════╮${NC}"
echo -e " ${COLOR1}│${NC} ${COLBG1}                  ${WH}• VLESS PANEL MENU •            ${NC} ${COLOR1}│ $NC"
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
1) clear ; add-vless ; exit ;;
2) clear ; trial-vless ; exit ;;
3) clear ; renew-vless ; exit ;;
4) clear ; del-vless ; exit ;;
5) clear ; cek-vless ; exit ;;
6) clear ; list-vless ; exit ;;
7) clear ; limit-vless ; exit ;;
8) clear ; login-vless ; exit ;;
9) clear ; lock-vless ; exit ;;
10) clear ; quota-user ; exit ;;
11) clear ; res-user ; exit ;;
0) clear ; menu ; exit ;;
x) exit ;;
*) echo "Presionaste Mal " ; sleep 1 ; m-vless ;;
esac
