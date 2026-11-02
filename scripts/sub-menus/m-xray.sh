#!/usr/bin/env bash
# ──────────────────────────────────────────────────────────────────────────────
#  XRAY / V2RAY CORE — JM SCRIPT
#  Instalación guiada: pide el dominio V2Ray, emite el certificado, instala Xray,
#  genera una config completa (VMess/VLESS/Trojan/Shadowsocks WS + gRPC) compatible
#  con los menús 02/03/04/05 y la deja activa.
# ──────────────────────────────────────────────────────────────────────────────
set -u

XRAY_BIN="/usr/local/bin/xray"
XRAY_DIR="/etc/xray"
XRAY_CONFIG="${XRAY_DIR}/config.json"
XRAY_SERVICE="xray.service"
XRAY_UNIT="/etc/systemd/system/${XRAY_SERVICE}"
XRAY_ASSETS="/usr/local/share/xray"
CERT="${XRAY_DIR}/xray.crt"
KEY="${XRAY_DIR}/xray.key"
NGINX_XRAY_CONF="/etc/nginx/conf.d/xray.conf"
CERT_HOOK="/usr/local/bin/xray-cert-hook.sh"
ACME="/root/.acme.sh/acme.sh"
# Servicios que pueden ocupar el puerto 80 y hay que parar un momento para emitir el certificado
PORT80_UNITS="nginx haproxy ws ws-stunnel ws-dropbear ws-ovpn sshws jm-proxy apache2 lighttpd caddy"

C1=$'\033[1;94m'; WH=$'\033[1;37m'; RD=$'\033[1;31m'; GN=$'\033[1;32m'; YL=$'\033[1;33m'; NC=$'\033[0m'

DOMAIN=""
TLS_MODE="acme"     # acme | selfsigned
STOPPED=()

# ── utilidades ────────────────────────────────────────────────────────────────
ok()   { echo -e " ${GN}✔${NC} $*"; }
warn() { echo -e " ${YL}!${NC} $*"; }
err()  { echo -e " ${RD}✖${NC} $*"; }
step() { echo -e "\n${C1}══ ${WH}$*${C1} ══${NC}"; }

box() {
    echo -e "${C1}╭══════════════════════════════════════════════════╮${NC}"
    printf "${C1}│${WH} %-48s ${C1}│${NC}\n" "$1"
    echo -e "${C1}╰══════════════════════════════════════════════════╯${NC}"
}

ask_yn() {  # ask_yn "pregunta" -> 0 si s/S/y/Y
    local a
    read -r -p " $1 [s/N]: " a
    [[ "$a" =~ ^[sSyY]$ ]]
}

back_to_menu() {
    if command -v menu >/dev/null 2>&1; then
        exec menu
    fi
    exit 0
}

pause_menu() {
    echo
    read -r -n 1 -s -p " Presione cualquier tecla para regresar..."
    echo
}

need_root() {
    if [ "$(id -u)" -ne 0 ]; then
        err "Esta operación requiere root."
        return 1
    fi
}

