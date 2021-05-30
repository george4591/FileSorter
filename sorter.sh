#!/bin/bash

# ======================================================================================
# 					TEAM: Stefan George, Sandu Calin, Zagorschi Andrei                 #
# ======================================================================================
#
# 	This is a script which organizes every file from a folder in 
#	subfolders depending on their extension 
#
#
#	EXAMPLE: We have the following folder:				After script execution:
#			Folder										Folder
#			|----image1.png								|----Images
#			|											|	 L----image1.png
#			|----video1.mp4								|----Videos
#			|											|	 L----video1.mp4
#			|----code.cpp								|----bin
#			|											|	 L----code.cpp
#			L----audio.mp3								L----Music
#															 L----audio.mp3
#			
#		
#
#	The script will execute in the current folder, if the user does not change it, or  
#   in the folder that the user entered. It gets a file and creates a folder based on 
#   the file's extension (if the folder does not exist already) and it moves the file in 
#   that subfolder. 
# ======================================================================================


# Function which changes the folder which is to be sorted

function change_folder() {
	printf "Old folder: %s\n" "$DEFAULT_FOLDER"
	printf "New folder:\n>"
	read new_folder
	DEFAULT_FOLDER="$new_folder"
	printf "Sorting folder changed to %s\n" "$DEFAULT_FOLDER"
}

# Function which moves a file in the passed folder name $1
# If the folder does not exist, it will first be created

function move_file() {
	if [ ! -d "$1/" ]; then
		mkdir "$1"
    fi
    mv "$2" "$1/"
}

function sort_files() {
	# "$1" is the argument which is passed to the function. It represents the
	# name of the folder. The script will check every file from the folder "$1"
	# and while we read a file we take its type by reading the mime-type from the
	# metadata. Then depending on the type of the file we call the move_file function
	# with the specific folder name. 
 
	# Takes the whole path of the file
	path="$(readlink -f "$1")" 
	
	find "$path" -type f | while read file; do

		# File metadata reading
		# EXAMPLE: running the command on photo.png gives us: image/jpeg
		FILE_TYPE="$(file -b --mime-type "${file}")"

		# If the user activated verbose then we are printing the file type
		if [[ "$verbose" == 1 ]]; then
			printf "File Type: %s\n" "$FILE_TYPE"
		fi

		case "$FILE_TYPE" in
			image*)
				move_file "$path/Images" "${file}";;
			audio*)
				move_file "$path/Music" "${file}";;
			video/*)
				move_file "$path/Videos" "${file}";;
			*zip*|*7z*|*rar*)
				move_file "$path/Archives" "${file}";;
			*document*|*powerpoint*)
				move_file "$path/Documents" "${file}";;

			# *text/x-* targets text files that are executable aka Scripts	
			*text/x-*)
				move_file "$path/bin" "${file}";;
			*)  move_file "$path/Default" "${file}";;
		esac
	done

	printf "\n\nDONE!\n"
}



DEFAULT_FOLDER="./"
verbose=0


# =====================================MAIN==============================================

printf "\nChoose an option:\n"
	printf '%-10s %-50s \n' \
    	   '1. sort:'   'Sorts the folder(Default folder is the folder the script is in)' \
		   '2. folder(chf):'	'Changes the default folder the scripts sorts' \
		   '3. verbose:' 'Enables the printing of file metadata for each file read' \
		   '4. quit:' 'Exit the script'

	printf '>'; read option

# Infinite loop until the user exits the script
while true; do
	case "$option" in
		sort) sort_files "$DEFAULT_FOLDER";;
		folder|chf) change_folder;;
		verbose) verbose=1;;
		quit) break;; 
	esac
	printf '>'; read option
done

# ========================================================================================