#!/bin/bash
# Einmalige Systemanpassungen, die über Updates kommen. Läuft beim Kiosk-Start als root (sudo -n).
# Jeder Schritt prüft selbst, ob er schon erledigt ist.

# 1) Kiosk nach einem Absturz automatisch neu starten
if [ ! -f /etc/systemd/system/kiosk.service.d/pixeldorf-restart.conf ]; then
  mkdir -p /etc/systemd/system/kiosk.service.d
  printf '[Service]\nRestart=always\nRestartSec=5\n' > /etc/systemd/system/kiosk.service.d/pixeldorf-restart.conf
  systemctl daemon-reload
fi
exit 0
