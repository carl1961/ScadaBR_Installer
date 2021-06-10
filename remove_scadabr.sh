#!/bin/bash
# This script can uninstall ScadaBR-EF and other ScadaBR
# versions installed in Linux based systems

# Confirm before uninstall
function confirmUninstall {
	echo "Warning: This script will DELETE ALL SCADABR DATA, including custom files you added."
	echo
	echo "This folder will be deleted: $INSTALL_FOLDER"
	echo "Uninstall ScadaBR anyway? (y/n)"
	read response
	echo
	
	if [[ "$response" != 'y' ]] && [[ "$response" != 'Y' ]]; then
		echo "Aborting. Good bye"
		exit
	else
		echo "To confirm uninstall, please type (in lower case): 'i am sure'"
		read response
		if [[ "$response" != 'i am sure' ]]; then
			echo "You don't typed 'i am sure'. Aborting."
			echo "(If needed, run this uninstaller again.)"
			exit
		fi
	fi
}

# Stop running tomcat instances
function stopTomcat {
	echo "Stopping Tomcat..."
	
	"${INSTALL_FOLDER}/tomcat/bin/shutdown.sh" > /dev/null 2>&1
	sleep 6s
}

# Delete all files from ScadaBR installation
function removeFiles {
	echo
	
	if [[ "$INSTALL_FOLDER" == "/" ]]; then
		echo "You cannot delete your root folder! Aborting."
		exit 1
	fi
	
	if [[ -d "$INSTALL_FOLDER" ]]; then
		echo "Removing folders..."
		rm -rf "$INSTALL_FOLDER"
	else
		echo "Installation folder not found! Is ScadaBR installed?"
		echo "Aborting."
		exit 1
	fi
}

# Remove startup service (for now we are using a crontab workaround)
function removeStartupService {
	echo "Removing startup service.."
	
	# Test if there is a crontab job to startup tomcat
	if [[ "$(crontab -l)" == *"${INSTALL_FOLDER}/tomcat/bin/startup.sh"* ]]; then
		crontab -l > /tmp/scadabr_crontab.tmp		
		# Remove tomcat entry
		sed -i "s:@reboot ${INSTALL_FOLDER}/tomcat/bin/startup.sh::" /tmp/scadabr_crontab.tmp
		# Install new crontab config
		crontab /tmp/scadabr_crontab.tmp
	fi
}

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Make sure you used sudo."
    echo "Usage:"
    echo "sudo $0"
    exit 1
fi

# Setting  variables...
INSTALL_FOLDER=/opt/ScadaBR-EF


echo "Welcome to ScadaBR-EF uninstaller!"
echo
confirmUninstall
stopTomcat
removeFiles
removeStartupService
echo
echo "ScadaBR-EF was successfully removed."
