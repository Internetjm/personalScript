#!/bin/bash
# JM_INSTALLER Installer — Versión GitHub (sin KEY ni servidor externo)
# Instala: Xray + Proxies SSH (Python) + Dropbear + BadVPN + OpenVPN + iptables

BIBlue='\033[1;94m'
BGCOLOR='\e[1;97;101m'
NC='\033[0m'
RED='\033[31m'
YELLOW='\033[33m'
GREEN='\033[32m'
purple='\033[1;95m'

# Solo ejecutar con el argumento correcto
[[ "$1" != "--jm-script" ]] && echo "Uso: $0 --jm-script" && exit 1

clear
echo -e "  ${BIBlue}╭══════════════════════════════════════╮${NC}"
echo -e "  ${BIBlue}│ ${BGCOLOR}       INSTALANDO jmscript VPN SERVER    ${NC}${BIBlue} │${NC}"
echo -e "  ${BIBlue}╰══════════════════════════════════════╯${NC}"
sleep 1

MYIP=$(curl -s ipv4.icanhazip.com 2>/dev/null || curl -s ifconfig.me 2>/dev/null || hostname -I | awk '{print $1}')
UUID=$(cat /proc/sys/kernel/random/uuid 2>/dev/null || python3 -c "import uuid; print(uuid.uuid4())")

mkdir -p /etc/xray
echo "${MYIP}" > /etc/xray/domain

# ─── APT PACKAGES ────────────────────────────────────────────────────────────
echo -e "${YELLOW}[1/8]${NC} Instalando paquetes..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y -qq \
    curl wget unzip tar gzip \
    python3 python3-pip \
    dropbear \
    openvpn easy-rsa \
    fail2ban \
    badvpn \
    net-tools iptables \
    uuid-runtime \
    openssl ca-certificates \
    nodejs npm \
    2>/dev/null || true

echo -e "${GREEN}  ✅ Paquetes instalados${NC}"

# ─── XRAY ────────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/8]${NC} Instalando Xray..."
mkdir -p /etc/xray /var/log/xray

XRAY_VER=$(curl -fsSL "https://api.github.com/repos/XTLS/Xray-core/releases/latest" 2>/dev/null \
    | grep '"tag_name"' | sed 's/.*"v\([^"]*\)".*/\1/' | head -1)
[[ -z "$XRAY_VER" ]] && XRAY_VER="25.4.30"

XRAY_URL="https://github.com/XTLS/Xray-core/releases/download/v${XRAY_VER}/Xray-linux-64.zip"
wget -q --timeout=60 "$XRAY_URL" -O /tmp/xray.zip 2>/dev/null
if [[ -f /tmp/xray.zip ]]; then
    unzip -o /tmp/xray.zip xray -d /usr/local/bin/ >/dev/null 2>&1
    chmod +x /usr/local/bin/xray
    rm -f /tmp/xray.zip
    echo -e "${GREEN}  ✅ Xray ${XRAY_VER} instalado${NC}"
else
    echo -e "${RED}  ✖ Error descargando Xray${NC}"
fi

