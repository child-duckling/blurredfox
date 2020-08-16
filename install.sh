#!/usr/bin/env bash

FF_USER_DIRECTORY=""
CHROME_DIRECTORY=""
RELEASE_NAME=""

message() {
	printf "%s\n" "$*" >&2;
}

download_bf() {

	message "[>>] Downloading theme..."

	curl -LJ0 https://github.com/manilarome/blurredfox/archive/master.tar.gz | tar -xz -C /tmp/

	if [[ $? -eq 0 ]]; 
	then
		message "[>>] Copying..."

		FF_THEME="/tmp/blurredfox-master/"
		cp -r "${FF_THEME}"* "${CHROME_DIRECTORY}"

		# Move user.js to the main profile directory
		mv "${CHROME_DIRECTORY}/user.js" "../"

		if [[ $? -eq 0 ]];
		then
			rm -rf "/tmp/blurredfox-master"
		else
			message " [!!] There was a problem while copying the files. Terminating..."
			return 1
		fi
	else
		message " [!!] Problem detected while downloading the theme. Terminating..."
		return 1
	fi
	echo "░█▀▄░█░░░█░█░█▀▄░█▀▄░█▀▀░█▀▄"
	echo "░█▀▄░█░░░█░█░█▀▄░█▀▄░█▀▀░█░█"
	echo "░▀▀░░▀▀▀░▀▀▀░▀░▀░▀░▀░▀▀▀░▀▀░"
	echo "┏━┛┏━┃┃ ┃"
	echo "┏━┛┃ ┃ ┛ "
	echo "┛  ━━┛┛ ┛"
	message "blurredfox successfully installed! Enjoy!"
}

function check_profile() {
	case "$OSTYPE" in #Different Paths in Windows compared to Linux
  	msys*)    FF_USER_DIRECTORY="$(find "${HOME}AppData\Roaming\Mozilla\firefox" -maxdepth 1 -type d -regextype egrep -regex '.*[a-zA-Z0-9]+.'${1})" ;;
  	*)        FF_USER_DIRECTORY="$(find "${HOME}/.mozilla/firefox/" -maxdepth 1 -type d -regextype egrep -regex '.*[a-zA-Z0-9]+.'${1})" ;;
	esac
	 
}

function print_args() {
	echo "Usage:"
	echo ""
	echo "help	- Show this message"
	echo "stable	- Firefox Stable Build"
	echo "dev 	- Firefox Developer Edition"
	echo "beta 	- Firefox Beta"
	echo "nightly - Firefox Nightly"
	echo "esr 	- Firefox Extended Support Release"
	echo ""
	echo "Example:"
	echo "$ ./install stable"
	echo "$ ./install dev"
	echo "$ curl -fsSL https://raw.githubusercontent.com/manilarome/blurredfox/script/install.sh | bash -s -- stable"
	echo ""
	echo "Defaults to 'stable' if empty."
}

# Check args
if [[ ! -z "${@}" ]] && [[ ! -z "${1}" ]] ;
then

	if [[ "${1}" == "dev" ]];
	then
		RELEASE_NAME="Developer Edition"
		check_profile "dev-edition-default"
	elif [[ "${1}" == "beta" ]];
	then
		RELEASE_NAME="Beta"
		check_profile "default-beta"
	elif [[ "${1}" == "nightly" ]];
	then
		RELEASE_NAME="Nightly"
		check_profile "default-nightly"
	elif [[ "${1}" == "stable" ]];
	then
		RELEASE_NAME="Stable"
		check_profile "default-release"
	elif [[ "${1}" == "esr" ]];
	then
		RELEASE_NAME="ESR"
		check_profile "default-esr"
	elif [[ "${1}" == "help" ]];
	then
		print_args
		exit
	else
		echo -ne "Invalid parameter!\n"
		print_args
		exit
	fi
else
	# check_profile "(dev-edition|default)-(release|beta|nightly|default|esr)"
	RELEASE_NAME="Stable"
	check_profile "default-release"
fi

if [[ -n $FF_USER_DIRECTORY ]];
then
	message "[>>] Firefox user profile directory located..."
	CHROME_DIRECTORY="$(find "$FF_USER_DIRECTORY/" -maxdepth 1 -type d -name 'chrome')"
	if [[ -n "$CHROME_DIRECTORY" ]];
	then
		# Check if the chrome folder contains files
		shopt -s nullglob dotglob 
		content="${CHROME_DIRECTORY}/"

		# If there's a current theme, make a backup
		if [ ${#content[@]} -gt 0 ];
		then
			message "[>>] Current chrome folder is not empty. Creating a backup in the same directory..."
			
			backup_dir="${CHROME_DIRECTORY}-backup"

			# Create backup folder
			if [[ ! -d "${backup_dir}" ]];
			then
				mkdir "${backup_dir}"
			fi

			mv --backup=t "${CHROME_DIRECTORY}" "${CHROME_DIRECTORY}-backup"
			mkdir "${CHROME_DIRECTORY}"
		fi
		download_bf
	else
		message "[>>] Chrome directory does not exist! Creating one..."
		mkdir "${FF_USER_DIRECTORY}/chrome"

		# Check if backup folder exist
		if [[ $? -eq 0 ]];
		then
			CHROME_DIRECTORY="${FF_USER_DIRECTORY}/chrome"
			
			download_bf
		else
			message "[!!] There was a problem creating the directory. Terminating..."
			exit 1;
		fi
	fi

else
	message "[!!] No Firefox ${RELEASE_NAME} user profile detected! Make sure to run Firefox ${RELEASE_NAME} atleast once! Terminating..."
	exit 1;
fi
