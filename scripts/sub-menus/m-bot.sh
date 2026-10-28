#!/bin/bash
NC="\e[0m"
RED="\033[0;31m"
COLOR1="\033[1;36m"
BLUE="\033[1;36m"
purple="\033[1;95m"
WH='\033[1;37m'
domain=$(cat /etc/xray/domain)
JS=$(cat /usr/bin/vendor_codes)
#color
purple="\e[92;1m"
NC='\e[0m'
WH='\033[1;37m'
#install
checking_sc() {
clear
}
#checking_sc
rm -rf /root/checkIP*
rm -rf /tmp/tmp.*
clear
# ========== FUNCIÓN PARA CREAR ENTORNO VIRTUAL ==========
setup_venv() {
    echo -e "${COLOR1}Configurando Entorno para Ubuntu...${NC}"
    
    # Crear directorio para entorno virtual
    mkdir -p /opt
    
    # Eliminar entorno virtual existente si hay problemas
    rm -rf /opt/kyt-venv 2>/dev/null
    
    # Crear entorno virtual
    python3 -m venv /opt/kyt-venv --clear
    
    if [ $? -ne 0 ]; then
        echo -e "${RED}Error: No se Pudo Crear Entorno${NC}"
        echo -e "${COLOR1}Instalando python3-venv...${NC}"
        apt install python3-venv -y
        python3 -m venv /opt/kyt-venv --clear
    fi
    
    # Usar pip del entorno virtual (no del sistema)
    /opt/kyt-venv/bin/python3 -m pip install --upgrade pip --quiet
    echo -e "${GREEN}✓ Entorno Creado en /opt/kyt-venv${NC}"
}
function install-bot(){
checking_sc
setup_venv
clear
apt update -y && apt upgrade -y
clear
echo -e "${COLOR1}Actualizando Base de Datos...${NC}"
apt install python3 python3-pip python3-venv git wget unzip -y &> /dev/null
clear
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/scripts/bot/bot.zip -O bot.zip
unzip -o -P SCr1PtByJS bot.zip >/dev/null 2>&1
mv bot/* /usr/bin
chmod +x /usr/bin/*
rm -rf bot.zip
rm -rf bot
clear
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/scripts/bot/kyt.zip -O kyt.zip
unzip -o -P SCr1PtByJS kyt.zip >/dev/null 2>&1
pip3 install -r kyt/requirements.txt
clear
mv kyt /usr/bin
chmod +x /usr/bin/*
#cd /usr/bin/kyt/bot
#chmod +x *
#mv -f * /usr/bin
rm -rf /usr/bin/kyt/bot
rm -rf /usr/bin/*.zip
rm -rf /root/kyt.zip
cd
rm -rf /etc/tele

clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1} ${NC} ${COLBG1}                ${WH}• BOT PANEL •                  ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${purple}Tutorial Crear Bot Y ID Telegram${NC}"
echo -e "${purple}[*] Crear Bot Y Token Bot : @BotFather${NC}"
echo -e "${purple}[*] Info de Id Telegram   : @MissRose_bot , Escriba /info${NC}"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
rm -rf /usr/bin/ddsdswl.session
rm -rf /usr/bin/kyt/var.txt
rm -rf /usr/bin/kyt/database.db
echo -e ""
read -e -p "[*] Introduce Tu Bot Token : " bottoken
read -e -p "[*] Introduce Tu Id Telegram :" admin

cat >/usr/bin/kyt/var.txt <<EOF
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAIN="$domain"
EOF

echo 'TEXT=$'"(cat /etc/notiftele)"'' > /etc/tele
echo "TIMES=10" >> /etc/tele
echo 'KEY=$'"(cat /etc/per/token)"'' >> /etc/tele

echo "$bottoken" > /etc/per/token
echo "$admin" > /etc/per/id
echo "$bottoken" > /usr/bin/token
echo "$admin" > /usr/bin/idchat
echo "$bottoken" > /etc/perlogin/token
echo "$admin" > /etc/perlogin/id
clear

echo "SHELL=/bin/sh" >/etc/cron.d/cekbot
echo "PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin" >>/etc/cron.d/cekbot
echo "*/1 * * * * root bash /usr/local/sbin/cekbot" >>/etc/cron.d/cekbot

cat > /usr/local/sbin/cekbot << END
nginx=$( systemctl status kyt | grep Active | awk '{print $3}' | sed 's/(//g' | sed 's/)//g' )
if [[ $nginx == "running" ]]; then
    echo -ne
else
    systemctl restart kyt
fi

kyt=$( systemctl status kyt | grep "TERM" | wc -l )
if [[ $kyt == "0" ]]; then
echo -ne
else
    systemctl restart kyt
fi
END

cat > /etc/systemd/system/kyt.service << END
[Unit]
Description=Simple kyt By - @Jerry_SBG
After=syslog.target network-online.target

[Service]
User=root
WorkingDirectory=/usr/bin
# USAR EL PYTHON DEL ENTORNO VIRTUAL
ExecStart=/opt/kyt-venv/bin/python3 -m kyt
Restart=on-failure

[Install]
WantedBy=multi-user.target
END
clear
systemctl daemon-reload &> /dev/null
systemctl enable kyt &> /dev/null
systemctl start kyt &> /dev/null
systemctl restart kyt &> /dev/null


echo "LISTO"
echo " Instalaciones Completadas, Escribe /start en tu Bot"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
menu
}
cd
if [ -e /usr/bin/kyt ]; then
echo -ne
else
install-bot
fi

