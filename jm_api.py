#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
JM API - crea cuentas de 24 horas en el VPS (SSH + UDP + SlowDNS + Xray) y
devuelve un JSON con TODOS los protocolos. Sin dependencias (solo stdlib).
Debe correr como root en el VPS donde esta instalado JM SCRIPT.

  python3 jm_api.py serve            # levanta la API
  python3 jm_api.py create [usuario] # crea una cuenta desde consola
  python3 jm_api.py delete <usuario>
  python3 jm_api.py reap             # borra las cuentas vencidas

  POST /api/v1/users/<usuario>       # crea o renueva tras 20 horas
  GET  /api/v1/users/<usuario>/remaining # solo segundos restantes
"""
import base64, hmac, json, os, re, secrets, subprocess, sys, threading, time, uuid as uuidlib
from datetime import datetime, timedelta, timezone
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

HOURS = 24                                   # duracion fija de toda cuenta
ROOT = os.environ.get("JM_ROOT", "")         # solo para pruebas
DRY = os.environ.get("JM_DRYRUN") == "1"     # solo para pruebas (no ejecuta useradd/systemctl)
BIND = os.environ.get("JM_API_BIND", "0.0.0.0")
PORT = int(os.environ.get("JM_API_PORT", "8085"))
ALLOW = [x.strip() for x in os.environ.get("JM_API_ALLOW", "").split(",") if x.strip()]
LOCK = threading.Lock()

USER_RE = re.compile(r"^[a-zA-Z][a-zA-Z0-9_-]{2,23}$")
PASS_RE = re.compile(r"^[A-Za-z0-9._-]{4,32}$")


def P(path):
    return ROOT + path


def rd(path, default=""):
    try:
        with open(P(path), "r", encoding="utf-8", errors="ignore") as f:
            return f.read().strip()
    except OSError:
        return default


def wr(path, text, mode="w"):
    os.makedirs(os.path.dirname(P(path)), exist_ok=True)
    with open(P(path), mode, encoding="utf-8") as f:
        f.write(text)


def sh(*args, stdin=None):
    if DRY:
        return 0, ""
    r = subprocess.run(list(args), input=stdin, capture_output=True, text=True)
    return r.returncode, (r.stdout or "") + (r.stderr or "")


def svc_exists(name):
    if DRY:
        return os.path.exists(P("/etc/systemd/system/%s.service" % name))
    return subprocess.run(["systemctl", "cat", name + ".service"], capture_output=True).returncode == 0


def svc_active(name):
    return DRY is False and subprocess.run(["systemctl", "is-active", "--quiet", name]).returncode == 0


def ports_of(proc, fallback):
    if DRY:
        return fallback
    r = subprocess.run(["ss", "-H", "-ltnp"], capture_output=True, text=True).stdout
    found = set()
    for ln in r.splitlines():
        if '"%s"' % proc in ln:
            m = re.search(r":(\d+)\s", ln.split()[3] + " ")
            if m:
                found.add(int(m.group(1)))
    return sorted(found) or fallback


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Xray (mismos marcadores que el panel) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def xray_add(user, exp, uid, lim):
    cfg = P("/etc/xray/config.json")
    text = rd("/etc/xray/config.json")
    needed = ["#vmess", "#vmessgrpc", "#vless", "#vlessgrpc", "#trojanws", "#trojangrpc"]
    lines = text.split("\n")
    stripped = [l.strip() for l in lines]
    if not all(m in stripped for m in needed):
        return False
    if '"email": "%s"' % user in text:
        return True
    vm = '},{"id": "%s","alterId": 0,"email": "%s"' % (uid, user)
    vl = '},{"id": "%s","email": "%s"' % (uid, user)
    tr = '},{"password": "%s","email": "%s"' % (uid, user)
    spec = {
        "#vmess": ("#vm %s %s" % (user, exp), vm),
        "#vmessgrpc": ("#vmg %s %s %s" % (user, exp, uid), vm),
        "#vless": ("#vl %s %s %s" % (user, exp, uid), vl),
        "#vlessgrpc": ("#vlg %s %s" % (user, exp), vl),
        "#trojanws": ("#tr %s %s %s" % (user, exp, uid), tr),
        "#trojangrpc": ("#trg %s %s" % (user, exp), tr),
    }
    out = []
    for l in lines:
        out.append(l)
        if l.strip() in spec:
            out.extend(spec[l.strip()])
    quota = str(9999 * 1024 ** 3)
    for p in ("vmess", "vless", "trojan"):
        wr("/etc/%s/%s" % (p, user), quota + "\n")
        wr("/etc/%s/%sIP" % (p, user), str(lim if lim > 0 else 9999) + "\n")
    wr("/etc/xray/config.json", "\n".join(out) + "\n")
    return True


def xray_del(user):
    text = rd("/etc/xray/config.json")
    if not text:
        return
    lines, out, skip = text.split("\n"), [], False
    for l in lines:
        if skip:
            if l.startswith("},{"):
                skip = False
            continue
        if re.match(r"^#(vm|vmg|vl|vlg|tr|trg) %s " % re.escape(user), l):
            skip = True
            continue
        out.append(l)
    wr("/etc/xray/config.json", "\n".join(out) + "\n")
    for p in ("vmess", "vless", "trojan"):
        for f in ("/etc/%s/%s" % (p, user), "/etc/%s/%sIP" % (p, user)):
            try:
                os.remove(P(f))
            except OSError:
                pass


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ UDP (ZIVPN / Hysteria) â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def udp_cfg_add(path, user, pw):
    text = rd(path)
    if not text:
        return False
    entry = '"%s:%s"' % (user, pw)
    out = []
    for l in text.split("\n"):
        if '"config": [' in l and entry not in l:
            m = re.search(r"\[(.*?)\]", l[l.index('"config": ['):])
            inner = m.group(1).strip() if m else ""
            l = l.replace("]", ("," if inner else "") + entry + "]", 1)
        out.append(l)
    wr(path, "\n".join(out) + "\n")
    return True


def udp_cfg_del(path, user, pw):
    text = rd(path)
    if not text:
        return False
    e = re.escape('"%s:%s"' % (user, pw))
    new = re.sub("," + e, "", text)
    if new == text:
        new = re.sub(e + ",", "", text)
    if new == text:
        new = re.sub(e, "", text)
    wr(path, new + "\n")
    return True


def restart_services():
    for s in ("xray", "udpmod", "zivpn"):
        if DRY:
            continue
        if svc_active(s):
            subprocess.run(["systemctl", "restart", s], capture_output=True)


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Cuentas â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def acct_file(user):
    return "/etc/jm-api/accounts/%s.json" % user


def exists(user):
    if os.path.exists(P(acct_file(user))):
        return True
    if re.search(r"^### %s " % re.escape(user), rd("/etc/xray/ssh"), re.M):
        return True
    if DRY:
        return False
    return subprocess.run(["getent", "passwd", user], capture_output=True).returncode == 0


def renew_account(rec):
    """Renueva una cuenta existente por 24 horas después de 20 horas."""
    user = rec["username"]
    now = datetime.now(timezone.utc)
    expires = now + timedelta(hours=HOURS)
    panel_exp = (datetime.now() + timedelta(days=2)).strftime("%Y-%m-%d")
    password = rec.get("password", "")

    if not DRY:
        sh("chage", "-E", panel_exp, user)

    ssh_text = rd("/etc/xray/ssh")
    ssh_new = re.sub(r"^### %s \S+ \S+$" % re.escape(user),
                     "### %s %s %s" % (user, panel_exp, password),
                     ssh_text, flags=re.M)
    if ssh_new == ssh_text and password:
        ssh_new = ssh_text.rstrip("\n") + "\n### %s %s %s\n" % (user, panel_exp, password)
    if ssh_new != ssh_text:
        wr("/etc/xray/ssh", ssh_new)

    check = rd("/var/www/html/CheckUser")
    check_new = re.sub(r"^%s:\S+$" % re.escape(user),
                       "%s:%s" % (user, panel_exp), check, flags=re.M)
    if check_new != check:
        wr("/var/www/html/CheckUser", check_new)

    xray = rd("/etc/xray/config.json")
    xray_new = re.sub(
        r"^(#(?:vm|vmg|vl|vlg|tr|trg) %s )\S+(.*)$" % re.escape(user),
        r"\g<1>%s\g<2>" % panel_exp,
        xray,
        flags=re.M,
    )
    if xray_new != xray:
        wr("/etc/xray/config.json", xray_new)

    renewed = dict(rec)
    renewed.update({"created_at": int(now.timestamp()),
                    "expires_at": int(expires.timestamp()),
                    "panel_exp": panel_exp})
    wr(acct_file(user), json.dumps(renewed))
    restart_services()
    result = build_json(renewed)
    result["renewed"] = True
    return result


def create_account(user=None, pw=None, ip_limit=1):
    user = user or ("u" + secrets.token_hex(4))
    pw = pw or "".join(secrets.choice("abcdefghjkmnpqrstuvwxyz23456789") for _ in range(8))
    if not USER_RE.match(user):
        raise ValueError("usuario invalido (3-24 caracteres, letras/numeros/_/-, empieza con letra)")
    if not PASS_RE.match(pw):
        raise ValueError("password invalido (4-32 caracteres A-Z a-z 0-9 . _ -)")
    if not isinstance(ip_limit, int) or not 0 <= ip_limit <= 100:
        raise ValueError("ip_limit invalido (0-100, 0 = sin limite)")
    if exists(user):
        try:
            previous = json.loads(rd(acct_file(user)) or "null")
        except ValueError:
            previous = None
        if not previous or not previous.get("created_at"):
            raise FileExistsError("el usuario ya existe y no tiene registro de la API")
        age = time.time() - int(previous["created_at"])
        minimum = 20 * 60 * 60
        if age < minimum:
            remaining = int(minimum - age)
            raise FileExistsError("no se puede renovar antes de 20 horas; faltan %d segundos" % remaining)
        return renew_account(previous)

    now = datetime.now(timezone.utc)
    expires = now + timedelta(hours=HOURS)
    # Fecha para el sistema/panel: +2 dias como red de seguridad (el sistema solo entiende dias).
    # El corte exacto a las 24h lo hace el 'reap' (cron cada 5 min + hilo interno).
    panel_exp = (datetime.now() + timedelta(days=2)).strftime("%Y-%m-%d")
    uid = str(uuidlib.uuid4())

    rc, out = sh("useradd", "-e", panel_exp, "-s", "/bin/false", "-M", user)
    if rc != 0:
        raise RuntimeError("useradd fallo: " + out.strip())
    sh("chpasswd", stdin="%s:%s\n" % (user, pw))
    wr("/etc/xray/ssh", "### %s %s %s\n" % (user, panel_exp, pw), "a")
    wr("/etc/xray/sshx/%sIP" % user, "%d\n" % ip_limit)
    wr("/var/www/html/CheckUser", "%s:%s\n" % (user, panel_exp), "a")
    has_xray = xray_add(user, panel_exp, uid, ip_limit)
    udp_cfg_add("/root/UDPMOD/config.json", user, pw)
    udp_cfg_add("/etc/zivpn/config.json", user, pw)
    restart_services()

    rec = {"username": user, "password": pw, "uuid": uid if has_xray else "",
           "ip_limit": ip_limit, "panel_exp": panel_exp,
           "created_at": int(now.timestamp()), "expires_at": int(expires.timestamp())}
    wr(acct_file(user), json.dumps(rec))
    return build_json(rec)


def delete_account(user, restart=True):
    if not USER_RE.match(user):
        raise ValueError("usuario invalido")
    rec = {}
    try:
        rec = json.loads(rd(acct_file(user)) or "{}")
    except ValueError:
        pass
    pw = rec.get("password", "")
    if not pw:
        m = re.search(r"^### %s \S+ (\S+)" % re.escape(user), rd("/etc/xray/ssh"), re.M)
        pw = m.group(1) if m else ""
    ssh_txt = re.sub(r"^### %s .*\n?" % re.escape(user), "", rd("/etc/xray/ssh"), flags=re.M)
    if rd("/etc/xray/ssh") != ssh_txt:
        wr("/etc/xray/ssh", ssh_txt)
    chk = re.sub(r"^%s:.*\n?" % re.escape(user), "", rd("/var/www/html/CheckUser"), flags=re.M)
    if os.path.exists(P("/var/www/html/CheckUser")):
        wr("/var/www/html/CheckUser", chk)
    if pw:
        udp_cfg_del("/root/UDPMOD/config.json", user, pw)
        udp_cfg_del("/etc/zivpn/config.json", user, pw)
    xray_del(user)
    sh("pkill", "-KILL", "-u", user)
    sh("userdel", user)
    for f in (acct_file(user), "/etc/xray/sshx/%sIP" % user, "/etc/xray/sshx/%slogin" % user,
              "/var/www/html/ssh-%s.txt" % user, "/var/www/html/APP/ssh-%s.txt" % user):
        try:
            os.remove(P(f))
        except OSError:
            pass
    if restart:
        restart_services()
    return True


def reap():
    d = P("/etc/jm-api/accounts")
    n, now = 0, time.time()
    if not os.path.isdir(d):
        return 0
    for fn in os.listdir(d):
        try:
            rec = json.load(open(os.path.join(d, fn)))
        except (OSError, ValueError):
            continue
        if rec.get("expires_at", 1 << 60) <= now:
            with LOCK:
                delete_account(rec["username"], restart=False)
            n += 1
    if n:
        restart_services()
    return n


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ JSON de salida â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def iso(ts):
    return datetime.fromtimestamp(ts, timezone.utc).strftime("%Y-%m-%dT%H:%M:%SZ")


def b64(d):
    return base64.b64encode(json.dumps(d, separators=(",", ":")).encode()).decode()


def build_json(rec):
    u, pw, uid = rec["username"], rec["password"], rec.get("uuid", "")
    domain = rd("/etc/xray/domain")
    patch = rd("/etc/xray/patch")
    ns, slkey = rd("/etc/xray/dns"), rd("/etc/slowdns/server.pub")
    ws_ports = [80, 8080, 8088, 8280, 8880, 2052, 2082, 2086, 2095]
    proto = {}

    proto["ssh"] = {
        "installed": True, "host": domain, "username": u, "password": pw,
        "ports": {"openssh": ports_of("sshd", [22]), "dropbear": ports_of("dropbear", [109, 143]),
                  "ws": ws_ports, "ssl_ws": [443], "ssl": [443], "tcp_ovpn": 1194, "udpgw": "7100-7300"},
        "ws_uri": "%s:80@%s:%s" % (domain, u, pw), "ssl_uri": "%s:443@%s:%s" % (domain, u, pw),
        "payload_ws": "GET / HTTP/1.1[crlf]Host: [host][crlf]Connection: Upgrade[crlf]User-Agent: [ua][crlf]Upgrade: ws[crlf][crlf]",
    }
    ok = bool(ns and slkey)
    proto["slowdns"] = {"installed": ok, "nameserver": ns, "public_key": slkey, "username": u, "password": pw,
                        "uri": "%s:53@%s:%s" % (ns, u, pw)} if ok else {"installed": False}
    proto["udp_zivpn"] = {"installed": bool(rd("/etc/zivpn/config.json")), "host": domain, "port_range": "1-19999",
                          "username": u, "password": pw}
    obfs = ""
    hy = rd("/root/UDPMOD/config.json")
    if hy:
        try:
            obfs = json.loads(hy).get("obfs", "")
        except ValueError:
            m = re.search(r'"obfs"\s*:\s*"([^"]*)"', hy)
            obfs = m.group(1) if m else ""
    proto["udp_hysteria"] = {"installed": bool(hy), "host": domain, "port_range": "20000-39999", "obfs": obfs,
                             "username": u, "password": pw}
    proto["udp_custom"] = {"installed": svc_exists("udp-custom"), "host": domain, "port_range": "40000-65535",
                           "username": u, "password": pw, "uri": "%s:40000-65535@%s:%s" % (domain, u, pw)}
    hp = re.search(r"--listen :(\d+)", rd("/etc/systemd/system/hcr-server.service"))
    proto["hcr"] = {"installed": svc_exists("hcr-server"), "host": domain, "port": int(hp.group(1)) if hp else 8880,
                    "username": u, "password": pw}
    bp = re.search(r"BHTTP_PORT=\"?(\d+)", rd("/etc/bhttp-panel.conf"))
    proto["bhttp"] = {"installed": svc_exists("bhttp"), "host": domain, "port": int(bp.group(1)) if bp else 8888,
                      "username": u, "password": pw}

    if uid:
        def vm(net, port, tls, path):
            return "vmess://" + b64({"v": "2", "ps": u, "add": domain, "port": str(port), "id": uid, "aid": "0",
                                     "net": net, "path": path, "type": "none", "host": domain, "tls": tls})
        proto["vmess"] = {"installed": True, "uuid": uid, "host": domain, "alter_id": 0, "ports": {"tls": 443, "ntls": 80},
                          "ws_path": "/vm-" + patch, "grpc_service": "vmgr-" + patch,
                          "links": {"ws_tls": vm("ws", 443, "tls", "/vm-" + patch),
                                    "ws_ntls": vm("ws", 80, "none", "/vm-" + patch),
                                    "grpc": vm("grpc", 443, "tls", "vmgr-" + patch)}}
        proto["vless"] = {"installed": True, "uuid": uid, "host": domain, "ports": {"tls": 443, "ntls": 80},
                          "ws_path": "/vl-" + patch, "grpc_service": "vlgr-" + patch,
                          "links": {"ws_tls": "vless://%s@%s:443?path=/vl-%s&security=tls&encryption=none&host=%s&type=ws&sni=%s#%s" % (uid, domain, patch, domain, domain, u),
                                    "ws_ntls": "vless://%s@%s:80?path=/vl-%s&security=none&encryption=none&host=%s&type=ws#%s" % (uid, domain, patch, domain, u),
                                    "grpc": "vless://%s@%s:443?mode=gun&security=tls&encryption=none&type=grpc&serviceName=vlgr-%s&sni=%s#%s" % (uid, domain, patch, domain, u)}}
        proto["trojan"] = {"installed": True, "password": uid, "host": domain, "port": 443,
                           "ws_path": "/tr-" + patch, "grpc_service": "trgr-" + patch,
                           "links": {"ws_tls": "trojan://%s@%s:443?path=%%2Ftr-%s&security=tls&host=%s&type=ws&sni=%s#%s" % (uid, domain, patch, domain, domain, u),
                                     "grpc": "trojan://%s@%s:443?mode=gun&security=tls&type=grpc&serviceName=trgr-%s&sni=%s#%s" % (uid, domain, patch, domain, u)}}
    else:
        for k in ("vmess", "vless", "trojan"):
            proto[k] = {"installed": False}

    return {"ok": True, "username": u, "password": pw, "uuid": uid, "host": domain,
            "duration_hours": HOURS, "ip_limit": rec.get("ip_limit", 1),
            "created_at": iso(rec["created_at"]), "expires_at": iso(rec["expires_at"]),
            "expires_at_epoch": rec["expires_at"], "protocols": proto}


def remaining_json(rec):
    """Respuesta deliberadamente mínima para el endpoint de tiempo restante."""
    return {"remaining_seconds": max(0, int(rec.get("expires_at", 0) - time.time()))}


# â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€ Servidor HTTP â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
def api_key():
    return rd("/etc/jm-api/api.key")


class H(BaseHTTPRequestHandler):
    server_version = "JMAPI/1.0"

    def log_message(self, fmt, *a):
        sys.stderr.write("%s %s\n" % (self.address_string(), fmt % a))

    def send(self, code, obj):
        body = json.dumps(obj, ensure_ascii=False).encode()
        self.send_response(code)
        self.send_header("Content-Type", "application/json; charset=utf-8")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def authed(self):
        if ALLOW and self.client_address[0] not in ALLOW:
            return False
        key = api_key()
        got = self.headers.get("X-API-Key") or self.headers.get("Authorization", "").replace("Bearer ", "", 1)
        return bool(key) and hmac.compare_digest(got.encode(), key.encode())

    def body(self):
        n = int(self.headers.get("Content-Length") or 0)
        if n > 4096:
            raise ValueError("body muy grande")
        raw = self.rfile.read(n) if n else b""
        return json.loads(raw.decode() or "{}")

    def route(self, method):
        path = self.path.split("?")[0].rstrip("/")
        if not self.authed():
            return self.send(401, {"ok": False, "error": "no autorizado"})
        try:
            if path == "/api/v1/users" and method == "POST":
                b = self.body()
                with LOCK:
                    res = create_account(b.get("username"), b.get("password"), int(b.get("ip_limit", 1)))
                return self.send(201, res)
            if path == "/api/v1/users" and method == "GET":
                d, out = P("/etc/jm-api/accounts"), []
                for fn in sorted(os.listdir(d)) if os.path.isdir(d) else []:
                    r = json.load(open(os.path.join(d, fn)))
                    out.append({"username": r["username"], "expires_at": iso(r["expires_at"])})
                return self.send(200, {"ok": True, "users": out})
            m = re.match(r"^/api/v1/users/([^/]+)/remaining$", path)
            if m and USER_RE.match(m.group(1)) and method == "GET":
                rec = json.loads(rd(acct_file(m.group(1))) or "null")
                if not rec:
                    return self.send(404, {"ok": False, "error": "no existe"})
                return self.send(200, remaining_json(rec))
            m = re.match(r"^/api/v1/users/([^/]+)$", path)
            if m and USER_RE.match(m.group(1)):
                user = m.group(1)
                if method == "GET":
                    rec = json.loads(rd(acct_file(user)) or "null")
                    if not rec:
                        return self.send(404, {"ok": False, "error": "no existe"})
                    return self.send(200, build_json(rec))
            return self.send(404, {"ok": False, "error": "ruta no encontrada"})
        except FileExistsError as e:
            return self.send(409, {"ok": False, "error": str(e)})
        except (ValueError, TypeError) as e:
            return self.send(400, {"ok": False, "error": str(e)})
        except Exception as e:  # noqa
            return self.send(500, {"ok": False, "error": "error interno: %s" % e})

    def do_GET(self): self.route("GET")
    def do_POST(self): self.route("POST")


def reaper_loop():
    while True:
        time.sleep(60)
        try:
            reap()
        except Exception as e:  # noqa
            sys.stderr.write("reap error: %s\n" % e)


def main():
    cmd = sys.argv[1] if len(sys.argv) > 1 else "serve"
    if cmd == "serve":
        threading.Thread(target=reaper_loop, daemon=True).start()
        print("JM API escuchando en %s:%d" % (BIND, PORT))
        ThreadingHTTPServer((BIND, PORT), H).serve_forever()
    elif cmd == "create":
        print(json.dumps(create_account(sys.argv[2] if len(sys.argv) > 2 else None), indent=2, ensure_ascii=False))
    elif cmd == "delete" and len(sys.argv) > 2:
        delete_account(sys.argv[2]); print("ok")
    elif cmd == "reap":
        print("vencidas borradas:", reap())
    else:
        print(__doc__)


if __name__ == "__main__":
    main()