is_ip()     { [[ "$1" =~ ^([0-9]{1,3}\.){3}[0-9]{1,3}$ ]]; }
is_domain() { [[ "$1" =~ ^([a-zA-Z0-9]([a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?\.)+[a-zA-Z]{2,}$ ]]; }

get_ip() {
    local u ip
    for u in https://ipv4.icanhazip.com https://ipinfo.io/ip https://api.ipify.org; do
        ip=$(curl -4 -fsS --max-time 6 "$u" 2>/dev/null | tr -d '[:space:]')
        if is_ip "$ip"; then echo "$ip"; return; fi
    done
    hostname -I 2>/dev/null | awk '{print $1}'
}

port_listening() {  # port_listening 443
    ss -H -ltn 2>/dev/null | awk '{print $4}' | grep -Eq "[:.]$1\$"
}

# ── dominio ───────────────────────────────────────────────────────────────────
ask_domain() {
    local cur ip dip
    cur=$(head -n1 "${XRAY_DIR}/domain" 2>/dev/null | tr -d '[:space:]')
    ip=$(get_ip)

    clear
    box "DOMINIO V2RAY"
    echo -e " ${WH}IP de este VPS : ${GN}${ip:-desconocida}${NC}"
    echo -e " ${WH}Dominio actual : ${GN}${cur:-ninguno}${NC}"
    echo -e " ${YL}El dominio/subdominio debe apuntar (registro A) a la IP del VPS.${NC}"
    echo -e " ${YL}Si usas Cloudflare, deja la nube en GRIS (solo DNS) para emitir el certificado.${NC}"
    echo

    while true; do
        read -r -p " Dominio V2Ray${cur:+ [Enter = ${cur}]}: " DOMAIN
        DOMAIN=${DOMAIN:-$cur}
        DOMAIN=$(echo "$DOMAIN" | tr 'A-Z' 'a-z' | tr -d '[:space:]')
        DOMAIN=${DOMAIN#http://}; DOMAIN=${DOMAIN#https://}; DOMAIN=${DOMAIN%%/*}

        if [ -z "$DOMAIN" ]; then
            err "Debes ingresar un dominio."
        elif is_ip "$DOMAIN"; then
            warn "Es una IP: se usará certificado AUTOFIRMADO (en el cliente activa 'allowInsecure')."
            if ask_yn "¿Continuar con IP?"; then TLS_MODE="selfsigned"; break; fi
        elif is_domain "$DOMAIN"; then
            dip=$(getent ahostsv4 "$DOMAIN" 2>/dev/null | awk 'NR==1{print $1}')
            if [ -z "$dip" ]; then
                warn "El dominio ${DOMAIN} todavía no resuelve a ninguna IP."
                ask_yn "¿Continuar de todos modos? (el certificado fallará si el DNS no está listo)" || continue
            elif [ -n "$ip" ] && [ "$dip" != "$ip" ]; then
                warn "${DOMAIN} apunta a ${dip} pero este VPS es ${ip}."
                ask_yn "¿Continuar de todos modos?" || continue
            else
                ok "DNS correcto: ${DOMAIN} → ${dip}"
            fi
            TLS_MODE="acme"; break
        else
            err "Dominio inválido. Ejemplo: v2.midominio.com"
        fi
    done
}

save_domain() {
    mkdir -p "${XRAY_DIR}" /var/lib
    echo "${DOMAIN}" > "${XRAY_DIR}/domain"
    echo "${DOMAIN}" > "${XRAY_DIR}/scdomain"
    echo "IP=${DOMAIN}" > /var/lib/ipvps.conf
    ok "Dominio guardado: ${DOMAIN}"
}

# ── dependencias y binario ────────────────────────────────────────────────────
install_deps() {
    step "Dependencias"
    export DEBIAN_FRONTEND=noninteractive
    local pkgs=() c
    for c in curl unzip socat openssl; do command -v "$c" >/dev/null 2>&1 || pkgs+=("$c"); done
    command -v crontab >/dev/null 2>&1 || pkgs+=(cron)
    command -v ss >/dev/null 2>&1 || pkgs+=(iproute2)
    if ! command -v nginx >/dev/null 2>&1; then pkgs+=(nginx); NGINX_FRESH=1; fi
    if [ "${#pkgs[@]}" -gt 0 ]; then
        echo " Instalando: ${pkgs[*]}"
        apt-get update -qq >/dev/null 2>&1
        if ! apt-get install -y -qq "${pkgs[@]}" >/dev/null 2>&1; then
            err "No se pudieron instalar: ${pkgs[*]}"
            return 1
        fi
    fi
    ok "Dependencias listas"
}

download_xray() {
    step "Binario Xray"
    local arch tmp url
    case "$(uname -m)" in
        x86_64|amd64)  arch="64" ;;
        aarch64|arm64) arch="arm64-v8a" ;;
        armv7l)        arch="arm32-v7a" ;;
        *) err "Arquitectura no soportada: $(uname -m)"; return 1 ;;
    esac
    url="https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-${arch}.zip"
    tmp=$(mktemp -d)
    echo " Descargando Xray (${arch})..."
    if curl -fL --retry 3 --connect-timeout 15 -o "${tmp}/xray.zip" "$url" 2>/dev/null \
       && unzip -qo "${tmp}/xray.zip" -d "${tmp}" && [ -f "${tmp}/xray" ]; then
        systemctl stop "${XRAY_SERVICE}" >/dev/null 2>&1
        install -m 755 "${tmp}/xray" "${XRAY_BIN}"
        mkdir -p "${XRAY_ASSETS}"
        cp -f "${tmp}"/geo*.dat "${XRAY_ASSETS}/" 2>/dev/null
    else
        warn "Descarga directa falló, probando el instalador oficial..."
        if ! bash -c "$(curl -fsSL https://github.com/XTLS/Xray-install/raw/main/install-release.sh)" @ install >/dev/null 2>&1; then
            rm -rf "$tmp"
            err "No se pudo descargar Xray. Revisa la conexión del VPS a GitHub."
            return 1
        fi
    fi
    rm -rf "$tmp"
    if ! "${XRAY_BIN}" version >/dev/null 2>&1; then
        err "El binario de Xray no funciona."
        return 1
    fi
    ok "$("${XRAY_BIN}" version | head -n1)"
}

