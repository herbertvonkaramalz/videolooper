#!/bin/bash
# Developed by Dominik Ponniah
# Plug-In USB-Disk with Video and use the Device or copy the Video directly to the home/video-Path.

declare -A VIDS # Eine Liste für alle Videos, die gefunden wurden

LOCAL_FILES=~/video/ # Pfad für lokale Videos
USB_FILES=/mnt/usbdisk/ # Pfad für USB-Videos
CURRENT=0 # Anzahl Videos gefunden. Beim Start immer 0.
SERVICE='omxplayer' # Programm für die Videowiedergabe
PLAYING=0 # Nummer des aktuell spielenden Videos. Beim Start immer 0.
FILE_FORMATS='.mov|.mp4|.mpg' # Erlaubte Videoformate

getvids () # Funktion, die immer wiederholt wird.
{
unset VIDS # Video-Liste komplett leeren
CURRENT=0 # Video-Anzahl zurücksetzen
IFS=$'\n' # Jede neue Zeile in der Liste ist ein neues Video
for f in `ls $LOCAL_FILES | grep -i -E $FILE_FORMATS` # Über Lokale Dateien iterieren
do
	VIDS[$CURRENT]=$LOCAL_FILES$f # Dateiname von gefundenen Elementen in VIDS-Liste schreiben
	let CURRENT+=1 # Video-Anzahl erhöhen
done
if [ -d "$USB_FILES" ]; then
  for f in `ls $USB_FILES | grep -i -E $FILE_FORMATS` # Über USB-Dateien iterieren
	do
		VIDS[$CURRENT]=$USB_FILES$f # Dateiname  von gefundenen Elementen in VIDS-Liste schreiben
		let CURRENT+=1 # Video-Anzahl erhöhen
	done
fi
}

while true; do
if ps ax | grep -v grep | grep $SERVICE > /dev/null # Prüfen, ob Video-Programm installiert ist
then
	echo 'running' # Status 'running' in Konsole ausgeben
else
	getvids # Funktion "getVids" aufrufen
	if [ $CURRENT -gt 0 ] # Wenn Videos vorhanden sind, fortfahren
	then
		let PLAYING+=1
		if [ $PLAYING -ge $CURRENT ] # Wenn wir beim letzten Video sind
		then
			PLAYING=0 # Aktuelles Video zurücksetzen (Zahl)
		fi

	 	if [ -f ${VIDS[$PLAYING]} ]; then
			/usr/bin/omxplayer -r -o hdmi ${VIDS[$PLAYING]} # Video abspielen
		fi
	else
		echo "Kein USB oder Video gefunden. Bitte Ports prüfen."
		exit
	fi
fi
done
