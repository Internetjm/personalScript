#!/bin/bash
NC='\e[0m'
colornow=$(cat /etc/rmbl/theme/color.conf)
export NC="\e[0m"
export COLOR1="$(cat /etc/rmbl/theme/$colornow | grep -w "TEXT" | cut -d: -f2|sed 's/ //g')"
rm -rf $(pwd)/$0
clear
echo -e "${COLOR1}╭═══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│$NC     \e[1;32mCONFIGURA IP/SUBDOMINIO/DOMINIO       ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════╯${NC}"
echo -e " "
read -p "   Ingresa tu Ip/Subdominio/Dominio : " domain
[[ -z "$domain" ]] && domain=$(cat /etc/xray/domain 2>/dev/null)
[[ -z "$domain" ]] && domain=$(wget -qO- ipinfo.io/ip)
echo -e " "
echo -e "${COLOR1}╭═══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│           \e[1;32mCREAR OBFS PERSONALIZADO        ${NC}${COLOR1}│${NC}"
echo -e "${COLOR1}╰═══════════════════════════════════════════╯${NC}"
echo -e " "
read -p "   Ingresa tu OBFS o ENTER para una Aletorio : " OBFS
    [[ -z "$OBFS" ]] && OBFS=`head /dev/urandom | tr -dc 'a-zA-Z0-9' | head -c 8`
cd /root
systemctl stop udpmod >/dev/null 2>&1
rm -rf /root/UDPMOD
echo -e "   \e[1;32mDescargando UDPMOD desde GitHub..."
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/scripts/UDPMOD/UDPMOD.zip -O UDPMOD.zip
unzip -o UDPMOD.zip
chmod 755 UDPMOD/*
rm -rf UDPMOD.zip

echo -e "   \e[1;32mInstalando Hysteria y Configurando, Espera..."

dir=/root
interfas=$(ip -4 route ls|grep default|grep -Po '(?<=dev )(\S+)'|head -1)
sys=$(command -v sysctl)
ip4t=$(command -v iptables)
ip6t=$(command -v ip6tables)

openssl genrsa -out ${dir}/UDPMOD/udpmod.ca.key 2048 2>/dev/null
openssl req -new -x509 -days 3650 -key ${dir}/UDPMOD/udpmod.ca.key -subj "/C=CN/ST=GD/L=SZ/O=Udpmod, Inc./CN=Udpmod Root CA" -out ${dir}/UDPMOD/udpmod.ca.crt 2>/dev/null
openssl req -newkey rsa:2048 -nodes -keyout ${dir}/UDPMOD/udpmod.server.key -subj "/C=CN/ST=GD/L=SZ/O=Udpmod, Inc./CN=${domain}" -out ${dir}/UDPMOD/udpmod.server.csr 2>/dev/null
openssl x509 -req -extfile <(printf "subjectAltName=DNS:${domain}") -days 3650 -in ${dir}/UDPMOD/udpmod.server.csr -CA ${dir}/UDPMOD/udpmod.ca.crt -CAkey ${dir}/UDPMOD/udpmod.ca.key -CAcreateserial -out ${dir}/UDPMOD/udpmod.server.crt 2>/dev/null

cat > ${dir}/UDPMOD/config.json << END
{
  "listen": ":36712",
  "cert": "${dir}/UDPMOD/udpmod.server.crt",
  "key": "${dir}/UDPMOD/udpmod.server.key",
  "protocol": "udp",
  "up": "600 Mbps",
  "up_mbps": 600,
  "down": "600 Mbps",
  "down_mbps": 600,
  "disable_udp": false,
  "obfs": "${OBFS}",
  "disable_mtu_discovery": false,
  "auth": {
    "mode": "passwords",
    "config": ["Ujm:Pjm"]
  }
}
END

{
echo "[Unit]"
echo "Description=UDPMOD Hysteria Service"
echo "After=network.target"
echo ""
echo "[Service]"
echo "User=root"
echo "Group=root"
echo "ExecStartPost=-${sys} -w net.ipv4.ip_forward=1"
echo "ExecStartPost=-${sys} -w net.ipv4.conf.all.rp_filter=0"
echo "ExecStartPost=-${sys} -w net.ipv4.conf.${interfas}.rp_filter=0"
echo "ExecStartPost=-${ip4t} -t nat -A PREROUTING -i ${interfas} -p udp --dport 20000:39999 -j DNAT --to-destination :36712"
echo "ExecStopPost=-${ip4t} -t nat -D PREROUTING -i ${interfas} -p udp --dport 20000:39999 -j DNAT --to-destination :36712"
if [[ -n "$ip6t" ]]; then
echo "ExecStartPost=-${ip6t} -t nat -A PREROUTING -i ${interfas} -p udp --dport 20000:39999 -j DNAT --to-destination :36712"
echo "ExecStopPost=-${ip6t} -t nat -D PREROUTING -i ${interfas} -p udp --dport 20000:39999 -j DNAT --to-destination :36712"
fi
echo "WorkingDirectory=${dir}/UDPMOD"
echo "ExecStart=${dir}/UDPMOD/hysteria-linux-amd64 -config ${dir}/UDPMOD/config.json server"
echo "Restart=on-failure"
echo "RestartSec=3"
echo ""
echo "[Install]"
echo "WantedBy=multi-user.target"
} > /etc/systemd/system/udpmod.service
rm -f ${dir}/UDPMOD/udpmod.service

systemctl daemon-reload
systemctl enable udpmod >/dev/null 2>&1
systemctl restart udpmod
sleep 2
if ! systemctl is-active --quiet udpmod; then
clear
echo -e "\e[1;31m  ERROR: Hysteria no pudo iniciar. Detalle:\e[0m"
journalctl -u udpmod --no-pager -n 15
read -p "  ENTER para continuar..."
exit 1
fi
clear
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "   \e[1;32mOBFS: ${OBFS}" > ${dir}/UDPMOD/data
echo -e "   \e[1;32mPuerto: 36712" >> ${dir}/UDPMOD/data
echo -e "   \e[1;32mRango de Puertos: 20000:39999"
echo -e "   \e[1;32mUsuario :    Ujm"
echo -e "   \e[1;32mContraseña : Pjm"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
rm -f /root/UDPMOD/install.sh
rm -f /root/UDPMOD/README.md
echo -e " \e[1;32mHYSTERIA Instalado Correctamente"
sleep 2
clear
setupudp2 2>/dev/null