write_unit() {
    # Se reemplaza cualquier drop-in del instalador oficial que cambie la ruta de la config.
    rm -rf /etc/systemd/system/xray.service.d /etc/systemd/system/xray@.service.d
    mkdir -p /var/log/xray "${XRAY_ASSETS}"
    cat > "${XRAY_UNIT}" <<EOF
[Unit]
Description=Xray Service (JM SCRIPT)
After=network.target nss-lookup.target

[Service]
User=root
Environment=XRAY_LOCATION_ASSET=${XRAY_ASSETS}
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=${XRAY_BIN} run -config ${XRAY_CONFIG}
Restart=on-failure
RestartPreventExitStatus=23
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF
    systemctl daemon-reload
    ok "Servicio systemd escrito"
}

# ── certificado ───────────────────────────────────────────────────────────────
write_cert_hook() {
    cat > "${CERT_HOOK}" <<'EOF'
#!/bin/bash
# Se ejecuta tras emitir/renovar el certificado: regenera los .pem de HAProxy y reinicia servicios.
C=/etc/xray/xray.crt; K=/etc/xray/xray.key
if [ -d /etc/haproxy ]; then
    for f in $(grep -ho '/etc/haproxy/[^ ]*\.pem' /etc/haproxy/haproxy.cfg 2>/dev/null | sort -u) /etc/haproxy/funny.pem /etc/haproxy/jm-script.pem; do
        cat "$C" "$K" > "$f" 2>/dev/null
    done
fi
for s in xray nginx haproxy; do
    systemctl is-active --quiet "$s" 2>/dev/null && systemctl restart "$s" >/dev/null 2>&1
done
exit 0
EOF
    chmod 755 "${CERT_HOOK}"
}

write_renew_script() {
    cat > /usr/local/bin/ssl_renew.sh <<EOF
#!/bin/bash
# Renovación automática del certificado (modo standalone: necesita el puerto 80 libre un instante)
STOPPED=""
for u in ${PORT80_UNITS}; do
    if systemctl is-active --quiet "\$u" 2>/dev/null; then systemctl stop "\$u"; STOPPED="\$STOPPED \$u"; fi
done
"/root/.acme.sh"/acme.sh --cron --home "/root/.acme.sh" &> /root/renew_ssl.log
for u in \$STOPPED; do systemctl start "\$u"; done
EOF
    chmod 755 /usr/local/bin/ssl_renew.sh
    if ! crontab -l 2>/dev/null | grep -q 'ssl_renew.sh'; then
        (crontab -l 2>/dev/null; echo "15 03 */3 * * /usr/local/bin/ssl_renew.sh") | crontab -
    fi
}

stop_port80() {
    STOPPED=()
    local u
    for u in $PORT80_UNITS; do
        if systemctl is-active --quiet "$u" 2>/dev/null; then
            systemctl stop "$u" >/dev/null 2>&1
            STOPPED+=("$u")
        fi
    done
    sleep 1
}

start_port80() {
    local u
    [ "${#STOPPED[@]}" -gt 0 ] || return 0
    for u in "${STOPPED[@]}"; do systemctl start "$u" >/dev/null 2>&1; done
    STOPPED=()
}

