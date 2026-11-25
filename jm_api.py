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

  POST /api/v1/users                 # crea o renueva tras 20 horas
  GET  /api/v1/users/<usuario>         # detalle de un usuario
  GET  /api/v1/users/<usuario>/remaining # solo segundos restantes

  Generador de configuraciones AVG VPN (el catalogo vive en el panel central):
  GET  /api/v1/info                      # estado de este VPS: dominio, protocolos, huella del certificado
  GET  /api/v1/pin[?sni=]                # huella SHA-256 del certificado que sirve este VPS
  POST /api/v1/preview                   # {"profile": {...}} -> .avg de muestra con los datos reales del VPS
  POST /api/v1/render                    # {"username","password","ip_limit","profile"|"profiles"}:
                                         #   reutiliza o crea la cuenta (24 h) y devuelve el .avg y el avgvpn://

  python3 jm_api.py preview <perfil.json>
  python3 jm_api.py render <usuario> <perfil.json> [--link]
  python3 jm_api.py pin [sni]
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
    xray_active = DRY or svc_active("xray")
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

    if uid and xray_active:
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
# ═════════════════════════ AVG VPN: generador de .avg ═════════════════════════
# El catalogo de perfiles (pais/compania/metodo) vive en el panel central. Este VPS solo recibe
# un perfil, lo combina con los datos REALES de la cuenta (usuario, clave, UUID, dominio,
# SlowDNS, UDP) y la huella del certificado de este VPS, y devuelve el .avg y el enlace avgvpn://.
import hashlib, io, socket, ssl, unicodedata, zipfile
from urllib.parse import parse_qs, urlparse

LINK_PREFIX = "avgvpn://"

# método -> tipo de túnel que entiende la app (ConfigParser)
METHODS = {"ssh_direct": 1, "ssh_proxy": 2, "ssh_ssl": 3, "payload_ssl": 4,
           "slowdns": 5, "udp": 6, "v2ray": 7}
DEFAULT_PORT = {"ssh_direct": 80, "ssh_proxy": 80, "ssh_ssl": 443, "payload_ssl": 443,
                "slowdns": 2222, "udp": 0, "v2ray": 443}
ID_RE = re.compile(r"^[a-z0-9][a-z0-9_-]{2,63}$")
RESERVED_IDS = set()
HOST_RE = re.compile(r"^(\{DOMAIN\}|[A-Za-z0-9]([A-Za-z0-9._-]{0,251}[A-Za-z0-9])?)$")
IP_RE = re.compile(r"^\d{1,3}(\.\d{1,3}){3}$")
FIELDS = ("id", "name", "country", "carrier", "method", "enabled", "front", "port", "sni",
          "payload", "proxy_host", "proxy_port", "dns_resolver", "v2", "notes", "udp_up", "udp_down")


def slug(text, maxlen=50):
    t = unicodedata.normalize("NFKD", str(text)).encode("ascii", "ignore").decode()
    t = re.sub(r"[^a-z0-9]+", "-", t.lower()).strip("-")
    return t[:maxlen].strip("-")


def _int(v, lo, hi, name):
    try:
        n = int(v)
    except (TypeError, ValueError):
        raise ValueError("%s debe ser un numero" % name)
    if not lo <= n <= hi:
        raise ValueError("%s fuera de rango (%d-%d)" % (name, lo, hi))
    return n


def _host(v, name):
    v = str(v or "").strip()
    if v and not HOST_RE.match(v):
        raise ValueError("%s invalido (dominio, IP o {DOMAIN})" % name)
    return v


