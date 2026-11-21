#!/bin/bash
# Startet das Pixeldorf im Vollbild (wird vom kiosk.service aufgerufen).
# Eigene Bildschirm-Einstellungen gehören in ../pi-settings.sh (wird nie überschrieben).
DIR="$(cd "$(dirname "$0")/.." && pwd)"
export XDG_RUNTIME_DIR=/run/user/$(id -u)
export WAYLAND_DISPLAY=wayland-0

PD_OUTPUT=HDMI-A-1
PD_MODE=1280x720
PD_TRANSFORM=normal
PD_PORT=8000
[ -f "$DIR/pi-settings.sh" ] && . "$DIR/pi-settings.sh"
export PD_OUTPUT PD_MODE PD_TRANSFORM PD_PORT

# einmalige Systemanpassungen aus Updates (z. B. automatischer Neustart bei Absturz)
[ -f "$DIR/pi/migrate.sh" ] && sudo -n bash "$DIR/pi/migrate.sh" >/dev/null 2>&1

sleep 10
wlr-randr --output "$PD_OUTPUT" --on --mode "$PD_MODE" --transform "$PD_TRANSFORM" || wlr-randr --output "$PD_OUTPUT" --transform "$PD_TRANSFORM"
command -v unclutter >/dev/null && unclutter &

python3 "$DIR/pi/server.py" &
for i in 1 2 3 4 5 6 7 8 9 10; do curl -s -o /dev/null "http://127.0.0.1:$PD_PORT/api/ping" && break; sleep 1; done

PROFILE="$HOME/.config/pixeldorf-chromium"
PREF="$PROFILE/Default/Preferences"
[ -f "$PREF" ] && sed -i 's/"exited_cleanly":false/"exited_cleanly":true/; s/"exit_type":"Crashed"/"exit_type":"Normal"/' "$PREF"

exec /usr/bin/chromium --noerrdialogs --disable-infobars --user-data-dir="$PROFILE" --no-first-run \
  --disable-features=Translate --check-for-update-interval=31536000 --kiosk "http://127.0.0.1:$PD_PORT/pixeldorf.html"