issue_cert() {
    step "Certificado TLS (${DOMAIN})"
    mkdir -p "${XRAY_DIR}"
    write_cert_hook

    if [ "$TLS_MODE" = "selfsigned" ]; then
        openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
            -keyout "${KEY}" -out "${CERT}" -subj "/CN=${DOMAIN}" \
            -addext "subjectAltName=IP:${DOMAIN}" >/dev/null 2>&1 \
        || openssl req -x509 -nodes -newkey rsa:2048 -days 3650 \
            -keyout "${KEY}" -out "${CERT}" -subj "/CN=${DOMAIN}" >/dev/null 2>&1
        chmod 644 "${CERT}"; chmod 600 "${KEY}"
        "${CERT_HOOK}"
        ok "Certificado autofirmado creado (10 años)"
        return 0
    fi

    mkdir -p /root/.acme.sh
    if [ ! -x "${ACME}" ]; then
        curl -fsSL https://raw.githubusercontent.com/acmesh-official/acme.sh/master/acme.sh -o "${ACME}" \
            || { err "No se pudo descargar acme.sh"; return 1; }
        chmod +x "${ACME}"
    fi
    "${ACME}" --set-default-ca --server letsencrypt >/dev/null 2>&1

    stop_port80
    if port_listening 80; then
        err "El puerto 80 sigue ocupado, no se puede validar el dominio:"
        ss -ltnp 'sport = :80' 2>/dev/null | sed 's/^/    /'
        start_port80
        return 1
    fi

    echo " Solicitando certificado a Let's Encrypt..."
    "${ACME}" --issue -d "${DOMAIN}" --standalone --keylength ec-256 --server letsencrypt
    local rc=$?
    start_port80
    # rc 2 = el certificado ya está vigente (no es un error)
    if [ $rc -ne 0 ] && [ $rc -ne 2 ]; then
        err "No se pudo emitir el certificado."
        echo -e "   ${YL}• Verifica que ${DOMAIN} apunte a la IP de este VPS (Cloudflare en gris)."
        echo -e "   • Let's Encrypt limita a 5 certificados/semana por dominio: prueba otro subdominio.${NC}"
        return 1
    fi
    "${ACME}" --installcert -d "${DOMAIN}" --ecc \
        --fullchain-file "${CERT}" --key-file "${KEY}" \
        --reloadcmd "${CERT_HOOK}" >/dev/null 2>&1
    if [ ! -s "${CERT}" ] || [ ! -s "${KEY}" ]; then
        err "El certificado no quedó instalado en ${XRAY_DIR}."
        return 1
    fi
    chmod 644 "${CERT}"; chmod 600 "${KEY}"
    write_renew_script
    ok "Certificado instalado (renovación automática cada 3 días si toca)"
}

# ── configuración Xray ────────────────────────────────────────────────────────
config_has_accounts_layout() {
    [ -s "${XRAY_CONFIG}" ] \
      && grep -q '^#vmessgrpc$' "${XRAY_CONFIG}" && grep -q '^#vlessgrpc$' "${XRAY_CONFIG}" \
      && grep -q '^#trojangrpc$' "${XRAY_CONFIG}" && grep -q '^#ssgrpc$' "${XRAY_CONFIG}"
}