def validate_entry(d, partial=False):
    if not isinstance(d, dict):
        raise ValueError("el perfil debe ser un objeto JSON")
    out = {k: d[k] for k in FIELDS if k in d}
    if not partial:
        for k in ("id", "name", "method"):
            if not out.get(k):
                raise ValueError("falta el campo '%s'" % k)
    if "id" in out:
        out["id"] = str(out["id"]).strip().lower()
        if not ID_RE.match(out["id"]) or out["id"] in RESERVED_IDS:
            raise ValueError("id invalido (a-z, 0-9, _ y -, de 3 a 64 caracteres)")
    if "name" in out:
        out["name"] = str(out["name"]).strip()[:80]
        if not out["name"]:
            raise ValueError("name vacio")
    if "method" in out and out["method"] not in METHODS:
        raise ValueError("method invalido; usa: " + ", ".join(sorted(METHODS)))
    if "country" in out:
        c = str(out["country"] or "").strip().upper()
        if c and not re.match(r"^[A-Z]{2}$", c):
            raise ValueError("country debe ser un codigo de 2 letras (CO, MX...)")
        out["country"] = c
    if "carrier" in out:
        out["carrier"] = str(out["carrier"] or "").strip()[:40]
    if "enabled" in out:
        enabled = out["enabled"]
        if isinstance(enabled, bool):
            out["enabled"] = enabled
        elif isinstance(enabled, str) and enabled.strip().lower() in ("true", "false"):
            out["enabled"] = enabled.strip().lower() == "true"
        else:
            raise ValueError("enabled debe ser booleano")
    if "front" in out:
        out["front"] = _host(out["front"], "front")
    if "sni" in out:
        out["sni"] = _host(out["sni"], "sni")
    if "proxy_host" in out:
        out["proxy_host"] = _host(out["proxy_host"], "proxy_host")
    if "port" in out:
        out["port"] = _int(out["port"], 0, 65535, "port")
    if "proxy_port" in out:
        out["proxy_port"] = _int(out["proxy_port"] or 0, 0, 65535, "proxy_port")
    if "dns_resolver" in out:
        r = str(out["dns_resolver"] or "").strip()
        if r and (not IP_RE.match(r) or any(int(part) > 255 for part in r.split("."))):
            raise ValueError("dns_resolver debe ser una IP")
        out["dns_resolver"] = r
    if "payload" in out:
        out["payload"] = str(out["payload"] or "")
        if len(out["payload"]) > 3000:
            raise ValueError("payload muy largo (max 3000)")
    if "notes" in out:
        out["notes"] = str(out["notes"] or "")[:300]
    for k in ("udp_up", "udp_down"):
        if k in out:
            out[k] = str(out[k] or "").strip()[:10]
    if "v2" in out:
        v = out["v2"] or {}
        if not isinstance(v, dict):
            raise ValueError("v2 debe ser un objeto")
        nv = {}
        nv["protocol"] = str(v.get("protocol", "vmess")).lower()
        if nv["protocol"] not in ("vmess", "vless", "trojan"):
            raise ValueError("v2.protocol: vmess, vless o trojan")
        nv["security"] = str(v.get("security", "none")).lower()
        if nv["security"] not in ("none", "tls"):
            raise ValueError("v2.security: none o tls")
        if v.get("port"):
            nv["port"] = _int(v["port"], 1, 65535, "v2.port")
        nv["host"] = _host(v.get("host", "{DOMAIN}"), "v2.host") or "{DOMAIN}"
        nv["sni"] = _host(v.get("sni", ""), "v2.sni")
        path = str(v.get("path", "auto") or "auto")
        if path != "auto" and not path.startswith("/"):
            raise ValueError("v2.path debe empezar con / o ser 'auto'")
        nv["path"] = path[:120]
        out["v2"] = nv
    if not partial:
        m = out["method"]
        out.setdefault("country", "")
        out.setdefault("carrier", "")
        out.setdefault("enabled", True)
        out.setdefault("front", "{DOMAIN}")
        out.setdefault("port", DEFAULT_PORT[m])
        out.setdefault("sni", "")
        out.setdefault("payload", "")
        out.setdefault("proxy_host", "")
        out.setdefault("proxy_port", 0)
        out.setdefault("dns_resolver", "")
        out.setdefault("notes", "")
        out.setdefault("udp_up", "")
        out.setdefault("udp_down", "")
        if m == "v2ray":
            out.setdefault("v2", {"protocol": "vmess", "security": "none", "host": "{DOMAIN}",
                                  "sni": "", "path": "auto"})
        else:
            out.pop("v2", None)
    return out


# ───────────────────────── huella del certificado del VPS ─────────────────────────
_PIN_CACHE = {}


