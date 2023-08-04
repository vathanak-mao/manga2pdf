#!/bin/bash

if [[ -z $1 ]]; then
	echo "Please specifiy the book directory's path!"
	exit 1
else
	## Change directory to the book directory cause all the commands below must run within it.
	cd "$1"
	echo "Changed directory to $1"
fi

## -mindepth -- to remove "." from the output
## -printf -- to remove "./" from and to add ',' as separator between the output directory names
## -maxdepth -- to show only direct child directories
## The "sort -V" command sorts lines of text
## The "tr" command translates/replaces "\n" with ":" cause IFS="\n" does not work when splitting string into array
dirnames=$(find . -mindepth 1 -maxdepth 1 -type d -name '*' -printf '%P\n' | sort -V | tr "\n" ":") 
echo "[DEB] Directories: $dirnames"

IFS=":" read -r -a chapternames <<< "$dirnames" ## Must use IFS=":" cause IFS="\n" does not work
echo "[DEB] Chapters: ${chapternames[@]}"
if [[ ${#chapternames[@]} = 0 ]]; then 
	echo "[WARN] No directory for a chapter found."
fi

from=1
to=${#chapternames[@]}

argcnt=("$#")
argval=("$@")
echo "[DEB] Command-line arguments: ${argval[@]}"

## Validate arguments
for (( i=0; i<argcnt; i++ )); do
	if [[ ${argval[i]} == "-from" || ${argval[i]} == "-to" ]]; then
		if [[ ${argval[i+1]} =~ ^[1-9]+$ ]]; then
			echo "[DEB] ${argval[i+1]} is an integer"
			
			if [[ ${argval[i]} == "-from" ]]; then
				from=${argval[i+1]}
			else
				to=${argval[i+1]}			
			fi

		else 
			echo "[ERR] The ${argval[i]} argument requires a postive integer greater than zero."
			exit 1;
		fi	
	fi
done
if [[ to -lt from ]]; then
	echo "[ERR] The argument 'to' is less than 'from'."
	exit 1;
fi

echo "[DEB] from=$from, to=$to"

## Loop through all chapters
for (( idx=from ; idx<=to ; idx++ )); do
	echo $(pwd)
	## Get all file names (pages) in side the chapter directory
	pagenames=$(find "./${chapternames[idx-1]}" -type f -name '*.png' -or -name '*.jpg' -printf './%P\n' | sort -V)
	echo "[DEB] pagenames=$pagenames"
	
	## The name of output PDF file (a chapter)
	outputname="${chapternames[idx-1]}.pdf"
	
	## Merge all pages of the chapter into a single PDF file
	cd "./${chapternames[idx-1]}"
	convert -quality 90 $pagenames "../${outputname}" && echo "'${outputname}' created."
	cd ".." 
done

