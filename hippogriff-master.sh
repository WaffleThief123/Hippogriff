#!/bin/bash

echo '
WELCOME TO....

███████╗██████╗  █████╗ ██████╗ ████████╗ █████╗       ██████╗ ██╗██████╗ ██████╗ 
██╔════╝██╔══██╗██╔══██╗██╔══██╗╚══██╔══╝██╔══██╗      ██╔══██╗██║██╔══██╗██╔══██╗
███████╗██████╔╝███████║██████╔╝   ██║   ███████║█████╗██████╔╝██║██████╔╝██║  ██║
╚════██║██╔═══╝ ██╔══██║██╔══██╗   ██║   ██╔══██║╚════╝██╔══██╗██║██╔══██╗██║  ██║
███████║██║     ██║  ██║██║  ██║   ██║   ██║  ██║      ██████╔╝██║██║  ██║██████╔╝
╚══════╝╚═╝     ╚═╝  ╚═╝╚═╝  ╚═╝   ╚═╝   ╚═╝  ╚═╝      ╚═════╝ ╚═╝╚═╝  ╚═╝╚═════╝ 

~~INSTALLER~~
______       
| ___ \      
| |_/ /_   _ 
| ___ \ | | |
| |_/ / |_| |
\____/ \__, |
        __/ |
       |___/  Beepers 🐰, Gryphon 🐦, QwertyKB 🐎

With contributions from:
batman 🦇

'

# Check for the --yes command line argument to skip yes/no prompts
if [ "$1" = "--yes" ]
then
    YES=1
else
    YES=0
fi

set -o nounset

if ! which lsb_release > /dev/null
then
    function lsb_release {
        if [ -f /etc/os-release ]
        then
            [[ "$1" = "-i" ]] && cat /etc/os-release | grep ^"ID" | cut -d= -f 2
            [[ "$1" = "-r" ]] && cat /etc/os-release | grep "VERSION_ID" | cut -d= -d'"' -f 2
        elif [ -f /etc/lsb-release ]
        then
            [[ "$1" = "-i" ]] && cat /etc/lsb-release | grep "DISTRIB_ID" | cut -d= -f 2
            [[ "$1" = "-r" ]] && cat /etc/lsb-release | grep "DISTRIB_RELEASE" | cut -d= -f 2
        else
            cat /etc/*release
        fi
    }
fi

if [ $YES -eq 0 ]
then
    distro="${1:-$(lsb_release -i|cut -f 2)}"
    distro_version="${1:-$(lsb_release -r|cut -f 2|cut -c1-2)}"
else
    distro="${2:-$(lsb_release -i|cut -f 2)}"
    distro_version="${2:-$(lsb_release -r|cut -f 2|cut -c1-2)}"
fi
REQUIRED_UTILS="wget tar python curl rename git"
APTCMD="apt"
APTGETCMD="apt-get"

if [ $distro = "Kali" ]
then
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract util-linux firmware-mod-kit cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop cpio"
elif [ $distro_version = "17" ]
then
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop srecord cpio"
elif [ $distro_version = "18" ]
then
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop srecord cpio"
else
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsprogs cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop srecord cpio $PYTHON3_APT_CANDIDATES"
fi

PYTHON3_APT_CANDIDATES="python3-crypto python3-pip python3-tk"
PYTHON3_YUM_CANDIDATES=""
FULLAPT_CANDIDATES="$APT_CANDIDATES"


###################
# Misc Global Variables
###################
PIP_COMMANDS="pip3"
PKGCMD=apt
PKGCMD_OPTS="install -y"
PKG_CANDIDATES="$APT_CANDIDATES"
PKG_PYTHON3_CANDIDATES="$PYTHON3_APT_CANDIDATES"
###################
##  Maybe: Re-implement sudo prompt
###################
# Check for root privileges
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
# Possible fix for unbound variable issue?
SUDO=sudo

##################################
#  Install Variables (Global)
##################################
MasterInstallDir=/usr/lib/hippogriff


function install_ffuf
{
    yes | $PIP_COMMANDS install lastversion
    rm -rf /tmp/ffuf/
    mkdir /tmp/ffuf
    cd /tmp/ffuf/
    lastversion -d --assets https://github.com/ffuf/ffuf/
    rename 's/ffuf_?..?..?..?_*//;' *
    
# x64 check
    arch | grep 64
    if [ $? -eq 0 ]
    then
        tar -xzf linux_amd64*
    fi
# ARM check
    arch | grep arm 
    if [ $? -eq 0 ]
    then
        tar -xzf linux_arm*
    fi
# ffuf cleanup
rm /tmp/ffuf/*.tar.gz
mkdir -p $MasterInstallDir/ffuf/ && cp /tmp/ffuf/* $MasterInstallDir/ffuf/
echo "ffuf install success"

}

function install_waybackurls
{
   source ~/.bashrc
   go get github.com/tomnomnom/waybackurls
   
}

function install_pip_package
{
    PACKAGE="$1"

    for PIP_COMMAND in $PIP_COMMANDS
    do
        $SUDO $PIP_COMMAND install $PACKAGE
    done
}

function find_path
{
    FILE_NAME="$1"
    echo -ne "checking for $FILE_NAME..."
    which $FILE_NAME > /dev/null
    if [ $? -eq 0 ]
    then
        echo "yes"
        return 0
    else
        echo "no"
        return 1
    fi
}

function install_updog
{
    $PIP_COMMANDS install updog
    echo "" >> ~/.bashrc
    echo "alias updog=~/.local/bin/updog" >> ~/.bashrc
}

function install_go
{
    wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash
}

# Make sure the user really wants to do this
if [ $YES -eq 0 ]
then
    echo " "
    echo "WARNING: This script will download and install all required and optional dependencies for Gryphon-Legion."
    echo "         This script has only been tested on, and is only intended for, Debian based systems."
    echo "         This script requires internet access."
    echo "         This script requires root privileges."
    echo ""
    if [ $distro != Unknown ]
    then
        echo "         $distro $distro_version detected"
    else
        echo "WARNING: Distro not detected, using package-manager defaults"
    fi
    echo ""
    echo -n "Continue [y/N]? "
    read YN
    if [ "$(echo "$YN" | grep -i -e 'y' -e 'yes')" == "" ]
    then
        echo "Quitting..."
        exit 1
    fi
elif [ $distro != Unknown ]
then
     echo "$distro $distro_version detected"
else
    echo "WARNING: Distro not detected, using package-manager defaults"
fi

# Check to make sure we have all the required utilities installed
NEEDED_UTILS=""
for UTIL in $REQUIRED_UTILS
do
    find_path $UTIL
    if [ $? -eq 1 ]
    then
        NEEDED_UTILS="$NEEDED_UTILS $UTIL"
    fi
done
############################################
# Do the needfull [Actually install stuff] #
############################################
cd /tmp
$SUDO $PKGCMD $PKGCMD_OPTS $PKG_CANDIDATES
if [ $? -ne 0 ]
    then
    echo "Package installation failed: $PKG_CANDIDATES"
    exit 1
fi

# Names of functions to install
install_pip_package matplotlib
install_pip_package capstone
install_ffuf
install_updog
install_go

# Requires goLang to be installed to run these
install_waybackurls

###############
# Post execution cleanup and stuff
###############
source ~/.bashrc