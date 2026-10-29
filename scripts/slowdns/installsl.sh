#!/bin/bash
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export RED="\033[0;31m"
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
export COLBG1="$(cat /etc/rmbl/theme/$colornow | grep -w "BG" | cut -d: -f2|sed 's/ //g')"
WH='\033[1;37m'
cd
rm -f /root/installsl.sh
clear
slowjm() {
slc=$(systemctl status server | grep Active | awk '{print $3}' | cut -d "(" -f2 | cut -d ")" -f1)
if [[ $slc == "running" ]]; then
   slc2=" ${COLOR1}ON ${NC}"
else
   slc2="${RED}OFF ${NC}"
fi
clear
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC         ${COLOR1}Configurar Dominio SlowDNS        $COLOR1│${NC}"
echo -e "$COLOR1│$NC         ${COLOR1}ESTADO DE SlowDNS   ${slc2}          $COLOR1│${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│  [ 1 ]  ${COLOR1}Instalar Dominio SlowDNS PERSONALIZADO${NC}"
echo -e "$COLOR1│  [ 2 ]  ${COLOR1}Desinstalar SLOWDNS                    ${NC}"
echo -e "$COLOR1│  [ ENTER ]  ${COLOR1}REGRESAR AL MENU                    ${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
echo ""
read -p "   Por Favor Selecciona una Opcion : " slow
clear
if [[ $slow == "1" ]]; then
#install slowdns
sudo apt install squid -y
#setting IPtables
iptables -I INPUT -p udp --dport 5300 -j ACCEPT
iptables -t nat -I PREROUTING -p udp --dport 53 -j REDIRECT --to-ports 5300
netfilter-persistent save
netfilter-persistent reload

#delete directory
rm -rf /etc/xray/dns
rm dns

#input nameserver manual to cloudflare
clear
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC               ${COLOR1}DOMINIO SLOWDNS             $COLOR1│${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
echo -e "$COLOR1╭═══════════════════════════════════════════╮${NC}"
echo -e "$COLOR1│$NC  ${COLOR1}Debes de tener Ya Configurado tu Dominio $COLOR1│${NC}"
echo -e "$COLOR1╰═══════════════════════════════════════════╯${NC}"
read -rp "Introduce Tu Dominio NS : " -e sub
SUB_DOMAIN=${sub}
NS_DOMAIN=${SUB_DOMAIN}
echo $NS_DOMAIN > /etc/xray/dns

nameserver=$(cat /etc/xray/dns)
pkill dnstt-server
mkdir -m 777 /etc/slowdns
echo -e "   \e[1;32mDescargando dnstt-server desde GitHub..."
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/scripts/slowdns/dnstt-server -O dnstt-server
mv dnstt-server /etc/slowdns/dnstt-server
#install server.service
cat > /etc/systemd/system/server.service << END
[Unit]
Description=Server SlowDNS
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

#permission service slowdns
cd
chmod +x /etc/systemd/system/server.service
chmod +x /etc/slowdns/dnstt-server
cd /etc/slowdns/
echo -e "${COLOR1}│ \033[0;31m Generando Nueva Clave SlowDNS"
./dnstt-server -gen-key -privkey-file server.key -pubkey-file server.pub &> /dev/null
chmod +x /etc/slowdns/server.pub
chmod +x /etc/slowdns/server.key
echo -e "${COLOR1}│ ${WH}NUEVA KEY SLOWNDS CREADA CON EXITO"
sleep 1
clear
cd
clear
systemctl daemon-reload
systemctl stop server
systemctl enable server
systemctl start server
systemctl restart server
clear
menu
fi
if [[ $slow == "2" ]]; then
clear
rm -rf /etc/xray/dns
rm -rf /etc/slowdns
rm -rf /etc/systemd/system/client.service
rm -rf /etc/systemd/system/server.service
systemctl daemon-reload
systemctl stop client
systemctl stop server
systemctl disable client
systemctl disable server
systemctl daemon-reload
rm -rf /etc/systemd/system/udp-custom.service
rm -rf /etc/udp
echo "Desintalado Correctamente SLOWDNS"
sleep 1
menu
fi
menu
}
slowjm
