// Persönliche Einstellungen für dein Pixeldorf.
// Diese Datei heißt auf dem Pi "config.js" und wird von Updates NIE überschrieben.
window.PD_CONFIG = {
  lat: __LAT__, lon: __LON__,          // Standort für Wetter, Sonne und Warnungen
  rot: __ROT__,                        // Bild drehen: 0, 90 oder 270
  fps: 12, quality: 'low',             // für den Raspberry Pi 3
  spotifyClientId: '__CID__',          // aus dem Spotify-Dashboard
  remoteTopic: '__TOPIC__',            // geheimer Kanal der Handy-Fernbedienung
  birthday: '',                        // 'MM-TT', z. B. '07-24'
  birthYear: 0,                        // Geburtsjahr, dann steht das Alter in der Gratulation
  screenOff: null,                     // z. B. { from: '01:00', to: '06:00' }
  shift: { start: '__SHIFT__', pattern: 'FFSSNNXXXX',   // F=Früh S=Spät N=Nacht X=frei
           times: { F: '06:00-14:00', S: '14:00-22:00', N: '22:00-06:00' } },
  reminders: [
    // { weekday: 3, from: '18:00', to: '22:00', text: 'GELBE TONNE RAUS!' }
  ]
};
