#!/bin/bash
# Holt neue Versionen von GitHub (läuft alle 15 Minuten über pixeldorf-update.timer).
# Die Seite lädt sich danach selbst neu. Nur bei Änderungen im Ordner pi/ wird der Kiosk neu gestartet.
DIR="$(cd "$(dirname "$0")/.." && pwd)"
U=$(stat -c %U "$DIR")
cd "$DIR" || exit 0
run() { if [ "$(id -un)" = "$U" ]; then "$@"; else sudo -u "$U" "$@"; fi; }

run git fetch -q origin main || exit 0
OLD=$(run git rev-parse HEAD)
NEW=$(run git rev-parse origin/main)
[ "$OLD" = "$NEW" ] && exit 0

CHANGED=$(run git diff --name-only "$OLD" "$NEW")
run git reset -q --hard origin/main
chmod +x "$DIR"/pi/*.sh "$DIR"/pi/server.py 2>/dev/null
echo "Pixeldorf aktualisiert: ${OLD:0:7} -> ${NEW:0:7}"
if echo "$CHANGED" | grep -q '^pi/'; then
  systemctl restart kiosk.service 2>/dev/null || sudo systemctl restart kiosk.service
fi
exit 0