def cert_info(sni=""):
    """Huella SHA-256 (hex minusculas, sin ':') del certificado que sirve el VPS en :443.
    Se calcula contra 127.0.0.1:443 con el SNI pedido. JM_CERT_PIN la fija a mano."""
    fixed = os.environ.get("JM_CERT_PIN", "").strip().lower().replace(":", "")
    if fixed:
        return {"pin": fixed, "self_signed": True, "subject": "", "source": "env"}
    host = os.environ.get("JM_PIN_HOST", "127.0.0.1")
    port = int(os.environ.get("JM_PIN_PORT", "443"))
    key = (host, port, sni)
    hit = _PIN_CACHE.get(key)
    if hit and time.time() - hit[0] < 300:
        return hit[1]
    der = None
    source = "tls"
    try:
        ctx = ssl.SSLContext(ssl.PROTOCOL_TLS_CLIENT)
        ctx.check_hostname = False
        ctx.verify_mode = ssl.CERT_NONE
        with socket.create_connection((host, port), timeout=5) as s:
            with ctx.wrap_socket(s, server_hostname=sni or None) as t:
                der = t.getpeercert(binary_form=True)
    except Exception:
        crt = rd("/etc/xray/xray.crt")
        if crt:
            try:
                der = ssl.PEM_cert_to_DER_cert(crt[crt.index("-----BEGIN"):crt.index("-----END CERTIFICATE-----") + 25])
                source = "xray.crt"
            except ValueError:
                der = None
    if not der:
        return {"pin": "", "self_signed": False, "subject": "", "source": "none"}
    info = {"pin": hashlib.sha256(der).hexdigest(), "self_signed": True, "subject": "", "source": source}
    if not DRY:
        try:
            pem = ssl.DER_cert_to_PEM_cert(der)
            r = subprocess.run(["openssl", "x509", "-noout", "-subject", "-issuer"], input=pem,
                               capture_output=True, text=True, timeout=5)
            subj = re.search(r"subject=\s*(.*)", r.stdout)
            iss = re.search(r"issuer=\s*(.*)", r.stdout)
            if subj and iss:
                info["subject"] = subj.group(1).strip()
                info["self_signed"] = subj.group(1).strip() == iss.group(1).strip()
        except Exception:
            pass
    _PIN_CACHE[key] = (time.time(), info)
    return info


# ───────────────────────── generador del .avg ─────────────────────────
def acct_ctx(acct):
    p = acct.get("protocols", {})
    return {"domain": acct.get("host", ""), "user": acct.get("username", ""),
            "pass": acct.get("password", ""), "uuid": acct.get("uuid", ""),
            "exp_ms": int(acct.get("expires_at_epoch", 0)) * 1000,
            "slow": p.get("slowdns", {}), "udp": p.get("udp_hysteria", {}), "p": p}


def fill(s, ctx, front=""):
    return (str(s or "").replace("{DOMAIN}", ctx["domain"]).replace("{FRONT}", front)
            .replace("{USER}", ctx["user"]).replace("{PASS}", ctx["pass"]).replace("{UUID}", ctx["uuid"]))


def _tls_settings(sni, domain):
    info = cert_info(sni)
    if not info["pin"]:
        raise ValueError("no se pudo leer el certificado del VPS en el puerto 443 (revisa /api/v1/pin)")
    tls = {"serverName": sni or domain}
    if info["pin"] and info["self_signed"]:
        tls["pinnedPeerCertSha256"] = info["pin"]      # certificado autofirmado: se fija la huella
    elif sni and domain and sni.lower() != domain.lower():
        tls["verifyPeerCertByName"] = domain           # CA real: se valida contra el dominio real
    return tls


