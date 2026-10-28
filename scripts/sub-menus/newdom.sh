#!/bin/bash
biji=`date +"%Y-%m-%d" -d "$dateFromServer"`
colornow=$(cat /etc/rmbl/theme/color.conf)
NC="\e[0m"
RED="\033[0;31m"
COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
checking_sc() {
clear
}
checking_sc
rm -rf /root/checkIP*
rm -rf /tmp/tmp.*
clear
function certv2ray(){
echo -e ""
echo start
sleep 0.5
source /var/lib/ipvps.conf
domain=$(cat /etc/xray/domain)
STOPWEBSERVER=$(lsof -i:89 | cut -d' ' -f1 | awk 'NR==2 {print $1}')
rm -rf /root/.acme.sh
mkdir /root/.acme.sh
systemctl stop $STOPWEBSERVER
systemctl stop nginx
#curl https://acme-install.netlify.app/acme.sh -o /root/.acme.sh/acme.sh
curl https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh -o /root/.acme.sh/acme.sh
chmod +x /root/.acme.sh/acme.sh
/root/.acme.sh/acme.sh --register-account -m rmbl@slowapp.cfd
/root/.acme.sh/acme.sh --upgrade --auto-upgrade
/root/.acme.sh/acme.sh --set-default-ca --server letsencrypt
/root/.acme.sh/acme.sh --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /etc/xray/xray.crt --keypath /etc/xray/xray.key --ecc
chmod 777 /etc/xray/xray.key  
cat /etc/xray/xray.crt /etc/xray/xray.key | tee /etc/haproxy/funny.pem

# nginx renew ssl
echo -n '#!/bin/bash
/etc/init.d/nginx stop
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
/etc/init.d/nginx start
/etc/init.d/nginx status
' > /usr/local/bin/ssl_renew.sh
chmod +x /usr/local/bin/ssl_renew.sh
if ! grep -q 'ssl_renew.sh' /var/spool/cron/crontabs/root;then (crontab -l;echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab;fi
systemctl daemon-reload
systemctl restart nginx
systemctl restart xray
systemctl restart haproxy
echo -e "[ ${green}ok${NC} ] CERTIFICADO APLICADO "
sleep 2
menu
}
clear
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
echo -ne "  \033[0;33mActualizando Dominio... \033[1;37m- \033[0;33m["
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
echo -e "\033[0;33m]\033[1;37m -\033[1;32m CON EXITO !\033[1;37m"
tput cnorm
}
res1() {
echo -e "\n  Ingresa tu subdominio personalizado (ej: mi.dominio.com)"
read -rp "  Dominio: " _dn
[[ -n "$_dn" ]] && echo "$_dn" > /etc/xray/domain && echo "  Dominio guardado: $_dn"
}
res2() {
echo -e "\n  Ingresa tu subdominio personalizado (ej: mi.dominio.com)"
read -rp "  Dominio: " _dn
[[ -n "$_dn" ]] && echo "$_dn" > /etc/xray/domain && echo "  Dominio guardado: $_dn"
}
res3() {
echo -e "\n  Ingresa tu subdominio personalizado (ej: mi.dominio.com)"
read -rp "  Dominio: " _dn
[[ -n "$_dn" ]] && echo "$_dn" > /etc/xray/domain && echo "  Dominio guardado: $_dn"
}
res4() {
echo -e "\n  Ingresa tu subdominio personalizado (ej: mi.dominio.com)"
read -rp "  Dominio: " _dn
[[ -n "$_dn" ]] && echo "$_dn" > /etc/xray/domain && echo "  Dominio guardado: $_dn"
}
res5() {
echo -e "\n  Ingresa tu subdominio personalizado (ej: mi.dominio.com)"
read -rp "  Dominio: " _dn
[[ -n "$_dn" ]] && echo "$_dn" > /etc/xray/domain && echo "  Dominio guardado: $_dn"
}
res6() {
echo -e "\n  Ingresa tu subdominio personalizado (ej: mi.dominio.com)"
read -rp "  Dominio: " _dn
[[ -n "$_dn" ]] && echo "$_dn" > /etc/xray/domain && echo "  Dominio guardado: $_dn"
}
dom=$( cat /etc/xray/domain)
echo $dom > /root/dom
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ ${WH}Please select a your Choice to Set Domain              ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│  [ 1 ]  ${WH}Tu propio Dominio VPS   ${NC}"
echo -e "${COLOR1}│  [ 2 ]  ${WH}Dominios VPS que tiene el Scripts     ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
until [[ $dns =~ ^[1-2]+$ ]]; do
read -p "   Seleccione los números 1-3 o cualquier botón (aleatorio) : " dns
done
if [[ $dns == "1" ]]; then
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│             ${WH}GRACIAS POR                  ${COLOR1}│${NC}"
echo -e  "${COLOR1}│        ${WH}MI AUTOSCRIPT PREMIUM             ${COLOR1}│${NC}"
echo -e  "${COLOR1}│              ${WH}JERRY SBG                   ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dnss =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio aquí : " -e dnss
done
rm -rf /etc/xray/domain
rm -rf /etc/xray/scdomain
rm -rf /var/lib/ipvps.conf
echo "$dnss" > /etc/xray/domain
echo "$dnss" > /etc/xray/scdomain
echo "IP=$dnss" > /var/lib/ipvps.conf
read -n 1 -s -r -p "  Presione cualquier tecla para regresar al Menu"
certv2ray
clear
elif [[ $dns == "2" ]]; then
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│ \033[1;37mPlease select a your Choice to Set Domain${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│  [ 1 ]  \033[1;37mDomain xxx.tepllovpn.eu.org       ${NC}"
echo -e "${COLOR1}│  [ 2 ]  \033[1;37mDomain xxx.berurat.cloud       ${NC}"
echo -e "${COLOR1}│  [ 3 ]  \033[1;37mDomain xxx.xnxxms.cloud       ${NC}"
echo -e "${COLOR1}│  [ 4 ]  \033[1;37mDomain xxx.vvpnstore.my.id       ${NC}"
echo -e "${COLOR1}│  [ 5 ]  \033[1;37mDomain xxx.yogzvpn.cloud       ${NC}"
echo -e "${COLOR1}│  [ 6 ]  \033[1;37mDomain xxx.jerrysbg.com      ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
until [[ $domain2 =~ ^[1-6]+$ ]]; do
read -p "   Please select numbers : " domain2
done
if [[ $domain2 == "1" ]]; then
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│  \033[1;37mEjemplo de Subdominio xxx.tepllovpn.eu.org       ${COLOR1}│${NC}"
echo -e  "${COLOR1}│    \033[1;37mxxx Es Tu Subdominio               ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dn1 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio aquí : " -e dn1
done
echo "$dn1" > /etc/xray/domain
echo "$dn1" > /root/subdomainx
cd
sleep 1
fun_bar 'res1'
clear
rm -rf /root/subdomainx
certv2ray
clear
fi
if [[ $domain2 == "2" ]]; then
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│  \033[1;37mEjemplo de Subdominio xxx.berurat.cloud      ${COLOR1}│${NC}"
echo -e  "${COLOR1}│    \033[1;37mxxx Es Tu Subdominio               ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dn2 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio aquí : " -e dn2
done
echo "$dn2" > /etc/xray/domain
echo "$dn2" > /root/subdomainx
cd
sleep 1
fun_bar 'res2'
clear
rm -rf /root/subdomainx
fi
if [[ $domain2 == "3" ]]; then
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│  \033[1;37mEjemplo de Subdominio xxx.xnxxms.cloud       ${COLOR1}│${NC}"
echo -e  "${COLOR1}│    \033[1;37mxxx Es Tu Subdominio               ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dn3 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio aquí : " -e dn3
done
echo "$dn3" > /etc/xray/domain
echo "$dn3" > /root/subdomainx
cd
sleep 1
fun_bar 'res5'
clear
rm -rf /root/subdomainx
fi
if [[ $domain2 == "4" ]]; then
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│  \033[1;37mEjemplo de Subdominio xxx.vvpnstore.my.id        ${COLOR1}│${NC}"
echo -e  "${COLOR1}│    \033[1;37mxxx Es Tu Subdominio               ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dn4 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio aquí : " -e dn4
done
echo "$dn4" > /etc/xray/domain
echo "$dn4" > /root/subdomainx
cd
sleep 1
fun_bar 'res4'
clear
rm -rf /root/subdomainx
fi
if [[ $domain2 == "5" ]]; then
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│  \033[1;37mEjemplo de Subdominio xxx.yogzvpn.cloud        ${COLOR1}│${NC}"
echo -e  "${COLOR1}│    \033[1;37mxxx Es Tu Subdominio               ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dn5 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio aquí : " -e dn5
done
echo "$dn5" > /etc/xray/domain
echo "$dn5" > /root/subdomainx
cd
sleep 1
fun_bar 'res3'
clear
rm -rf /root/subdomainx
fi
if [[ $domain2 == "6" ]]; then
clear
echo -e  "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e  "${COLOR1}│  \033[1;37mEjemplo de Subdominio xxx.jerrysbg.com        ${COLOR1}│${NC}"
echo -e  "${COLOR1}│    \033[1;37mxxx Es Tu Subdominio               ${COLOR1}│${NC}"
echo -e  "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo " "
until [[ $dn6 =~ ^[a-zA-Z0-9_.-]+$ ]]; do
read -rp "Introduce tu Dominio aquí : " -e dn6
done
echo "$dn6" > /etc/xray/domain
echo "$dn6" > /root/subdomainx
cd
sleep 1
fun_bar 'res6'
clear
rm -rf /root/subdomainx
fi
read -n 1 -s -r -p "  Presione Cualquier Tecla para Renovar Certificado o Ctrl + C para Salir"
certv2ray
clear
fi
echo -e " Back To Menu"
sleep 1
menu