write_config() {
    step "Configuración Xray"
    if config_has_accounts_layout; then
        ok "Config existente compatible con los menús de cuentas: se conserva (cuentas intactas)"
        return 0
    fi

    mkdir -p "${XRAY_DIR}" /var/log/xray
    if [ -s "${XRAY_CONFIG}" ]; then
        local bak="${XRAY_CONFIG}.bak.$(date +%Y%m%d%H%M%S)"
        cp -a "${XRAY_CONFIG}" "$bak"
        warn "Config anterior sin estructura de cuentas, respaldada en ${bak}"
    fi

    local patch uuid
    patch=$(tr -d '\r\n' < "${XRAY_DIR}/patch" 2>/dev/null)
    if [[ ! "$patch" =~ ^[A-Za-z0-9_-]+$ ]]; then
        patch="jm-script"
        echo "$patch" > "${XRAY_DIR}/patch"
    fi
    uuid=$(cat /proc/sys/kernel/random/uuid)

    # Los marcadores (#vmess, #vmessgrpc, ...) los usan los menús para agregar/borrar cuentas.
    cat > "${XRAY_CONFIG}" <<'JSON'
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "warning"
  },
  "api": {
    "tag": "api",
    "services": ["HandlerService", "LoggerService", "StatsService"]
  },
  "stats": {},
  "policy": {
    "levels": { "0": { "statsUserDownlink": true, "statsUserUplink": true } },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  },
  "inbounds": [
    {
      "listen": "127.0.0.1",
      "port": 10085,
      "protocol": "dokodemo-door",
      "settings": { "address": "127.0.0.1" },
      "tag": "api"
    },
    {
      "listen": "127.0.0.1",
      "port": 14016,
      "protocol": "vless",
      "tag": "vless-ws",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "__UUID__",
            "email": "default-vless"
#vless
          }
        ]
      },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/vl-__PATCH__" } }
    },
    {
      "listen": "127.0.0.1",
      "port": 23456,
      "protocol": "vmess",
      "tag": "vmess-ws",
      "settings": {
        "clients": [
          {
            "id": "__UUID__",
            "alterId": 0,
            "email": "default-vmess"
#vmess
          }
        ]
      },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/vm-__PATCH__" } }
    },
    {
      "listen": "127.0.0.1",
      "port": 25432,
      "protocol": "trojan",
      "tag": "trojan-ws",
      "settings": {
        "clients": [
          {
            "password": "__UUID__",
            "email": "default-trojan"
#trojanws
          }
        ]
      },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/tr-__PATCH__" } }
    },
    {
      "listen": "127.0.0.1",
      "port": 30300,
      "protocol": "shadowsocks",
      "tag": "ss-ws",
      "settings": {
        "network": "tcp,udp",
        "clients": [
          {
            "method": "aes-128-gcm",
            "password": "__UUID__",
            "email": "default-ss"
#ssws
          }
        ]
      },
      "streamSettings": { "network": "ws", "wsSettings": { "path": "/ss-__PATCH__" } }
    },
    {
      "listen": "127.0.0.1",
      "port": 24456,
      "protocol": "vless",
      "tag": "vless-grpc",
      "settings": {
        "decryption": "none",
        "clients": [
          {
            "id": "__UUID__",
            "email": "default-vless-grpc"
#vlessgrpc
          }
        ]
      },
      "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "vlgr-__PATCH__" } }
    },
    {
      "listen": "127.0.0.1",
      "port": 31234,
      "protocol": "vmess",
      "tag": "vmess-grpc",
      "settings": {
        "clients": [
          {
            "id": "__UUID__",
            "alterId": 0,
            "email": "default-vmess-grpc"
#vmessgrpc
          }
        ]
      },
      "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "vmgr-__PATCH__" } }
    },
    {
      "listen": "127.0.0.1",
      "port": 33456,
      "protocol": "trojan",
      "tag": "trojan-grpc",
      "settings": {
        "clients": [
          {
            "password": "__UUID__",
            "email": "default-trojan-grpc"
#trojangrpc
          }
        ]
      },
      "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "trgr-__PATCH__" } }
    },
    {
      "listen": "127.0.0.1",
      "port": 30310,
      "protocol": "shadowsocks",
      "tag": "ss-grpc",
      "settings": {
        "network": "tcp,udp",
        "clients": [
          {
            "method": "aes-128-gcm",
            "password": "__UUID__",
            "email": "default-ss-grpc"
#ssgrpc
          }
        ]
      },
      "streamSettings": { "network": "grpc", "grpcSettings": { "serviceName": "ssgr-__PATCH__" } }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
  ],
  "routing": {
    "rules": [
      { "type": "field", "inboundTag": ["api"], "outboundTag": "api" },
      { "type": "field", "ip": ["10.0.0.0/8", "172.16.0.0/12", "192.168.0.0/16"], "outboundTag": "blocked" },
      { "type": "field", "protocol": ["bittorrent"], "outboundTag": "blocked" }
    ]
  }
}
JSON
    sed -i "s/__UUID__/${uuid}/g; s/__PATCH__/${patch}/g" "${XRAY_CONFIG}"
    chmod 600 "${XRAY_CONFIG}"
    ok "Config nueva escrita (path /vm-${patch}, /vl-${patch}, /tr-${patch}, /ss-${patch})"
}