#isi data     
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│      \033[1;37mPor favor seleccione su Opción      ${COLOR1}│${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭══════════════════════════════════════════╮${NC}"
echo -e "${COLOR1}│  [ 1 ]  \033[1;37mCAMBIAR BOT       ${NC}"
echo -e "${COLOR1}│  [ 2 ]  \033[1;37mACTUALIZAR BOT     ${NC}"
echo -e "${COLOR1}│  [ 3 ]  \033[1;37mBORRAR BOT     ${NC}"
echo -e "${COLOR1}│  [ ENTER ]  \033[1;37mREGRESAR AL MENU     ${NC}"
#echo -e "${COLOR1}│  [ 4 ]  \033[1;37mAÑADIR ADMINISTRADOR     ${NC}"
echo -e "${COLOR1}╰══════════════════════════════════════════╯${NC}"
until [[ $domain2 =~ ^[1-3]+$ ]]; do 
read -p "   Por favor seleccione los números 1 al 3 : " domain2
done

if [[ $domain2 == "1" ]]; then
clear
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${COLOR1} ${NC} ${COLBG1}                ${WH}• BOT PANEL •                  ${NC} ${COLOR1} $NC"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
echo -e "${purple}Tutorial Crear Bot Y Tu ID Telegram${NC}"
echo -e "${purple}[*] Crear Bot Y Token Bot : @BotFather${NC}"
echo -e "${purple}[*] Info de Id Telegram   : @MissRose_bot , Escribe /info${NC}"
echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
rm -rf /usr/bin/ddsdswl.session
rm -rf /usr/bin/kyt/var.txt
rm -rf /usr/bin/kyt/database.db
echo -e ""
read -e -p "[*] Introduce Tu Bot Token : " bottoken
read -e -p "[*] Introduce Tu Id Telegram :" admin

cat >/usr/bin/kyt/var.txt <<EOF
BOT_TOKEN="$bottoken"
ADMIN="$admin"
DOMAIN="$domain"
EOF

echo "$bottoken" > /etc/per/token
echo "$admin" > /etc/per/id
clear

cat > /etc/systemd/system/kyt.service << END
[Unit]
Description=Simple kyt By - @Jerry_SBG
After=syslog.target network-online.target

[Service]
User=root
WorkingDirectory=/usr/bin
# USAR EL PYTHON DEL ENTORNO VIRTUAL
ExecStart=/opt/kyt-venv/bin/python3 -m kyt
Restart=on-failure

[Install]
WantedBy=multi-user.target
END

systemctl daemon-reload &> /dev/null
systemctl stop kyt &> /dev/null
systemctl enable kyt &> /dev/null
systemctl start kyt &> /dev/null
systemctl restart kyt &> /dev/null

echo "LISTO"
echo " Instalaciones Completadas, Escribe /menu en tu Bot"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
menu
fi
if [[ $domain2 == "2" ]]; then
clear
cp -r /usr/bin/kyt/var.txt /usr/bin &> /dev/null
rm -rf /usr/bin/kyt.zip
rm -rf /usr/bin/kyt
sleep 2
cd /usr/bin
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/scripts/bot/bot.zip -O bot.zip
unzip -o -P SCr1PtByJS kyt.zip >/dev/null 2>&1
mv bot/* /usr/bin
chmod +x /usr/bin/*
rm -rf bot.zip
clear
wget -q --show-progress https://github.com/Internetjm/personalScript/raw/main/scripts/bot/kyt.zip -O kyt.zip
unzip -o -P SCr1PtByJS kyt.zip >/dev/null 2>&1
cd kyt
pip3 install -r kyt/requirements.txt
clear
cd /usr/bin/kyt/bot
chmod +x *
mv -f * /usr/bin
rm -rf /usr/bin/kyt/bot
rm -rf /usr/bin/*.zip
mv /usr/bin/var.txt /usr/bin/kyt
cd
clear

systemctl daemon-reload &> /dev/null
systemctl stop kyt &> /dev/null
systemctl enable kyt &> /dev/null
systemctl start kyt &> /dev/null
systemctl restart kyt &> /dev/null
clear
echo -e "BOT Telegram ACTUALIZADO CON EXITO"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
menu
fi

if [[ $domain2 == "3" ]]; then
clear
rm -rf /usr/bin/kyt
echo -e "BOT Telegram BORRADO CON EXITO"
read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
menu
fi
menu
#if [[ $domain2 == "4" ]]; then
#clear
#echo -e "${COLOR1}╭═════════════════════════════════════════════════╮${NC}"
#echo -e "${COLOR1} ${NC} ${COLBG1}                ${WH}• BOT PANEL •                  ${NC} ${COLOR1} $NC"
#echo -e "${COLOR1}╰═════════════════════════════════════════════════╯${NC}"
#echo -e ""
#read -e -p "[*] Ingrese su ID de Usuario : " user
#userke=$(cat /usr/bin/kyt/var.txt | wc -l)
#sed -i '/(ADMIN,))/a Hola	c.execute("INSERT INTO admin (user_id) VALUES (?)",(USER'""$userke""',))' /usr/bin/kyt/__init__.py
#cat >>/usr/bin/kyt/var.txt <<EOF
#USER${userke}=$user
#EOF
#sed -i "s/Hola//g" /usr/bin/kyt/__init__.py

#echo 'curl -s --max-time $TIMES -d "chat_id='""$user""'&disable_web_page_preview=1&text=$TEXT&parse_mode=html" https://api.telegram.org/bot$KEY/sendMessage >/dev/null' >> /etc/tele
#clear
#echo -e "BOT Telegram con Éxito AGREGAR Administrador"
#rm -rf /usr/bin/ddsdswl.session
#rm -rf /usr/bin/kyt/database.db
#systemctl restart kyt 
#read -n 1 -s -r -p "Presione cualquier tecla para volver al MENU"
#menu
#fi