# Config Xray
cat > /etc/xray/config.json << XRAYEOF
{
  "log": {
    "access": "/var/log/xray/access.log",
    "error": "/var/log/xray/error.log",
    "loglevel": "info"
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
      "port": "14016",
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [ { "id": "${UUID}" } ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/vl-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "23456",
      "protocol": "vmess",
      "settings": {
        "clients": [ { "id": "${UUID}", "alterId": 0 } ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/vm-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "28406",
      "protocol": "vmess",
      "settings": {
        "clients": [ { "id": "${UUID}", "alterId": 0 } ]
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/w-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "25432",
      "protocol": "trojan",
      "settings": {
        "decryption": "none",
        "clients": [ { "password": "${UUID}" } ],
        "udp": true
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/tr-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "30300",
      "protocol": "shadowsocks",
      "settings": {
        "clients": [ { "method": "aes-128-gcm", "password": "${UUID}" } ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "ws",
        "wsSettings": { "path": "/ss-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "24456",
      "protocol": "vless",
      "settings": {
        "decryption": "none",
        "clients": [ { "id": "${UUID}" } ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": { "serviceName": "vlgr-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "31234",
      "protocol": "vmess",
      "settings": {
        "clients": [ { "id": "${UUID}", "alterId": 0 } ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": { "serviceName": "vmgr-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "33456",
      "protocol": "trojan",
      "settings": {
        "decryption": "none",
        "clients": [ { "password": "${UUID}" } ]
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": { "serviceName": "trgr-jm-script" }
      }
    },
    {
      "listen": "127.0.0.1",
      "port": "30310",
      "protocol": "shadowsocks",
      "settings": {
        "clients": [ { "method": "aes-128-gcm", "password": "${UUID}" } ],
        "network": "tcp,udp"
      },
      "streamSettings": {
        "network": "grpc",
        "grpcSettings": { "serviceName": "ssgr-jm-script" }
      }
    }
  ],
  "outbounds": [
    { "protocol": "freedom", "settings": {} },
    { "protocol": "blackhole", "settings": {}, "tag": "blocked" }
  ],
  "routing": {
    "rules": [
      {
        "type": "field",
        "ip": ["10.0.0.0/8","172.16.0.0/12","192.168.0.0/16"],
        "outboundTag": "blocked"
      },
      { "inboundTag": ["api"], "outboundTag": "api", "type": "field" },
      { "type": "field", "outboundTag": "blocked", "protocol": ["bittorrent"] }
    ]
  },
  "stats": {},
  "api": {
    "services": ["StatsService"],
    "tag": "api"
  },
  "policy": {
    "levels": { "0": { "statsUserDownlink": true, "statsUserUplink": true } },
    "system": {
      "statsInboundUplink": true,
      "statsInboundDownlink": true,
      "statsOutboundUplink": true,
      "statsOutboundDownlink": true
    }
  }
}
XRAYEOF

echo "${UUID}" > /etc/xray/token
echo "${MYIP}" > /etc/xray/domain

# Xray systemd service
cat > /etc/systemd/system/xray.service << 'EOF'
[Unit]
Description=Xray Service
After=network.target nss-lookup.target

[Service]
User=root
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_BIND_SERVICE
NoNewPrivileges=true
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
RestartPreventExitStatus=23

[Install]
WantedBy=multi-user.target
EOF

# ─── PROXIES PYTHON ──────────────────────────────────────────────────────────
echo -e "${YELLOW}[3/8]${NC} Instalando proxies SSH..."

# jmscript WebSocket Proxy (puerto 701)
cat > /usr/local/bin/jm-proxy.py << 'PYEOF'
#!/usr/bin/env python3
import socket, threading, select, sys, time, logging
logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = 701
BUFLEN = 4096
TIMEOUT = 300
DEFAULT_HOST = '127.0.0.1:22'
RESPONSE = 'HTTP/1.1 101 <b><font color="cyan"><i>WS + SSL JM SCRIPT</i></font></b>\r\nContent-Length: 0\r\n\r\n'

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False; self.host = host; self.port = port
        self.threads = []; self.threadsLock = threading.Lock(); self.logLock = threading.Lock()
    def run(self):
        self.soc = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2); self.soc.bind((self.host, self.port)); self.soc.listen(100)
        self.running = True
        try:
            while self.running:
                try:
                    c, addr = self.soc.accept()
                    c.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
                    c.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                    c.setblocking(1)
                except socket.timeout: continue
                conn = ConnectionHandler(c, self, addr); conn.start(); self.addConn(conn)
        finally: self.running = False; self.soc.close()
    def printLog(self, log):
        with self.logLock: logging.info(log)
    def addConn(self, conn):
        with self.threadsLock:
            if self.running: self.threads.append(conn)
    def removeConn(self, conn):
        with self.threadsLock:
            if conn in self.threads: self.threads.remove(conn)
    def close(self):
        try:
            self.running = False
            with self.threadsLock:
                for c in list(self.threads): c.close()
        except: pass

class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False; self.targetClosed = True
        self.client = socClient; self.client_buffer = b''; self.server = server
        self.addr = addr; self.log = f'Conexion: {addr[0]}:{addr[1]}'
    def close(self):
        try:
            if not self.clientClosed: self.client.shutdown(socket.SHUT_RDWR); self.client.close(); self.clientClosed = True
        except: pass
        try:
            if not self.targetClosed: self.target.shutdown(socket.SHUT_RDWR); self.target.close(); self.targetClosed = True
        except: pass
    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)
            hostPort = self.findHeader(self.client_buffer, b'X-Real-Host')
            if hostPort == b'': hostPort = DEFAULT_HOST.encode()
            split = self.findHeader(self.client_buffer, b'X-Split')
            if split != b'': self.client.recv(BUFLEN)
            if hostPort != b'':
                passwd = self.findHeader(self.client_buffer, b'X-Pass')
                if hostPort.startswith(b'127.0.0.1') or hostPort.startswith(b'localhost'):
                    self.method_CONNECT(hostPort)
                else: self.client.send(b'HTTP/1.1 403 Forbidden!\r\n\r\n')
            else: self.client.send(b'HTTP/1.1 400 NoXRealHost!\r\n\r\n')
        except Exception as e:
            self.log += f' - error: {e}'; self.server.printLog(self.log)
        finally: self.close(); self.server.removeConn(self)
    def findHeader(self, head, header):
        aux = head.find(header + b': ')
        if aux == -1: return b''
        aux = head.find(b':', aux); head = head[aux+2:]
        aux = head.find(b'\r\n')
        if aux == -1: return b''
        return head[:aux]
    def connect_target(self, host):
        i = host.find(b':')
        if i != -1: port = int(host[i+1:]); host = host[:i]
        else: port = 22
        self.target = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        self.target.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        self.target.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        self.targetClosed = False
        self.target.connect((host.decode(), port))
    def method_CONNECT(self, path):
        self.log += f' - CONNECT {path.decode()}'
        self.connect_target(path); self.client.sendall(RESPONSE.encode())
        self.client_buffer = b''; self.server.printLog(self.log); self.doCONNECT()
    def doCONNECT(self):
        socs = [self.client, self.target]; count = 0; error = False
        last_activity = time.time()
        while True:
            count += 1
            recv, _, err = select.select(socs, [], socs, 30)
            if time.time() - last_activity > 240: break
            if err: error = True
            if recv:
                for in_ in recv:
                    try:
                        data = in_.recv(BUFLEN)
                        if data:
                            last_activity = time.time()
                            if in_ is self.target: self.client.send(data)
                            else:
                                while data: sent = self.target.send(data); data = data[sent:]
                            count = 0
                        else: break
                    except: error = True; break
            if count == TIMEOUT: error = True
            if error: break

def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else LISTENING_PORT
    logging.info(f'jmscript WebSocket Proxy escuchando en 0.0.0.0:{port}')
    server = Server(LISTENING_ADDR, port); server.start()
    while True:
        try: time.sleep(2)
        except KeyboardInterrupt: server.close(); break

if __name__ == '__main__': main()
PYEOF
chmod +x /usr/local/bin/jm-proxy.py

# SSH WebSocket Internal (puerto 10015)
cat > /usr/local/bin/ssh-ws-internal.py << 'PYEOF'
#!/usr/bin/env python3
import asyncio, signal, sys
BUFFER_SIZE = 65536
SSH_HOST = "127.0.0.1"
SSH_PORT = 22
R101 = b"HTTP/1.1 101 Switching Protocols\r\nUpgrade: websocket\r\nConnection: Upgrade\r\n\r\n"
R200 = b"HTTP/1.1 200 Connection established\r\n\r\n"
active = 0

async def pipe(r, w):
    try:
        while True:
            d = await r.read(BUFFER_SIZE)
            if not d: break
            w.write(d); await w.drain()
    except: pass
    finally:
        try: w.close()
        except: pass

async def handle(cr, cw):
    global active
    active += 1; sw = None
    try:
        try: p = await asyncio.wait_for(cr.read(BUFFER_SIZE), timeout=10)
        except asyncio.TimeoutError: cw.close(); active -= 1; return
        if not p: cw.close(); active -= 1; return
        req = p.decode("utf-8", errors="ignore").upper()
        cw.write(R101 if ("UPGRADE" in req or "WEBSOCKET" in req) else R200)
        await cw.drain()
        try: sr, sw = await asyncio.open_connection(SSH_HOST, SSH_PORT)
        except: cw.close(); active -= 1; return
        await asyncio.gather(pipe(cr, sw), pipe(sr, cw))
    except: pass
    finally:
        active -= 1
        try: cw.close()
        except: pass
        if sw:
            try: sw.close()
            except: pass

async def start(port):
    s = await asyncio.start_server(handle, "127.0.0.1", port)
    async with s: await s.serve_forever()

def main():
    port = int(sys.argv[1]) if len(sys.argv) > 1 else 10015
    loop = asyncio.new_event_loop(); asyncio.set_event_loop(loop)
    for sig in (signal.SIGTERM, signal.SIGINT):
        try: loop.add_signal_handler(sig, lambda: loop.stop())
        except: pass
    loop.run_until_complete(start(port))

if __name__ == "__main__": main()
PYEOF
chmod +x /usr/local/bin/ssh-ws-internal.py

# WS Proxy LTM (puerto 80)
mkdir -p /root/ltmssh-web
cat > /root/ltmssh-web/ws-proxy.py << 'PYEOF'
#!/usr/bin/env python3
import socket, threading, select, sys, time
LISTENING_ADDR = '0.0.0.0'
LISTENING_PORT = 80
BUFLEN = 4096 * 4
TIMEOUT = 180
DEFAULT_HOST = b'127.0.0.1:22'
MSG = b'LTM SSHFREE'
STATUS_RESP = b'101'
FTAG = b'\r\nContent-length: 0\r\n\r\nHTTP/1.1 200 Connection Established\r\n\r\n'
RESPONSE = b'HTTP/1.1 ' + STATUS_RESP + b' ' + MSG + b' ' + FTAG

class Server(threading.Thread):
    def __init__(self, host, port):
        threading.Thread.__init__(self)
        self.running = False; self.host = host; self.port = port
        self.threads = []; self.threadsLock = threading.Lock(); self.logLock = threading.Lock()
    def run(self):
        self.soc = socket.socket(socket.AF_INET)
        self.soc.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.soc.settimeout(2); self.soc.bind((self.host, int(self.port))); self.soc.listen(0)
        self.running = True
        try:
            while self.running:
                try:
                    c, addr = self.soc.accept(); c.setblocking(1)
                    c.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
                    c.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
                except socket.timeout: continue
                conn = ConnectionHandler(c, self, addr); conn.start(); self.addConn(conn)
        finally: self.running = False; self.soc.close()
    def printLog(self, log):
        self.logLock.acquire(); print(log, flush=True); self.logLock.release()
    def addConn(self, conn):
        try:
            self.threadsLock.acquire()
            if self.running: self.threads.append(conn)
        finally: self.threadsLock.release()
    def removeConn(self, conn):
        try: self.threadsLock.acquire(); self.threads.remove(conn)
        finally: self.threadsLock.release()
    def close(self):
        try:
            self.running = False; self.threadsLock.acquire()
            for c in list(self.threads): c.close()
        finally: self.threadsLock.release()

class ConnectionHandler(threading.Thread):
    def __init__(self, socClient, server, addr):
        threading.Thread.__init__(self)
        self.clientClosed = False; self.targetClosed = True
        self.client = socClient; self.client_buffer = b''
        self.server = server; self.log = 'Connection: ' + str(addr)
    def close(self):
        try:
            if not self.clientClosed: self.client.shutdown(socket.SHUT_RDWR); self.client.close()
        except: pass
        finally: self.clientClosed = True
        try:
            if not self.targetClosed: self.target.shutdown(socket.SHUT_RDWR); self.target.close()
        except: pass
        finally: self.targetClosed = True
    def run(self):
        try:
            self.client_buffer = self.client.recv(BUFLEN)
            hostPort = self.findHeader(self.client_buffer, b'X-Real-Host')
            if hostPort == b'': hostPort = DEFAULT_HOST
            split = self.findHeader(self.client_buffer, b'X-Split')
            if split != b'': self.client.recv(BUFLEN)
            if hostPort != b'':
                if hostPort.startswith(b'127.0.0.1') or hostPort.startswith(b'localhost'):
                    self.method_CONNECT(hostPort)
                else: self.client.send(b'HTTP/1.1 403 Forbidden!\r\n\r\n')
            else: self.client.send(b'HTTP/1.1 400 NoXRealHost!\r\n\r\n')
        except Exception as e:
            self.log += ' - error: ' + str(e); self.server.printLog(self.log)
        finally: self.close(); self.server.removeConn(self)
    def findHeader(self, head, header):
        aux = head.find(header + b': ')
        if aux == -1: return b''
        aux = head.find(b':', aux); head = head[aux + 2:]
        aux = head.find(b'\r\n')
        if aux == -1: return b''
        return head[:aux]
    def connect_target(self, host):
        i = host.find(b':')
        if i != -1: port = int(host[i + 1:]); host = host[:i]
        else: port = 22
        (soc_family, soc_type, proto, _, address) = socket.getaddrinfo(host, port)[0]
        self.target = socket.socket(soc_family, soc_type, proto)
        self.target.setsockopt(socket.SOL_SOCKET, socket.SO_KEEPALIVE, 1)
        self.target.setsockopt(socket.IPPROTO_TCP, socket.TCP_NODELAY, 1)
        self.targetClosed = False; self.target.connect(address)
    def method_CONNECT(self, path):
        self.log += ' - CONNECT ' + path.decode()
        self.connect_target(path); self.client.sendall(RESPONSE)
        self.client_buffer = b''; self.server.printLog(self.log); self.doCONNECT()
    def doCONNECT(self):
        socs = [self.client, self.target]; count = 0; error = False
        while True:
            count += 1
            (recv, _, err) = select.select(socs, [], socs, 3)
            if err: error = True
            if recv:
                for in_ in recv:
                    try:
                        data = in_.recv(BUFLEN)
                        if data:
                            if in_ is self.target: self.client.send(data)
                            else:
                                while data: byte = self.target.send(data); data = data[byte:]
                            count = 0
                        else: break
                    except: error = True; break
            if count == TIMEOUT: error = True
            if error: break

if __name__ == '__main__':
    port = int(sys.argv[1]) if len(sys.argv) > 1 else LISTENING_PORT
    print(f"LTMSSH WS Proxy | Puerto: {port} -> SSH :22 | Resp: 101", flush=True)
    server = Server(LISTENING_ADDR, port); server.start()
    while True:
        try: time.sleep(2)
        except KeyboardInterrupt: server.close(); break
PYEOF
chmod +x /root/ltmssh-web/ws-proxy.py

echo -e "${GREEN}  ✅ Proxies SSH instalados${NC}"

# ─── SYSTEMD SERVICES ────────────────────────────────────────────────────────
echo -e "${YELLOW}[4/8]${NC} Creando servicios systemd..."

cat > /etc/systemd/system/ws.service << 'EOF'
[Unit]
Description=Python Proxy Mod JM SCRIPT
After=network.target nss-lookup.target

[Service]
Type=simple
User=root
ExecStart=/usr/bin/python3 /usr/local/bin/jm-proxy.py 701
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/ssh-ws-internal.service << 'EOF'
[Unit]
Description=SSH WebSocket Internal (127.0.0.1:10015)
After=network.target

[Service]
Type=simple
ExecStart=/usr/bin/python3 /usr/local/bin/ssh-ws-internal.py 10015
Restart=always
RestartSec=3
LimitNOFILE=65536

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/ws-proxy.service << 'EOF'
[Unit]
Description=WS proxy Python port 80 para HTTP Custom
After=network.target

[Service]
ExecStart=/usr/bin/python3 /root/ltmssh-web/ws-proxy.py 80
Restart=always
RestartSec=3

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/badvpn1.service << 'EOF'
[Unit]
Description=UDP 7300
After=syslog.target network-online.target

[Service]
User=root
NoNewPrivileges=true
ExecStart=/usr/sbin/badvpn --listen-addr 127.0.0.1:7300 --max-clients 500
Restart=on-failure
LimitNPROC=10000
LimitNOFILE=1000000

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/systemd/system/dropbear_custom.service << 'EOF'
[Unit]
Description=Dropbear SSH Multi-Port
After=network.target

[Service]
Type=simple
ExecStart=/usr/sbin/dropbear -F -p 90 -p 143 -p 109 -W 65536 -b /etc/issue.net
Restart=always
RestartSec=3
KillMode=process

[Install]
WantedBy=multi-user.target
EOF

echo -e "${GREEN}  ✅ Servicios creados${NC}"

# ─── SSH CONFIG ───────────────────────────────────────────────────────────────
echo -e "${YELLOW}[5/8]${NC} Configurando SSH..."

# Configurar sshd_config
sed -i 's/^#*PermitRootLogin.*/PermitRootLogin yes/' /etc/ssh/sshd_config
sed -i 's/^#*PasswordAuthentication.*/PasswordAuthentication yes/' /etc/ssh/sshd_config
[[ $(grep -c "PasswordAuthentication" /etc/ssh/sshd_config) = '0' ]] && \
    echo 'PasswordAuthentication yes' >> /etc/ssh/sshd_config
[ -f /etc/ssh/sshd_config.d/60-cloudimg-settings.conf ] && \
    sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" \
    /etc/ssh/sshd_config.d/60-cloudimg-settings.conf 2>/dev/null

# Banner SSH
cat > /etc/issue.net << 'EOF'
<p style="text-align:center"><span style=background-color:#000000;"><b><font color="cyan">V I P  S E R V E R  jmscript</font>
<BR><font color='#5539fb'>===============================</font><BR>
<font color='red'> REGLAS !! </font><br>
<font color="cyan">1 cuenta para 1 dispositivo<br>
No Porn/Apk 18+<br>
No Hotspot & STB<br>
No Contenido Ilegal<br><b></font>
<font color="green">Violar Reglas</>
<font color="#FFFFFF"> = </>
<font color="red">Baneado!</><font>
<BR><font color='#5539fb'>===============================</font><BR>
<font color="cyan">By JM SCRIPT VPN</font><br>
EOF

echo -e "${GREEN}  ✅ SSH configurado${NC}"

# ─── OPENVPN ─────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/8]${NC} Configurando OpenVPN..."

if command -v openvpn &>/dev/null; then
    mkdir -p /etc/openvpn/easy-rsa /etc/openvpn/ccd /etc/openvpn/client

    # Generar PKI
    if [ ! -f /etc/openvpn/easy-rsa/pki/ca.crt ]; then
        cd /usr/share/easy-rsa 2>/dev/null || cd /etc/easy-rsa 2>/dev/null || true
        if [ -f "easyrsa" ] || command -v easyrsa &>/dev/null; then
            EASYRSA=$(command -v easyrsa 2>/dev/null || echo "./easyrsa")
            cp -r /usr/share/easy-rsa/* /etc/openvpn/easy-rsa/ 2>/dev/null || true
            cd /etc/openvpn/easy-rsa
            EASYRSA_BATCH=1 ./easyrsa init-pki 2>/dev/null
            EASYRSA_BATCH=1 EASYRSA_REQ_CN="jmscript-CA" ./easyrsa build-ca nopass 2>/dev/null
            EASYRSA_BATCH=1 ./easyrsa build-server-full server nopass 2>/dev/null
            EASYRSA_BATCH=1 ./easyrsa gen-dh 2>/dev/null
            EASYRSA_BATCH=1 ./easyrsa gen-crl 2>/dev/null
            openvpn --genkey secret /etc/openvpn/ta.key 2>/dev/null
        fi
    fi

    cat > /etc/openvpn/server.conf << 'OVPNEOF'
port 1194
proto udp
dev tun
ca /etc/openvpn/easy-rsa/pki/ca.crt
cert /etc/openvpn/easy-rsa/pki/issued/server.crt
key /etc/openvpn/easy-rsa/pki/private/server.key
dh /etc/openvpn/easy-rsa/pki/dh.pem
tls-auth /etc/openvpn/ta.key 0
crl-verify /etc/openvpn/easy-rsa/pki/crl.pem
server 10.9.0.0 255.255.255.0
push "redirect-gateway def1 bypass-dhcp"
keepalive 10 120
auth-user-pass-verify /etc/openvpn/login.sh via-env
verify-client-cert require
username-as-common-name
script-security 3
cipher AES-256-CBC
auth SHA256
tls-version-min 1.2
reneg-sec 0
max-clients 100
client-config-dir /etc/openvpn/ccd
comp-lzo no
persist-key
persist-tun
verb 3
OVPNEOF

    cat > /etc/openvpn/login.sh << 'LOGINEOF'
#!/bin/bash
USERNAME=$common_name
PASSWORD=$password
PASSFILE="/etc/openvpn/passwd"
if [ -f "$PASSFILE" ]; then
    HASH=$(grep "^${USERNAME}:" "$PASSFILE" | cut -d: -f2)
    if [ -n "$HASH" ]; then
        INPUT_HASH=$(openssl passwd -1 "$PASSWORD" 2>/dev/null)
        [[ "$HASH" == $(openssl passwd -1 -stdin <<< "$PASSWORD" 2>/dev/null) ]] && exit 0
        python3 -c "import crypt; exit(0 if crypt.crypt('$PASSWORD', '$HASH') == '$HASH' else 1)" 2>/dev/null && exit 0
    fi
fi
exit 1
LOGINEOF
    chmod +x /etc/openvpn/login.sh
fi

echo -e "${GREEN}  ✅ OpenVPN configurado${NC}"

# ─── IPTABLES ────────────────────────────────────────────────────────────────
echo -e "${YELLOW}[7/8]${NC} Configurando firewall..."

iptables -F
iptables -A INPUT -p tcp --dport 22   -j ACCEPT
iptables -A INPUT -p tcp --dport 80   -j ACCEPT
iptables -A INPUT -p tcp --dport 90   -j ACCEPT
iptables -A INPUT -p tcp --dport 109  -j ACCEPT
iptables -A INPUT -p tcp --dport 143  -j ACCEPT
iptables -A INPUT -p tcp --dport 443  -j ACCEPT
iptables -A INPUT -p tcp --dport 701  -j ACCEPT
iptables -A INPUT -p tcp --dport 1194 -j ACCEPT
iptables -A INPUT -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -p tcp --dport 7300 -j ACCEPT
iptables -A INPUT -p udp --dport 7300 -j ACCEPT
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o eth0 -j MASQUERADE 2>/dev/null
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o ens3 -j MASQUERADE 2>/dev/null
iptables -t nat -A POSTROUTING -s 10.9.0.0/24 -o venet0 -j MASQUERADE 2>/dev/null
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
echo -e "${GREEN}  ✅ Firewall configurado${NC}"

# ─── HABILITAR Y ARRANCAR SERVICIOS ──────────────────────────────────────────
echo -e "${YELLOW}[8/8]${NC} Iniciando servicios..."

systemctl daemon-reload

for svc in xray ws ssh-ws-internal ws-proxy badvpn1 dropbear_custom; do
    systemctl enable "$svc" 2>/dev/null
    systemctl restart "$svc" 2>/dev/null && \
        echo -e "${GREEN}  ✅ ${svc} activo${NC}" || \
        echo -e "${RED}  ✖ ${svc} falló${NC}"
done

systemctl enable openvpn@server 2>/dev/null
systemctl restart openvpn@server 2>/dev/null && \
    echo -e "${GREEN}  ✅ openvpn activo${NC}" || \
    echo -e "${YELLOW}  ⚠ openvpn: requiere PKI completo${NC}"

systemctl restart ssh 2>/dev/null || service ssh restart 2>/dev/null

# ─── PANEL ───────────────────────────────────────────────────────────────────
# Descargar e instalar el panel jmscript
wget -q --timeout=30 \
    "https://raw.githubusercontent.com/Internetjm/personalScript/main/jm-panel.sh" \
    -O /usr/local/bin/jm-panel 2>/dev/null && chmod +x /usr/local/bin/jm-panel
ln -sf /usr/local/bin/jm-panel /usr/local/bin/menu 2>/dev/null

# ─── FINALIZAR ───────────────────────────────────────────────────────────────
clear
echo -e "  ${BIBlue}╭══════════════════════════════════════╮${NC}"
echo -e "  ${BIBlue}│ ${BGCOLOR}      ✅ INSTALACION COMPLETADA      ${NC}${BIBlue} │${NC}"
echo -e "  ${BIBlue}╰══════════════════════════════════════╯${NC}"
echo ""
echo -e "  ${GREEN}IP del servidor:${NC} ${MYIP}"
echo -e "  ${GREEN}UUID Xray:${NC}       ${UUID}"
echo ""
echo -e "  ${YELLOW}Puertos activos:${NC}"
echo -e "  SSH     : 22, 90, 109, 143"
echo -e "  WS Proxy: 80, 701"
echo -e "  BadVPN  : 7300 (UDP)"
echo -e "  OpenVPN : 1194 (UDP)"
echo ""
echo -e "  Escribe ${GREEN}menu${NC} para abrir el panel de administracion"
echo ""
sleep 3
exec bash /usr/local/bin/jm-panel
