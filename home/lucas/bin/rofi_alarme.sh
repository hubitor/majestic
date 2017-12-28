#!/bin/sh
#
# Script de alarme usando o paplay, dunst e rofi.
#
# Desenvolvido por Lucas Saliés Brum <lucas@archlinux.com.br>
#
# Criado em: 28/12/17 00:52:08
# Última Atualização: 28/12/17 00:52:16
# Evaluate: ! date +"%d/%m/%y %H:%M:%S"

dependencias=("curl" "rofi" "notify-send" "mpg123")

for dep in ${dependencias[@]} 
do
	which $dep 1> /dev/null 2> /dev/null
	if [ $? != 0 ]; then
		echo
		echo "O aplicativo $dep não foi encontrado."
		echo "Abortando..."
		echo
		exit 1
	fi
done

audio="${HOME}/.alarme.mp3"
audio_web="https://github.com/sistematico/majestic/raw/master/home/lucas/audio/alarme.mp3"
icone="/usr/share/icons/Arc/devices/24@2x/video-display.png"
tema="${HOME}/.local/share/rofi/themes/sistematico-dark.rasi"

if [ ! -f $audio ]; then
	curl -L -s $audio_web > $audio
fi

if [ ! -f $tema ]; then
	curl -L -s $tema_web > $tema
fi

hora=$(rofi -theme "$tema" -dmenu -p "Formato: HH:MM (c para cancelar!):" -bw 0 -lines 2 -separator-style none -location 0 -width 300 -hide-scrollbar -padding 5)

if [ $hora ]; then
	if [ "$hora" = "c" ]; then
		killall -9 $(basename $0)
		msg="Alarme Cancelado! $(basename $0)"
	else
		date "+%H:%M" -d "$hora" > /dev/null 2>&1
		if [ $? != 0 ]; then
			msg="Hora inválida!\n\nVocê digitou: $hora \n\nFormato: (HH:MM)"
		else
			notify-send -i $icone "Rofi Alarme" "O alarme irá tocar as:\n\n$(date --date=${hora})"
			sleep $(( $(date --date="$hora" +%s) - $(date +%s) ));
			notify-send -i $icone "Rofi Alarme" "ACORDA!!!"
			while true; do
	  			/usr/bin/mpg123 $audio
	  			sleep 3
			done
			
			msg="Alarme ajustado para:\n\n${hora}"
		fi
	fi

	notify-send -i $icone "Rofi Alarme" "$msg"
fi