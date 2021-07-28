# ScadaBR Installer for ScadaBR-EF
(Forked from thiagoralves/ScadaBR_Installer)

## English description

Script to install ScadaBR on Linux machines, adapted to ScadaBR-EF and Java/OpenJDK 8

(The OpenJDK builds in this repository come from [AdoptOpenJDK](https://adoptopenjdk.net/) and [OpenLogic](https://www.openlogic.com/openjdk-downloads))

#### Supported architectures:
- i386 (32 bit)
- x86_64 (64 bit)
- ARM 32 bit (armv7l)
- ARM 64 bit (armv8l)

#### Installation:
- Download the sources 
 
git clone https://github.com/celsou/ScadaBR_Installer.git

#### cd ScadaBR_Installer

- Give execute permissions to `install_scadabr.sh` and `remove_scadabr.sh` scripts (through the GUI or the command `chmod + x <filename>`)
 
#### sudo chmod +x install_scadabr.sh
#### sudo chmod +x remove_scadabr.sh

- To install ScadaBR, run the script `install_scadabr.sh` using the command `./install_scadabr.sh`

#### sudo ./install_scadabr.sh

- To remove ScadaBR, run the `remove_scadabr.sh` script via the command `./remove_scadabr.sh`

#### sudo ./remove_scadabr.sh

Note: When installing, you will be asked for the port to be used in Tomcat and the username/password for tomcat-manager. If you want to do a silent installation, use the `./install_scadabr.sh silent` command. In this mode, Tomcat will be installed on port 8080 and the username and password generated for tomcat-manager will be printed on the terminal.

#### sudo ./install_scadabr.sh silent


#### Descrição em português

Script para instalar o ScadaBR em máquinas Linux, adaptado ao ScadaBR-EF e Java/OpenJDK 8

(As builds do OpenJDK presentes neste repositório vêm do [AdoptOpenJDK](https://adoptopenjdk.net/) e do [OpenLogic](https://www.openlogic.com/openjdk-downloads))

#### Arquiteturas suportadas:
- i386 (32 bit)
- x86_64 (64 bit)
- ARM 32 bit (armv7l)
- ARM 64 bit (armv8l)

#### Instalação:
- Faça o download dos sources  

git clone https://github.com/celsou/ScadaBR_Installer.git

#### cd ScadaBR_Installer

- Dê permissões de execução aos scripts `install_scadabr.sh` e `remove_scadabr.sh` (através da interface gráfica ou com o comando `chmod +x <nome_do_arquivo>`)
- 
#### sudo chmod +x install_scadabr.sh
#### sudo chmod +x remove_scadabr.sh

- Para instalar o ScadaBR, execute o script `install_scadabr.sh` através do comando `./install_scadabr.sh`
- 
#### sudo ./install_scadabr.sh

- Para remover o ScadaBR, execute o script `remove_scadabr.sh` através do comando `./remove_scadabr.sh`

#### sudo ./remove_scadabr.sh

Obs.: Ao instalar, você será perguntado pela porta a ser usada no Tomcat e o nome de usuário/senha para o tomcat-manager. Caso você deseje fazer uma instalação silenciosa, use o comando `./install_scadabr.sh silent`. Nesse modo, Tomcat será instalado na porta 8080 e será impresso no terminal o nome de usuário e senha gerados para o tomcat-manager.

#### sudo ./install_scadabr.sh silent