validate_config() {
    local out
    if ! out=$("${XRAY_BIN}" run -test -config "${XRAY_CONFIG}" 2>&1); then
        err "La configuración de Xray no es válida:"
        echo "$out" | tail -n 15 | sed 's/^/    /'
        return 1
    fi
    ok "Configuración válida"
}

# ── nginx (puente WS/gRPC hacia Xray) ─────────────────────────────────────────
setup_nginx() {
    step "Nginx"
    command -v nginx >/dev/null 2>&1 || { warn "nginx no está instalado, se omite"; return 0; }

    if [ -f "${NGINX_XRAY_CONF}" ]; then
        # Layout ya existente: solo se actualiza el dominio, no se toca nada más.
        if [ -n "${OLD_DOMAIN:-}" ] && [ "${OLD_DOMAIN}" != "${DOMAIN}" ]; then
            sed -i "s/${OLD_DOMAIN//./\\.}/${DOMAIN}/g" "${NGINX_XRAY_CONF}"
            ok "Dominio actualizado en ${NGINX_XRAY_CONF}"
        else
            ok "${NGINX_XRAY_CONF} ya existe, se conserva"
        fi
    else
        local patch tls_listen=""
        patch=$(tr -d '\r\n' < "${XRAY_DIR}/patch")
        # nginx del paquete trae un sitio por defecto en :80 que choca con los proxies WS
        if [ "${NGINX_FRESH:-0}" = "1" ]; then rm -f /etc/nginx/sites-enabled/default; fi
        if ! port_listening 443; then tls_listen="443"
        elif ! port_listening 8443; then tls_listen="8443"; fi

        {
            echo "server {"
            echo "    listen 81 http2;"
            [ -n "$tls_listen" ] && echo "    listen ${tls_listen} ssl http2;"
            cat <<'EOF'
    server_name __DOMAIN__;
    ssl_certificate     /etc/xray/xray.crt;
    ssl_certificate_key /etc/xray/xray.key;
    ssl_protocols TLSv1.2 TLSv1.3;

    location / { return 404; }

    location /vl-__PATCH__ { proxy_pass http://127.0.0.1:14016; include /etc/nginx/xray-ws.inc; }
    location /vm-__PATCH__ { proxy_pass http://127.0.0.1:23456; include /etc/nginx/xray-ws.inc; }
    location /tr-__PATCH__ { proxy_pass http://127.0.0.1:25432; include /etc/nginx/xray-ws.inc; }
    location /ss-__PATCH__ { proxy_pass http://127.0.0.1:30300; include /etc/nginx/xray-ws.inc; }

    location /vlgr-__PATCH__ { grpc_pass grpc://127.0.0.1:24456; include /etc/nginx/xray-grpc.inc; }
    location /vmgr-__PATCH__ { grpc_pass grpc://127.0.0.1:31234; include /etc/nginx/xray-grpc.inc; }
    location /trgr-__PATCH__ { grpc_pass grpc://127.0.0.1:33456; include /etc/nginx/xray-grpc.inc; }
    location /ssgr-__PATCH__ { grpc_pass grpc://127.0.0.1:30310; include /etc/nginx/xray-grpc.inc; }
}
EOF
        } > "${NGINX_XRAY_CONF}"
        sed -i "s/__DOMAIN__/${DOMAIN}/g; s/__PATCH__/${patch}/g" "${NGINX_XRAY_CONF}"

        cat > /etc/nginx/xray-ws.inc <<'EOF'
proxy_http_version 1.1;
proxy_set_header Upgrade $http_upgrade;
proxy_set_header Connection "upgrade";
proxy_set_header Host $host;
proxy_set_header X-Real-IP $remote_addr;
proxy_read_timeout 1h;
proxy_send_timeout 1h;
proxy_redirect off;
EOF
        cat > /etc/nginx/xray-grpc.inc <<'EOF'
grpc_set_header Host $host;
grpc_set_header X-Real-IP $remote_addr;
client_max_body_size 0;
grpc_read_timeout 1h;
grpc_send_timeout 1h;
EOF
        if nginx -t >/dev/null 2>&1; then
            ok "Nginx: puerto 81 (WS/gRPC sin TLS)${tls_listen:+ y ${tls_listen} (TLS)}"
        else
            err "nginx -t falló; se elimina ${NGINX_XRAY_CONF} para no romper nginx:"
            nginx -t 2>&1 | tail -n 5 | sed 's/^/    /'
            rm -f "${NGINX_XRAY_CONF}"
            return 1
        fi
    fi
    systemctl enable nginx >/dev/null 2>&1
    systemctl restart nginx >/dev/null 2>&1 && ok "nginx reiniciado" || warn "nginx no pudo reiniciar (revisa: nginx -t)"
}

# ── flujo de instalación ──────────────────────────────────────────────────────
start_and_verify() {
    step "Arranque"
    systemctl daemon-reload
    systemctl enable "${XRAY_SERVICE}" >/dev/null 2>&1
    systemctl restart "${XRAY_SERVICE}"
    sleep 2
    if ! systemctl is-active --quiet "${XRAY_SERVICE}"; then
        err "Xray no arrancó. Últimas líneas del log:"
        journalctl -u "${XRAY_SERVICE}" -n 15 --no-pager 2>/dev/null | sed 's/^/    /'
        return 1
    fi
    ok "Xray activo"
    local p miss=0
    for p in 14016 23456 25432 30300 24456 31234 33456 30310; do
        port_listening "$p" || { warn "Puerto interno ${p} sin escuchar"; miss=1; }
    done
    [ $miss -eq 0 ] && ok "8 inbounds escuchando (WS + gRPC)"
    if systemctl is-active --quiet haproxy 2>/dev/null; then
        systemctl restart haproxy >/dev/null 2>&1 && ok "haproxy reiniciado"
    fi
}

summary() {
    local patch
    patch=$(tr -d '\r\n' < "${XRAY_DIR}/patch" 2>/dev/null)
    echo
    box "V2RAY LISTO"
    echo -e " ${WH}Dominio   : ${GN}${DOMAIN}${NC}"
    echo -e " ${WH}Modo TLS  : ${GN}$([ "$TLS_MODE" = selfsigned ] && echo autofirmado || echo "Let's Encrypt")${NC}"
    echo -e " ${WH}Paths WS  : ${GN}/vm-${patch}  /vl-${patch}  /tr-${patch}  /ss-${patch}${NC}"
    echo -e " ${WH}gRPC      : ${GN}vmgr-${patch}  vlgr-${patch}  trgr-${patch}  ssgr-${patch}${NC}"
    echo -e " ${WH}Siguiente : ${YL}crea cuentas en el menú: 02 VMESS · 03 VLESS · 04 SHADOW · 05 TROJAN${NC}"
}

install_xray() {
    need_root || return 1
    OLD_DOMAIN=$(head -n1 "${XRAY_DIR}/domain" 2>/dev/null | tr -d '[:space:]')
    NGINX_FRESH=0
    ask_domain
    save_domain
    install_deps   || return 1
    download_xray  || return 1
    write_unit
    issue_cert     || { err "Instalación detenida: sin certificado no se puede continuar."; return 1; }
    write_config
    validate_config || return 1
    setup_nginx
    start_and_verify || return 1
    summary
}

change_domain() {
    need_root || return 1
    [ -x "${XRAY_BIN}" ] || { err "Xray no está instalado. Usa la opción 1."; return 1; }
    OLD_DOMAIN=$(head -n1 "${XRAY_DIR}/domain" 2>/dev/null | tr -d '[:space:]')
    NGINX_FRESH=0
    ask_domain
    save_domain
    issue_cert || return 1
    setup_nginx
    systemctl restart "${XRAY_SERVICE}" >/dev/null 2>&1
    systemctl is-active --quiet "${XRAY_SERVICE}" && ok "Xray reiniciado con el nuevo dominio"
    systemctl is-active --quiet haproxy 2>/dev/null && systemctl restart haproxy >/dev/null 2>&1
    summary
}

uninstall_xray() {
    need_root || return 1
    ask_yn "¿Desinstalar Xray? (se conserva ${XRAY_CONFIG} y los certificados)" || { echo " Cancelado."; return 0; }
    systemctl disable --now "${XRAY_SERVICE}" >/dev/null 2>&1
    rm -f "${XRAY_UNIT}" "${XRAY_BIN}"
    rm -rf /etc/systemd/system/xray.service.d
    systemctl daemon-reload
    ok "Xray desinstalado. Config conservada en ${XRAY_CONFIG}"
}

show_status() {
    systemctl status "${XRAY_SERVICE}" --no-pager --full 2>&1 | head -n 14
    echo
    if [ -x "${XRAY_BIN}" ]; then
        echo -e " ${WH}Versión : ${GN}$("${XRAY_BIN}" version | head -n1)${NC}"
        validate_config
    else
        err "Binario de Xray no encontrado (${XRAY_BIN})"
    fi
    echo -e " ${WH}Dominio : ${GN}$(cat "${XRAY_DIR}/domain" 2>/dev/null || echo ninguno)${NC}"
    if [ -s "${CERT}" ]; then
        echo -e " ${WH}Cert    : ${GN}$(openssl x509 -enddate -noout -in "${CERT}" 2>/dev/null | sed 's/notAfter=/vence /')${NC}"
    else
        warn "Sin certificado en ${CERT}"
    fi
}

show_xray_ports() {
    ss -lntup 2>/dev/null | grep -E 'xray|:(14016|23456|25432|30300|24456|31234|33456|30310|10085|81|443|8443) ' || echo " (sin puertos de Xray escuchando)"
}

# Modo no interactivo: el instalador principal lo llama como "m-xray --install"
if [ "${1:-}" = "--install" ]; then
    install_xray
    exit $?
fi

# ── menú ──────────────────────────────────────────────────────────────────────
while true; do
    clear
    box "XRAY / V2RAY CORE"
    if systemctl is-active --quiet "${XRAY_SERVICE}" 2>/dev/null; then
        echo -e " ${WH}Estado : ${GN}ACTIVO${NC}   ${WH}Dominio : ${GN}$(cat "${XRAY_DIR}/domain" 2>/dev/null || echo -)${NC}"
    else
        echo -e " ${WH}Estado : ${RD}INACTIVO${NC}   ${WH}Dominio : ${GN}$(cat "${XRAY_DIR}/domain" 2>/dev/null || echo -)${NC}"
    fi
    echo
    echo -e " ${C1}[1]${NC} Instalar / reparar V2Ray (pide dominio)"
    echo -e " ${C1}[2]${NC} Cambiar dominio V2Ray + certificado"
    echo -e " ${C1}[3]${NC} Activar"
    echo -e " ${C1}[4]${NC} Desactivar"
    echo -e " ${C1}[5]${NC} Reiniciar"
    echo -e " ${C1}[6]${NC} Ver estado y validar configuración"
    echo -e " ${C1}[7]${NC} Ver logs"
    echo -e " ${C1}[8]${NC} Ver puertos"
    echo -e " ${C1}[9]${NC} Desinstalar"
    echo -e " ${C1}[0]${NC} Regresar"
    echo
    read -r -p " Seleccione una opción: " option
    case "${option}" in
        1) install_xray;   pause_menu ;;
        2) change_domain;  pause_menu ;;
        3) systemctl enable --now "${XRAY_SERVICE}" && ok "Xray activado"; pause_menu ;;
        4) systemctl disable --now "${XRAY_SERVICE}" && ok "Xray desactivado"; pause_menu ;;
        5) systemctl restart "${XRAY_SERVICE}" && ok "Xray reiniciado"; pause_menu ;;
        6) show_status;    pause_menu ;;
        7) journalctl -u "${XRAY_SERVICE}" -n 60 --no-pager; tail -n 20 /var/log/xray/error.log 2>/dev/null; pause_menu ;;
        8) show_xray_ports; pause_menu ;;
        9) uninstall_xray; pause_menu ;;
        0) back_to_menu ;;
        *) echo " Opción inválida."; sleep 1 ;;
    esac
done
