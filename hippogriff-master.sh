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
YUMCMD="yum"
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
PYTHON2_APT_CANDIDATES="python-crypto python-lzo python-lzma python-pip python-tk"
PYTHON3_APT_CANDIDATES="python3-crypto python3-pip python3-tk"
PYTHON3_YUM_CANDIDATES=""
YUM_CANDIDATES="git gcc gcc-c++ make openssl-devel qtwebkit-devel qt-devel gzip bzip2 tar arj p7zip p7zip-plugins cabextract squashfs-tools zlib zlib-devel lzo lzo-devel xz xz-compat-libs xz-libs xz-devel xz-lzma-compat python-backports-lzma lzip pyliblzma perl-Compress-Raw-Lzma lzop srecord"
PYTHON2_YUM_CANDIDATES="python-pip python-Bottleneck cpio"
FULLAPT_CANDIDATES="$APT_CANDIDATES $PYTHON2_APT_CANDIDATES"
YUM_CANDIDATES="$YUM_CANDIDATES $PYTHON2_YUM_CANDIDATES"
PIP_COMMANDS="pip3"


###################
##  Maybe: Re-implement sudo prompt
###################
# Check for root privileges
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi


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
mkdir $MasterInstallDir/ffuf && cp -r /tmp/ffuf/ $MasterInstallDir/
echo "ffuf install success"

}

function install_waybackurls
{
   git clone github.com/tomnomnom/waybackurls
   
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
    echo ""
    echo "WARNING: This script will download and install all required and optional dependencies for Legion-Bird."
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

# Check for supported package managers and set the PKG_* envars appropriately
find_path $APTCMD
if [ $? -eq 1 ]
then
    find_path $APTGETCMD
    if [ $? -eq 1 ]
    then
        find_path $YUMCMD
        if [ $? -eq 1 ]
        then
            NEEDED_UTILS="$NEEDED_UTILS $APTCMD/$APTGETCMD/$YUMCMD"
        else
            PKGCMD="$YUMCMD"
            PKGCMD_OPTS="-y install"
            PKG_CANDIDATES="$YUM_CANDIDATES"
            PKG_PYTHON3_CANDIDATES="$PYTHON3_YUM_CANDIDATES"
        fi
    else
        PKGCMD="$APTGETCMD"
        PKGCMD_OPTS="install -y"
        PKG_CANDIDATES="$FULLAPT_CANDIDATES"
        PKG_PYTHON3_CANDIDATES="$PYTHON3_APT_CANDIDATES"
    fi
else
    if "$APTCMD" install -s -y dpkg > /dev/null
    then
        PKGCMD="$APTCMD"
        PKGCMD_OPTS="install -y"
        PKG_CANDIDATES="$APT_CANDIDATES"
        PKG_PYTHON3_CANDIDATES="$PYTHON3_APT_CANDIDATES"
    else
        PKGCMD="$APTGETCMD"
        PKGCMD_OPTS="install -y"
        PKG_CANDIDATES="$APT_CANDIDATES"
        PKG_PYTHON3_CANDIDATES="$PYTHON3_APT_CANDIDATES"
    fi
fi

if [ "$NEEDED_UTILS" != "" ]
then
    echo "Please install the following required utilities: $NEEDED_UTILS"
    exit 1
fi


# Do the needfull [install stuff]

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