def build_v2ray_json(entry, ctx):
    v2 = entry.get("v2") or {}
    proto = v2.get("protocol", "vmess")
    sec = v2.get("security", "none")
    addr = fill(entry.get("front") or "{DOMAIN}", ctx)
    port = int(v2.get("port") or entry.get("port") or (443 if sec == "tls" else 80))
    host = fill(v2.get("host") or "{DOMAIN}", ctx)
    sni = fill(v2.get("sni", ""), ctx)
    if not ctx["uuid"]:
        raise ValueError("la cuenta no tiene UUID (Xray no esta instalado en el VPS)")
    if not ctx["p"].get("vmess", {}).get("installed"):
        raise ValueError("Xray no esta activo en el VPS")
    path = v2.get("path") or "auto"
    if path == "auto":
        path = ctx["p"].get(proto, {}).get("ws_path") or "/"
    if proto == "vmess":
        out = {"mux": {"concurrency": 8, "enabled": False}, "protocol": "vmess",
               "settings": {"vnext": [{"address": addr, "port": port, "users": [
                   {"alterId": 0, "encryption": "auto", "id": ctx["uuid"], "flow": "", "level": 8,
                    "security": "auto"}]}]}}
    elif proto == "vless":
        out = {"mux": {"concurrency": 8, "enabled": False}, "protocol": "vless",
               "settings": {"vnext": [{"address": addr, "port": port, "users": [
                   {"id": ctx["uuid"], "encryption": "none", "level": 8}]}]}}
    else:
        out = {"mux": {"concurrency": 8, "enabled": False}, "protocol": "trojan",
               "settings": {"servers": [{"address": addr, "port": port, "password": ctx["uuid"], "level": 8}]}}
    stream = {"network": "ws", "security": sec,
              "wsSettings": {"headers": {"Host": host}, "path": path}}
    if sec == "tls":
        stream["tlsSettings"] = _tls_settings(sni or host, ctx["domain"])
    else:
        stream["security"] = "none"
    out["streamSettings"] = stream
    out["tag"] = "proxy"
    cfg = {"dns": {"hosts": {"domain:googleapis.cn": "googleapis.com"}, "servers": ["1.1.1.1"]},
           "inbounds": [
               {"listen": "127.0.0.1", "port": 10808, "protocol": "socks",
                "settings": {"auth": "noauth", "udp": True, "userLevel": 8},
                "sniffing": {"destOverride": ["http", "tls"], "enabled": False}, "tag": "socks"},
               {"listen": "127.0.0.1", "port": 10809, "protocol": "http",
                "settings": {"userLevel": 8}, "tag": "http"}],
           "log": {"loglevel": "warning"},
           "outbounds": [out, {"tag": "direct", "protocol": "freedom", "settings": {}},
                         {"tag": "block", "protocol": "blackhole", "settings": {"response": {"type": "http"}}}],
           "policy": {"levels": {"8": {"connIdle": 300, "downlinkOnly": 1, "handshake": 4, "uplinkOnly": 1}},
                      "system": {"statsOutboundUplink": True, "statsOutboundDownlink": True}},
           "routing": {"domainStrategy": "IPIfNonMatch",
                       "rules": [{"type": "field", "ip": ["1.1.1.1"], "port": "53", "outboundTag": "proxy"}]},
           "stats": {}}
    return json.dumps(cfg), addr, port


def build_props(entry, acct):
    """Devuelve (lista ordenada de (clave, valor), advertencias)."""
    ctx = acct_ctx(acct)
    if not ctx["domain"]:
        raise ValueError("el VPS no tiene dominio configurado (/etc/xray/domain)")
    m = entry["method"]
    front = fill(entry.get("front") or "{DOMAIN}", ctx)
    port = entry.get("port") or DEFAULT_PORT[m]
    sni = fill(entry.get("sni", ""), ctx)
    payload = fill(entry.get("payload", ""), ctx, front)
    warns = []
    kv = {"file.appVersionCode": "1", "file.validade": str(ctx["exp_ms"]), "file.proteger": "0",
          "file.msg": entry["name"], "Name": entry["name"], "Info": "Conexion Segura",
          "FLAG": entry.get("country") or "US", "ServerIP": front, "ServerPort": str(port),
          "SSLPort": "", "ProxyIP": "", "ProxyPort": "", "ServerUser": ctx["user"],
          "ServerPass": ctx["pass"], "Payload": "", "SNI": "", "Slowdns": "", "Slowchave": "",
          "Nameserver": ""}
    flags = {}
    if m == "ssh_direct":
        kv["Payload"] = payload
        flags["isDirect"] = "true"
    elif m == "ssh_proxy":
        if not entry.get("proxy_host"):
            raise ValueError("ssh_proxy necesita proxy_host")
        kv["Payload"] = payload
        kv["ProxyIP"] = fill(entry["proxy_host"], ctx)
        kv["ProxyPort"] = str(entry.get("proxy_port") or 80)
        flags["isInject"] = "true"
    elif m == "ssh_ssl":
        kv["SSLPort"] = str(port)
        kv["SNI"] = sni
        flags["isSSL"] = "true"
    elif m == "payload_ssl":
        kv["SSLPort"] = str(port)
        kv["SNI"] = sni
        kv["Payload"] = payload
        flags["isPayloadSSL"] = "true"
    elif m == "slowdns":
        s = ctx["slow"]
        if not (s.get("installed") and s.get("nameserver") and s.get("public_key")):
            raise ValueError("SlowDNS no esta instalado en el VPS")
        kv["ServerIP"] = "127.0.0.1"
        kv["ServerPort"] = str(port or 2222)
        kv["Slowdns"] = entry.get("dns_resolver") or "8.8.8.8"
        kv["Slowchave"] = s["public_key"]
        kv["Nameserver"] = s["nameserver"]
        flags["isSlow"] = "true"
    elif m == "udp":
        u = ctx["udp"]
        if not u.get("installed"):
            raise ValueError("UDP (Hysteria) no esta instalado en el VPS")
        kv["ServerIP"] = ctx["domain"]
        kv["ServerPort"] = ""
        kv["ServerUser"] = ""
        kv["ServerPass"] = ""
        kv["UdpServer"] = ctx["domain"]
        kv["UdpPort"] = u.get("port_range", "")
        kv["UdpObfs"] = u.get("obfs", "")
        kv["UdpAuth"] = "%s:%s" % (ctx["user"], ctx["pass"])
        kv["UdpUp"] = entry.get("udp_up", "")
        kv["UdpDown"] = entry.get("udp_down", "")
        flags["isUdp"] = "true"
    elif m == "v2ray":
        js, addr, vport = build_v2ray_json(entry, ctx)
        kv["ServerIP"], kv["ServerPort"] = addr, str(vport)
        kv["ServerUser"] = kv["ServerPass"] = ""
        kv["SNI"] = fill((entry.get("v2") or {}).get("sni", ""), ctx)
        kv["Json"] = kv["v2rayJson"] = kv["ZYuHTCH"] = js
        flags["isV2ray"] = "true"
    props = list(kv.items())
    props.append(("tunnelType", str(METHODS[m])))
    props.extend(flags.items())
    if m.startswith("ssh") or m in ("payload_ssl", "slowdns"):
        props.append(("plainPass", "1"))     # el servidor SSH es normal: contraseña sin firmar
    return props, warns


