#!/bin/bash


if [[ -z $1 ]]; then
	echo "Please specifiy the book directory's path!"
	exit 1
else
	## Change directory to the book directory cause all the commands below must run within it.
	cd "$1"
	echo "Changed directory to $1"
fi

##
## -mindepth -- to remove "." from the output
## -printf -- to remove "./" from and to add ',' as separator between the output directory names
## -maxdepth -- to show only direct child directories
## The "sort -V" command sorts lines of text
## The "tr" command translates/replaces "\n" with ":" cause IFS="\n" does not work when splitting string into array
##
dirnames=$(find . -mindepth 1 -maxdepth 1 -type d -name '*' -printf '%P\n' | sort -V | tr "\n" ":") 
echo "[DEB] Directories: $dirnames"

IFS=":" read -r -a chapternames <<< "$dirnames" ## Must use IFS=":" cause IFS="\n" does not work
echo "[DEB] Chapters: ${chapternames[@]}"
if [[ ${#chapternames[@]} = 0 ]]; then 
	echo "[WARN] No directory for a chapter found."
fi

from=1
to=${#chapternames[@]}
merge=false


##
## Obtain the command-line arguments' values 
##
argcnt=("$#")
argval=("$@")
echo "[DEB] Command-line arguments: ${argval[@]}"

for (( i=0; i<argcnt; i++ )); do
	if [[ ${argval[i]} == "-from" || ${argval[i]} == "-to" ]]; then
		## If positive integer
		if [[ ${argval[i+1]} =~ (^[1-9]+[1-9]?$)|(^[1-9]+[0-9]+$) ]]; then
			echo "[DEB] ${argval[i+1]} is an integer"
			
			if [[ ${argval[i]} == "-from" ]]; then
				from=${argval[i+1]}
			else
				to=${argval[i+1]}			
			fi
		else 
			echo "[ERR] The ${argval[i]} argument requires a postive integer (greater than zero)."
			exit 1;
		fi	
	fi
	if [[ ${argval[i]} == "--merge" ]]; then
		merge=true	
	fi
done


##
## Validate the command-line arguments 
##
if [[ to -lt from ]]; then
	echo "[ERR] Invalid argument: 'to' is less than 'from'"
	exit 1;
fi
if [[ from -gt ${#chapternames[@]} ]]; then
	echo "[ERR] Invalid arugment: 'from' is greater than the number of chapters [${#chapternames[@]}]."
	exit 1;
fi
if [[ to -gt ${#chapternames[@]} ]]; then
	to=${#chapternames[@]}
fi
echo "[DEB] from=$from, to=$to"


## 
## Create a PDF file for each chapter
## 
chapter_pdfs=""
for (( idx=from ; idx<=to ; idx++ )); do ## Loop through all chapters
	## Get all file names (pages) in side the chapter directory
	pagenames=$(find "./${chapternames[idx-1]}" -type f -name '*.png' -or -name '*.jpg' -printf './%P\n' | sort -V)
	echo "[DEB] pagenames=$pagenames"
	
	## The name of output PDF file (a chapter)
	## The tr command removes spaces from the names so the convert command won't fail when merging.
	outputname=$( echo "${chapternames[idx-1]}.pdf" | tr -d "[:space:]" )
	echo "[DEB] outputname=$outputname"
	
	## Merge pages of a chapter (JPGs) into a single PDF file
	cd "./${chapternames[idx-1]}" 
	convert -quality 100 $pagenames "../${outputname}" && echo "'${outputname}' created."
	cd ".." 
	
	chapter_pdfs+="./${outputname}\n" ## When merging chapters, the convert command needs this format
done
echo "[DEB] chapter_pdfs=$chapter_pdfs"

##
## Merge multiple chapters (PDFs) into a single PDF file
##
numofchaps=${#chapternames[@]}
if [[ $merge == true && $numofchaps -gt 0 ]]; then
	mergefile=${chapternames[from-1]}
	[[ $numofchaps -gt 1 ]] && mergefile+="-${chapternames[to-1]}" 
	mergefile=$( echo "$mergefile.pdf" | tr -d "[:space:]" )
	
	chapfiles=$(echo -e $chapter_pdfs) ## interpret '\n' chars or the convert command will fails
	
	cd "$1" && convert -quality 100 $chapfiles "./${mergefile}" && echo "'${mergefile}' created."
fi


