# 🏰 Pixeldorf

Eine Pixel-Festung für den Raspberry Pi, die mit der Zeit wächst. Mit echtem Wetter, Tag und Nacht, Angriffen, Ereignissen, Spotify-Party, Schichtplan und Handy-Fernbedienung.

## Installation auf dem Raspberry Pi

```bash
curl -fsSL https://raw.githubusercontent.com/blackrubyde-web/pixeldorf/main/pi/install.sh | bash
```

Das Skript:
- holt das Projekt nach `~/pixeldorf`
- legt `config.js` mit den persönlichen Einstellungen an (wird nie überschrieben)
- prüft alle 15 Minuten auf Updates (`pixeldorf-update.timer`)
- startet den Kiosk neu und zeigt den Link zur Fernbedienung an

## Dateien

| Datei | Zweck |
|---|---|
| `pixeldorf.html` | das Spiel |
| `remote.html` | Handy-Fernbedienung (über ntfy.sh) |
| `config.example.js` | Vorlage für die persönliche `config.js` |
| `pi/kiosk.sh` | startet Server und Chromium im Vollbild |
| `pi/server.py` | kleiner Webserver mit Proxy und Bildschirm-Schalter |
| `pi/update.sh` | holt neue Versionen von GitHub |
| `version.txt` | ändert sich bei jedem Update, die Seite lädt sich dann selbst neu |