def render_avg(props):
    from xml.sax.saxutils import escape
    lines = ['<?xml version="1.0" encoding="UTF-8"?>',
             '<!DOCTYPE properties SYSTEM "http://java.sun.com/dtd/properties.dtd">', "<properties>"]
    for k, v in props:
        lines.append('<entry key="%s">%s</entry>' % (escape(k), escape(str(v))))
    lines.append("</properties>")
    return "\n".join(lines) + "\n"


def make_config(entry, acct):
    props, warns = build_props(entry, acct)
    xml = render_avg(props)
    link = LINK_PREFIX + base64.b64encode(xml.encode("utf-8")).decode()
    user = acct.get("username", "")
    return {"id": entry["id"], "name": entry["name"], "country": entry.get("country", ""),
            "carrier": entry.get("carrier", ""), "method": entry["method"],
            "filename": "%s_%s.avg" % (slug(entry["name"], 40) or entry["id"], user),
            "link": link, "avg": xml, "warnings": warns}


def inline_profile(raw, n=0):
    """Valida un perfil recibido en el cuerpo de la peticion (el id es opcional)."""
    raw = dict(raw) if isinstance(raw, dict) else raw
    if isinstance(raw, dict) and not raw.get("id"):
        raw["id"] = "perfil-%d" % (n + 1)
    return validate_entry(raw)


def render_profiles(acct, profiles):
    """Genera cada perfil con la cuenta dada. Devuelve (generados, omitidos)."""
    done, skipped = [], []
    for n, raw in enumerate(profiles):
        try:
            done.append(make_config(inline_profile(raw, n), acct))
        except (ValueError, TypeError, AttributeError) as ex:
            name = raw.get("name", "") if isinstance(raw, dict) else ""
            skipped.append({"index": n, "name": name, "reason": str(ex)})
    return done, skipped


def load_account(user):
    if not USER_RE.match(user):
        return None
    try:
        rec = json.loads(rd(acct_file(user)) or "null")
    except ValueError:
        return None
    return rec


def sample_account():
    """Cuenta de muestra (no se crea nada) para previsualizar un perfil con los datos reales del VPS."""
    now = int(time.time())
    rec = {"username": "usuario", "password": "clave", "uuid": "11111111-2222-3333-4444-555555555555",
           "ip_limit": 1, "panel_exp": "", "created_at": now, "expires_at": now + HOURS * 3600}
    return build_json(rec)


def get_or_create_account(username=None, password=None, ip_limit=1):
    """Si la cuenta ya existe (y no vencio) la reutiliza; si no, la crea."""
    with LOCK:
        rec = load_account(username) if username else None
        if rec and rec.get("expires_at", 0) > time.time():
            if password and password != rec.get("password"):
                raise FileExistsError("la cuenta ya existe en este VPS con otra clave")
            res = build_json(rec)
            res["created"] = False
            return res
        res = create_account(username, password, ip_limit)
        res["created"] = True
        return res


