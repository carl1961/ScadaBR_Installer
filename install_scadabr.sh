#!/bin/bash

function checkfiles {
    if [[ -f "$java" ]] && [[ -f "$tomcat" ]] && [[ -f "ScadaBR.war" ]] ; then
		# Installer files present, continue
		echo "Files present! Lets go to install!"
    else
		# Files not present. Abort
		echo "ERROR: Java, ScadaBR and/or Tomcat files not found!" 
		exit
    fi
}


function createInstallFolder {
	if [[ -d $INSTALL_FOLDER ]]; then
		# Install folder already exists. Is ScadaBR already installed?
		echo "Installation folder ($INSTALL_FOLDER) already exists. Aborting."
		exit
	else
		mkdir -p "$INSTALL_FOLDER"
	fi
}

function installTomcat {
	echo
	echo "Installing Tomcat:"

	cd "$INSTALL_FOLDER"
	
	echo "   * Copying Tomcat into installation folder"
	cp "${CURRENT_FOLDER}/$tomcat" "$INSTALL_FOLDER/$tomcat"
	
	echo "   * Extratcting tomcat files..."
	tar xvf "$tomcat" > /tmp/scadabrInstall.log && rm "$tomcat"
	
	echo "   * Renaming Tomcat folder"
	mv apache-tomcat-* tomcat
	
	echo "   * Copying ScadaBR into Tomcat..."
	cp "${CURRENT_FOLDER}/ScadaBR.war" "${INSTALL_FOLDER}/tomcat/webapps/ScadaBR.war"
	
	echo "   * Setting permissions..."
	chmod 755 -R tomcat/
	
	echo "Done."
	echo
}

function configureTomcat {
	echo
	echo "=== Tomcat configuration ==="
	
	key=n
	
	while [[ $key == "n" ]]; do
		read -p "Define Tomcat port (default: 8080): " TOMCAT_PORT
		read -p "Define a username for tomcat-manager: " TOMCAT_USER
		read -p "Define a password for created user: " TOMCAT_PASSWORD
		
		[[ $TOMCAT_PORT -gt 0 ]] || TOMCAT_PORT=8080
		[[ -n $TOMCAT_USER ]] || TOMCAT_USER=tomcat
		[[ -n $TOMCAT_PASSWORD ]] || TOMCAT_PASSWORD=tomcat${RANDOM}
		
		echo
		echo "Tomcat port will be set to $TOMCAT_PORT"
		echo "A user with name \"$TOMCAT_USER\" and password \"$TOMCAT_PASSWORD\" will be created to tomcat-manager"
		echo
		read -p "Type n to correct the entered data or press ENTER to continue..." key
	done
	echo
}

function changeTomcatSettings {
	# Change tomcat port
	sed -i "s/port=\"8080\"/port=\"${TOMCAT_PORT}\"/" "$INSTALL_FOLDER/tomcat/conf/server.xml"
	
}

function installJava {
	echo
	echo -e "Installing Java:"
	cd "$INSTALL_FOLDER"
	
	echo "   * Copying Java into installation folder"
	cp "${CURRENT_FOLDER}/$java" "$INSTALL_FOLDER/$java"
	
	echo "   * Extracting Java files..."
	tar xvzf "$java" > /tmp/scadabrInstall.log && rm "$java"
	
	echo "   * Setting permissions..."
	chmod 755 -R *jre*
	
	echo "   * Creating JRE symlink..."
	ln -s *jre* jre
	
	echo "Done."
	echo
}


if [[ $EUID -ne 0 ]]; then
    echo -e "This script must be run as root. Make sure you used sudo:"
    echo -e "sudo ./install_scadabr.sh"
    exit 1
fi

# Setting  variables...

MACHINE_TYPE=$(uname -m)
CURRENT_FOLDER=$(pwd)
INSTALL_FOLDER=/opt/patolino

tomcat=apache-tomcat-9.0.46.tar.gz
tomcat_custom=apache-tomcat-custom.tar.gz
java_custom=jdk-8-custom.tar.gz

tomcat=apache-tomcat-9.0.46.tar.gz
java_x86=openlogic-openjdk-jre-8u292-b10-linux-x32.tar.gz
java_x64=OpenJDK8U-jre_x64_linux_hotspot_8u292b10.tar.gz
java_arm32=OpenJDK8U-jre_arm_linux_hotspot_8u292b10.tar.gz
java_arm64=OpenJDK8U-jre_aarch64_linux_hotspot_8u292b10.tar.gz


if [ ${MACHINE_TYPE} == 'aarch64' ]; then
    echo "arm 64 bits machine detected"
    java=$java_arm64
    
elif [ ${MACHINE_TYPE} == 'armv7l' ]; then
    echo "arm 32 bits machine detected"
    java=$java_arm32
    
elif [ ${MACHINE_TYPE} == 'x86_64' ]; then
    echo "64-bit machine detected"
    java=$java_x64
    createInstallFolder
    installJava
    installTomcat
    configureTomcat
else
    echo "32-bit machine detected"
    java=$java_x86
fi

