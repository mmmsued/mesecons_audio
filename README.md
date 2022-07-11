# Mesecons Audio Mod
![Mesecons Audio Mod](https://github.com/mmmsued/mesecons_audio)

Der Mod »Mesecons Audio« ermöglicht es, Audiodateien in Minetest einzubinden und mit mesecons zu starten. Abhängigkeit: default, mesecons.

With this mod you can use audio files in Minetest and start them with mesecons. You need the mesecons_audio privileg for setting (but not for playing). Depends: default, mesecons.
## [download](https://github.com/mmmsued/mesecons_audio)

<img src="screenshot.png">

Verwendung:
Man benötigt das Privileg »mesecons_audio«, um das Formspec des Blockes mit Rechtsklick öffnen, bearbeiten und speichern zu können. Anschließend Wird der Block mit Mesecons-Schaltern verbunden, um den Ton abzuspielen. Spieler:innen ohne »mesecons_audio«-Privileg können den Block nur abspielen.

Hinweise:
Das Dateiformat der Audiodateien muss .ogg sein (am besten Mono). Der Dateiname sollte dem Schema »ma_dateiname.ogg« folgen, wobei »ma« für »Mesecons Audio« steht. Bei Sonderzeichen im Dateinamen werden diese im Dropdown-Menü des Blocks zwar angezeigt, können aber nicht abgespielt werden.

Mit »Hearing Distance« stellt man ein, wie dicht ein:e Spieler:in vor dem Block stehen muss, damit der Ton beim Anklicken gehört werden kann. Auch alle anderen Spieler:innen in »Hearing Distance« hören den Ton.

Hat man einen Audioblock gesetzt und fügt dem Sounds-Ordner nachträglich Töne hinzu, werden diese ab Minetest-Version 5.5 beim erneuten Öffnen der Formspec automatisch angezeigt. Bis Vesion 5.4.1 muss ansonsten der gesamte Block neu gesetzt werden.

Läuft der Sound bereits, führt erneutes Anklicken des Mescon-Schalter zum kompletten Neustart des Tones.

Lizenz:
Copyright (C) 2022 Norbert Thien, multimediamobil – Region Süd, Lizenz: Creative Commons BY-SA 4.0
Copyright (C) 2022 Isidor Zeuner, Lizenz: Creative Commons BY-SA 4.0