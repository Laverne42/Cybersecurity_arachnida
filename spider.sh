#!/bin/bash

SAVE_PATH="./data"
LINKS_PATH="./links"
LEVEL=5

while getopts "r:l:p:" FLAG
do
	case "${FLAG}" in
		l)
			LEVEL="${OPTARG}"
			echo "El nivel de recursividad por defecto es 5. El solicitado es $LEVEL"
			;;
		r)
			if [[ ${OPTARG} != *"https://"* ]]; then 
				echo "Debe introducirse la URL completa ("https://...")"
				exit
			else
				URL="${OPTARG}"
				echo "La URL es: $URL"
			fi
			;;
		p)
		if [ -z "${OPTARG}" ]; then
			SAVE_PATH="./data"
			echo "La ruta es ./data"
		else
			SAVE_PATH="${OPTARG}"
			echo "La ruta es $SAVE_PATH"
		fi
		;;
		*)	echo "Opción no válida"
		;;
	esac
done

	shift $(($OPTIND -1))
	set +x

	[ ! -d "$SAVE_PATH" ] && mkdir -p "$SAVE_PATH"
   	[ ! -d "$LINKS_PATH" ] && mkdir -p "$LINKS_PATH"
	

IMGFILE="images"
LINKFILE="links"
EXT_TXT="txt"
SRC_PATH=$(pwd)
DEEP=1
ALL_LINKS="all.links"
TEMP="temp"

echo $URL >> $LINKS_PATH/$LINKFILE.$DEEP.$EXT_TXT
N=2

cd "./$LINKS_PATH"

while [[ $N -le $LEVEL ]]
do
	for line in $(cat $LINKFILE.$DEEP.$EXT_TXT)
	do
		if [[ "$line" == ^/$ ]]
		then
			continue

		elif [[ "$line" == http* ]]
			then
			curl -sSL $line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | cut -d "'" -f2 | grep '/' | sort -u >> $LINKFILE.$N.$EXT_TXT
		elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL == https://* ]]
	   		then
			curl -sSL $URL//$line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | cut -d "'" -f2 | grep '/' | sort -u >> $LINKFILE.$N.$EXT_TXT
		elif [[ $line ==  /* ]]
	  		then
	  		curl -sSL $URL$line | awk -F '<a' '{print $2}' | awk -F 'href=' '{print $2}' | cut -d '"' -f2 | cut -d "'" -f2 | grep '/' | sort -u >> $LINKFILE.$N.$EXT_TXT
		fi
	done
		DEEP=$N
		(( N++ ))
done

cat $LINKFILE.*.$EXT_TXT | sort -u >> $ALL_LINKS.$EXT_TXT

for line in $(cat $ALL_LINKS.$EXT_TXT)
	do
	if [[ "$line" == http* ]]
		then
		curl -sSL $line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' | cut -d '"' -f2 | cut -d "'" -f2 | cut -d "?" -f1 | sort -u >> ../$IMGFILE.$EXT_TXT
	elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL == https://* ]]
		then
		curl -sSL $URL//$line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' | cut -d '"' -f2 | cut -d "'" -f2 | cut -d "?" -f1 | sort -u >> ../$IMGFILE.$EXT_TXT
	elif [[ $line ==  /* ]]
		then
		curl -sSL $URL$line | grep ".jpg\|.jpeg\|.png\|.gif\|.bmp" | awk -F '<img' '{print $2}' | awk -F 'src=' '{print $2}' | cut -d '"' -f2 | cut -d "'" -f2 | cut -d "?" -f1 | sort -u >> ../$IMGFILE.$EXT_TXT
	fi
	done

cat "../$IMGFILE.$EXT_TXT" | sort -u > "../$TEMP.$EXT_TXT"

mv ../$TEMP.$EXT_TXT ../$IMGFILE.$EXT_TXT

cd "../$SAVE_PATH"


for line in $(cat ../$IMGFILE.$EXT_TXT)
do
	if [[ "$line" == http* ]]
		then
		curl -OL $line;
	elif [[ ( $line == [a-z]* || $line == [A-Z]* || $line == [0-9]* ) && $URL == https://* ]]
	   then
		curl -OL $URL//$line
	elif [[ $line ==  /* ]]
	  	then
	  	curl -OL $URL$line;
	fi
done