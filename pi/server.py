#!/usr/bin/env python3
"""Kleiner Webserver für das Pixeldorf auf dem Raspberry Pi.

- liefert die Dateien aus dem Projektordner aus (nur für diesen Pi: 127.0.0.1)
- /api/proxy?url=...    holt Daten von erlaubten Seiten (Nachrichten, Polarlicht, Warnungen)
- /api/screen?state=on|off  schaltet den Bildschirm an oder aus
- /api/health           Temperatur und Strom-Status des Pi
"""
import http.server, socketserver, urllib.request, urllib.parse, subprocess, os, sys, json

DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
PORT = int(os.environ.get('PD_PORT', '8000'))
OUTPUT = os.environ.get('PD_OUTPUT', 'HDMI-A-1')
MODE = os.environ.get('PD_MODE', '1280x720')
TRANSFORM = os.environ.get('PD_TRANSFORM', 'normal')
ALLOW = ('api.brightsky.dev', 'services.swpc.noaa.gov', 'tagesschau.de', 'calendar.google.com',
         'dwd.de', 'open-meteo.com')


class Handler(http.server.SimpleHTTPRequestHandler):
    def __init__(self, *a, **k):
        super().__init__(*a, directory=DIR, **k)

    def log_message(self, *a):
        pass

    def end_headers(self):
        p = self.path.split('?')[0]
        if p.endswith(('.html', '.js', '.txt')) or p.startswith('/api') or p == '/':
            self.send_header('Cache-Control', 'no-store')
        super().end_headers()

    def _send(self, code, body, ctype='text/plain; charset=utf-8'):
        self.send_response(code)
        self.send_header('Content-Type', ctype)
        self.send_header('Content-Length', str(len(body)))
        self.end_headers()
        self.wfile.write(body)

    def do_GET(self):
        u = urllib.parse.urlparse(self.path)
        q = urllib.parse.parse_qs(u.query)
        if u.path == '/api/ping':
            return self._send(200, b'ok')
        if u.path == '/api/health':
            info = {}
            try:
                t = subprocess.run(['vcgencmd', 'measure_temp'], capture_output=True, text=True, timeout=5).stdout
                info['temp'] = float(t.split('=')[1].split("'")[0])
            except Exception:
                try:
                    info['temp'] = int(open('/sys/class/thermal/thermal_zone0/temp').read()) / 1000.0
                except Exception:
                    pass
            try:
                th = subprocess.run(['vcgencmd', 'get_throttled'], capture_output=True, text=True, timeout=5).stdout
                info['throttled'] = int(th.split('=')[1].strip(), 16)
            except Exception:
                pass
            return self._send(200, json.dumps(info).encode(), 'application/json')
        if u.path == '/api/screen':
            on = q.get('state', ['on'])[0] != 'off'
            args = ['wlr-randr', '--output', OUTPUT] + (['--on', '--mode', MODE, '--transform', TRANSFORM] if on else ['--off'])
            try:
                subprocess.run(args, timeout=15, check=False)
                return self._send(200, b'ok')
            except Exception as e:
                return self._send(500, str(e).encode())
        if u.path == '/api/proxy':
            url = q.get('url', [''])[0]
            host = urllib.parse.urlparse(url).hostname or ''
            if not any(host == d or host.endswith('.' + d) for d in ALLOW):
                return self._send(403, b'not allowed')
            try:
                req = urllib.request.Request(url, headers={'User-Agent': 'Pixeldorf/1.0 (Raspberry Pi)'})
                with urllib.request.urlopen(req, timeout=20) as r:
                    data = r.read()
                    ctype = r.headers.get('Content-Type', 'application/octet-stream')
                return self._send(200, data, ctype)
            except Exception as e:
                return self._send(502, str(e).encode())
        return super().do_GET()


class Server(socketserver.ThreadingMixIn, http.server.HTTPServer):
    daemon_threads = True
    allow_reuse_address = True


if __name__ == '__main__':
    print('Pixeldorf-Server auf http://127.0.0.1:%d (%s)' % (PORT, DIR), file=sys.stderr)
    Server(('127.0.0.1', PORT), Handler).serve_forever()