def vps_info():
    s = sample_account()
    p = s["protocols"]
    pin = cert_info("")
    xray_installed = svc_exists("xray")
    xray_active = DRY or svc_active("xray")
    return {"host": s["host"], "ssh_ports": p["ssh"]["ports"],
            "xray": xray_active, "xray_installed": xray_installed, "xray_active": xray_active,
            "slowdns": bool(p["slowdns"].get("installed")),
            "udp_zivpn": bool(p["udp_zivpn"].get("installed")), "udp_hysteria": bool(p["udp_hysteria"].get("installed")),
            "udp_custom": bool(p["udp_custom"].get("installed")), "cert_pin": pin["pin"],
            "cert_self_signed": pin["self_signed"], "cert_source": pin["source"],
            "duration_hours": HOURS}

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
        if n > 1024 * 1024:
            raise ValueError("body muy grande (maximo 1 MB)")
        raw = self.rfile.read(n) if n else b""
        return json.loads(raw.decode() or "{}")

    def route(self, method):
        path = self.path.split("?")[0].rstrip("/")
        if not self.authed():
            return self.send(401, {"ok": False, "error": "no autorizado"})
        try:
            if path == "/api/v1/users" and method == "POST":
                b = self.body()
                duration = int(b.get("duration_hours", HOURS))
                if duration != HOURS:
                    raise ValueError("la duracion debe ser exactamente %d horas" % HOURS)
                with LOCK:
                    res = create_account(b.get("username"), b.get("password"), int(b.get("ip_limit", 1)))
                return self.send(201, res)
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
            if path == "/api/v1/info" and method == "GET":
                return self.send(200, dict(ok=True, **vps_info()))
            if path == "/api/v1/pin" and method == "GET":
                q = parse_qs(urlparse(self.path).query)
                return self.send(200, dict(ok=True, **cert_info((q.get("sni") or [""])[0].strip())))
            if path == "/api/v1/preview" and method == "POST":
                b = self.body()
                done, skipped = render_profiles(sample_account(), [b.get("profile") or {}])
                if not done:
                    return self.send(422, {"ok": False, "error": skipped[0]["reason"]})
                return self.send(200, dict(ok=True, preview=True, **done[0]))
            if path == "/api/v1/render" and method == "POST":
                b = self.body()
                profiles = b.get("profiles") if isinstance(b.get("profiles"), list) else [b.get("profile")]
                if not profiles or not all(isinstance(p, dict) for p in profiles):
                    raise ValueError("envia 'profile' (objeto) o 'profiles' (lista de objetos)")
                if len(profiles) > 200:
                    raise ValueError("maximo 200 perfiles por peticion")
                acct = get_or_create_account(b.get("username"), b.get("password"), int(b.get("ip_limit", 1)))
                done, skipped = render_profiles(acct, profiles)
                if not done:
                    return self.send(422, {"ok": False, "error": "ningun perfil pudo generarse", "skipped": skipped})
                return self.send(200, {"ok": True,
                                       "account": {"username": acct["username"], "password": acct["password"],
                                                   "host": acct["host"], "created": acct.get("created", False),
                                                   "created_at": acct["created_at"], "expires_at": acct["expires_at"],
                                                   "expires_at_epoch": acct["expires_at_epoch"]},
                                       "configs": done, "skipped": skipped})
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
    elif cmd == "pin":
        print(json.dumps(cert_info(sys.argv[2] if len(sys.argv) > 2 else ""), indent=1))
    elif cmd == "preview" and len(sys.argv) > 2:
        done, skipped = render_profiles(sample_account(), [json.load(open(sys.argv[2], encoding="utf-8"))])
        print(done[0]["avg"] if done else skipped[0]["reason"])
    elif cmd == "render" and len(sys.argv) > 3:
        acct = get_or_create_account(sys.argv[2])
        done, skipped = render_profiles(acct, [json.load(open(sys.argv[3], encoding="utf-8"))])
        if not done:
            sys.exit(skipped[0]["reason"])
        print(done[0]["link"] if "--link" in sys.argv else done[0]["avg"])
    else:
        print(__doc__)


if __name__ == "__main__":
    main()


