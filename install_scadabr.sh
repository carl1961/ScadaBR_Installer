#!/bin/bash
# This script can install ScadaBR-EF and other ScadaBR
# versions in Linux based systems

function checkFiles {
	cd "$CURRENT_FOLDER"
	
    if [[ -f "$java" ]] && [[ -f "$tomcat" ]] && [[ -f "$scadabr" ]] ; then
		# Installer files present, continue
		echo "Files present! Lets go to install!"
    else
		# Files not present. Abort
		echo "ERROR: Java, ScadaBR and/or Tomcat files not found! Aborting." 
		exit 1
    fi
}


function createInstallFolder {
	if [[ -d $INSTALL_FOLDER ]]; then
		# Install folder already exists. Is ScadaBR already installed?
		echo "ERROR: Installation folder ($INSTALL_FOLDER) already exists. Aborting."
		exit 1
	else
		mkdir -p "$INSTALL_FOLDER"
	fi
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
	chmod 755 -R *jre* || chmod 755 -R *jdk*
	
	echo "   * Creating JRE symlink..."
	ln -s *jre* jre || ln -s *jdk* jre
	
	echo "Done."
	echo
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
	
	echo "   * Extracting ScadaBR into Tomcat..."
	mkdir -p "${INSTALL_FOLDER}/tomcat/webapps/ScadaBR"
	unzip "${CURRENT_FOLDER}/${scadabr}" -d "${INSTALL_FOLDER}/tomcat/webapps/ScadaBR" > /tmp/scadabrInstall.log 2>&1
	
	echo "   * Setting permissions..."
	chmod 755 -R tomcat/
	
	echo "Done."
	echo
}

function getTomcatSettings {
	echo
	echo "=== Tomcat configuration ==="
	
	key=n
	
	while [[ $key == "n" ]]; do
		read -p "Define Tomcat port (default: 8080): " TOMCAT_PORT
		read -p "Define a username for tomcat-manager (default: tomcat): " TOMCAT_USER
		read -p "Define a password for created user: " TOMCAT_PASSWORD
		echo "============================"
		
		[[ $TOMCAT_PORT -gt 0 ]] || TOMCAT_PORT=8080
		[[ -n $TOMCAT_USER ]] || TOMCAT_USER=tomcat
		[[ -n $TOMCAT_PASSWORD ]] || TOMCAT_PASSWORD=!tc${RANDOM}
		
		echo
		echo "Tomcat port will be set to: $TOMCAT_PORT"
		echo
		echo "The following user will be created to access tomcat-manager:"
		echo "Username: \"$TOMCAT_USER\""
		echo "Password: \"$TOMCAT_PASSWORD\""
		echo
		echo "Type n to change data or press ENTER to continue."
		read key
	done
	echo
}

function getLibraryPath {
	cd "${CURRENT_FOLDER}"
	
	# Prefer system-wide java, if installed
	if java -version > /dev/null 2>&1; then
		CUR_LIB_PATH=$(java libraryPath)
	else
		CUR_LIB_PATH=$("${INSTALL_FOLDER}/jre/bin/java" libraryPath)
	fi
	
	# Add RXTX path (in Ubuntu/Mint) to library path
	if [[ "$CUR_LIB_PATH" == *"/usr/lib/jni"* ]]; then
		LIBRARY_PATH=$CUR_LIB_PATH
	else
		LIBRARY_PATH="${CUR_LIB_PATH}:/usr/lib/jni"
	fi
}

