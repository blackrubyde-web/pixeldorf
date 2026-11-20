#!/bin/bash
# Einmalige Einrichtung des Pixeldorfs mit automatischen Updates.
# Aufruf:  curl -fsSL https://raw.githubusercontent.com/blackrubyde-web/pixeldorf/main/pi/install.sh | bash
# Optional: PD_LAT=50.5 PD_LON=7.5 PD_SHIFT=2026-11-13 PD_ROT=90 vor "bash" setzen.
set -e
REPO=https://github.com/blackrubyde-web/pixeldorf.git
H="$HOME"; U=$(id -un)
echo "== Pixeldorf wird eingerichtet für $U =="

command -v git >/dev/null || sudo apt-get install -y git

OLD=""
if [ ! -d "$H/pixeldorf/.git" ]; then
  if [ -d "$H/pixeldorf" ]; then OLD="$H/pixeldorf-alt-$(date +%Y%m%d-%H%M)"; mv "$H/pixeldorf" "$OLD"; echo "Alter Ordner gesichert: $OLD"; fi
  git clone -q "$REPO" "$H/pixeldorf"
else
  git -C "$H/pixeldorf" pull -q || true
fi
chmod +x "$H"/pixeldorf/pi/*.sh "$H"/pixeldorf/pi/server.py

if [ ! -f "$H/pixeldorf/config.js" ]; then
  CID=""
  [ -n "$OLD" ] && CID=$(grep -o "spotifyClientId: '[^']*'" "$OLD/pixeldorf.html" 2>/dev/null | head -1 | cut -d"'" -f2 || true)
  TOPIC="pd-$(head -c 9 /dev/urandom | od -An -tx1 | tr -d ' \n')"
  sed -e "s|__CID__|$CID|" -e "s|__TOPIC__|$TOPIC|" -e "s|__LAT__|${PD_LAT:-50.11}|" -e "s|__LON__|${PD_LON:-8.68}|" \
      -e "s|__SHIFT__|${PD_SHIFT:-}|" -e "s|__ROT__|${PD_ROT:-90}|" "$H/pixeldorf/config.example.js" > "$H/pixeldorf/config.js"
  echo "Persönliche Einstellungen angelegt: $H/pixeldorf/config.js"
fi

if [ -f "$H/kiosk.sh" ] && [ ! -f "$H/kiosk.sh.vor-update" ]; then cp "$H/kiosk.sh" "$H/kiosk.sh.vor-update"; fi
printf '#!/bin/bash\nexec %s/pixeldorf/pi/kiosk.sh\n' "$H" > "$H/kiosk.sh"
chmod +x "$H/kiosk.sh"

sudo tee /etc/systemd/system/pixeldorf-update.service >/dev/null <<EOF
[Unit]
Description=Pixeldorf Update von GitHub
After=network-online.target
Wants=network-online.target
[Service]
Type=oneshot
ExecStart=$H/pixeldorf/pi/update.sh
EOF
sudo tee /etc/systemd/system/pixeldorf-update.timer >/dev/null <<EOF
[Unit]
Description=Pixeldorf alle 15 Minuten auf Updates pruefen
[Timer]
OnBootSec=3min
OnUnitActiveSec=15min
[Install]
WantedBy=timers.target
EOF
sudo systemctl daemon-reload
sudo systemctl enable --now pixeldorf-update.timer >/dev/null

pkill -f "http.server 8000" 2>/dev/null || true
sudo systemctl restart kiosk.service

TOPIC=$(grep -o "remoteTopic: '[^']*'" "$H/pixeldorf/config.js" | cut -d"'" -f2)
echo
echo "== FERTIG! =="
echo "Fernbedienung fuers Handy:"
echo "https://blackrubyde-web.github.io/pixeldorf/remote.html#$TOPIC"