function changeTomcatSettings {
	# Change tomcat port
	sed -i "s/port=\"8080\"/port=\"${TOMCAT_PORT}\"/" "${INSTALL_FOLDER}/tomcat/conf/server.xml"
	
	# Create manager-gui user
	sed -i '/<\/tomcat-users>/ i <role rolename="manager-gui"\/>' "${INSTALL_FOLDER}/tomcat/conf/tomcat-users.xml"
	sed -i "/<\/tomcat-users>/ i <user username=\"${TOMCAT_USER}\" password=\"${TOMCAT_PASSWORD}\" roles=\"manager-gui\"\/>" "${INSTALL_FOLDER}/tomcat/conf/tomcat-users.xml"
	
	# Set Tomcat environment options
	getLibraryPath
	
	> "${INSTALL_FOLDER}/tomcat/bin/setenv.sh"
	echo '#!bin/bash' >> "${INSTALL_FOLDER}/tomcat/bin/setenv.sh"
	echo "JAVA_HOME=\"${INSTALL_FOLDER}/jre\"" >> "${INSTALL_FOLDER}/tomcat/bin/setenv.sh"
	echo "JAVA_OPTS=\"\${JAVA_OPTS} -Dfile.encoding=UTF-8 -Djavax.servlet.request.encoding=UTF-8 -Djava.library.path=${LIBRARY_PATH}\"" >> "${INSTALL_FOLDER}/tomcat/bin/setenv.sh"
	
	chmod 755 "${INSTALL_FOLDER}/tomcat/bin/setenv.sh"
}

# In future, this will create an init service at startup
# For now, we will use a crontab workaround
function createStartupService {
	echo
	echo "Creating startup service..."
	
	# Add tomcat to crontab jobs, if it hasn't been added yet
	if [[ "$(crontab -l)" != *"${INSTALL_FOLDER}/tomcat/bin/startup.sh"* ]]; then
		# Get current crontab config
		crontab -l > /tmp/scadabr_crontab.tmp		
		# Add an entry for tomcat
		echo "@reboot ${INSTALL_FOLDER}/tomcat/bin/startup.sh" >> /tmp/scadabr_crontab.tmp
		# Install new crontab config
		crontab /tmp/scadabr_crontab.tmp
	fi
}

function finishInstall {
	echo
	echo "ScadaBR-EF was successfully installed."
	echo 
	
	if [[ "$1" != 'silent' ]]; then
		echo "Launch ScadaBR-EF now? (y/n)"

		read launch
		if [[ $launch == 'y' ]] || [[ $launch == 'Y' ]]; then
			echo "Launching ScadaBR-EF..."
			"${INSTALL_FOLDER}/tomcat/bin/startup.sh" > /dev/null
		fi
	fi
		
	echo "All done. Good bye."
}

if [[ $EUID -ne 0 ]]; then
    echo "This script must be run as root. Make sure you used sudo."
    echo "Usage:"
    echo "sudo $0"
    echo "sudo $0 silent (for silent install)"
    exit 1
fi

# Setting  variables...

MACHINE_TYPE=$(uname -m)
CURRENT_FOLDER=$(pwd)
INSTALL_FOLDER=/opt/ScadaBR-EF

# Files
tomcat=apache-tomcat-9.0.46.tar.gz
scadabr=ScadaBR.war
java_x86=openlogic-openjdk-jre-8u292-b10-linux-x32.tar.gz
java_x64=OpenJDK8U-jre_x64_linux_hotspot_8u292b10.tar.gz
java_arm32=OpenJDK8U-jre_arm_linux_hotspot_8u292b10.tar.gz
java_arm64=OpenJDK8U-jre_aarch64_linux_hotspot_8u292b10.tar.gz

echo "Welcome to ScadaBR-EF installer!"
echo

case $MACHINE_TYPE in
	arm64 | armv8l | aarch64)
		echo "ARM 64-bit machine detected"
		java=$java_arm64
	;;
    
    armv6l | armv7l)
		echo "ARM 32-bit machine detected"
		java=$java_arm32
	;;
    
	x86_64)
		echo "64-bit machine detected"
		java=$java_x64
	;;
    
	*)
		echo "32-bit machine detected"
		java=$java_x86
	;;
esac

checkFiles
createInstallFolder

if [[ "$1" != 'silent' ]]; then
	getTomcatSettings
else
	TOMCAT_PORT=8080
	TOMCAT_USER=tomcat
	TOMCAT_PASSWORD=!tc${RANDOM}
	echo "Creating a tomcat-manager user with username $TOMCAT_USER and password $TOMCAT_PASSWORD"
fi

installJava
installTomcat
changeTomcatSettings
createStartupService 2> /dev/null
finishInstall
