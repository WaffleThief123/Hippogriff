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
rez0m 🍺

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
REQUIRED_UTILS="wget tar python3 curl rename git sudo "
APTCMD="apt"
APTGETCMD="apt-get"

if [ $distro = "Kali" ]
then
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract util-linux firmware-mod-kit cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop cpio libyaml-dev libssl-dev libreadline-dev libncurses5-dev libgdbm-dev bison autotools-dev autoconf automake"
elif [ $distro_version = "17" ]
then
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop srecord cpio libyaml-dev libssl-dev libreadline-dev libncurses5-dev libgdbm-dev bison autotools-devautoconf automake"
elif [ $distro_version = "18" ]
then
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop srecord cpio libyaml-dev libssl-dev libreadline-dev libncurses5-dev libgdbm-dev bison autotools-dev autoconf automake"
else
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsprogs cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop srecord cpio $PYTHON3_APT_CANDIDATES libyaml-dev libssl-dev libreadline-dev libncurses5-dev libgdbm-dev bison autotools-dev autoconf automake"
fi

PYTHON3_APT_CANDIDATES="python3-crypto python3-pip python3-tk"
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


##################################
#  Install Variables (Global)
##################################
MasterInstallDir=/usr/lib/hippogriff
mkdir $MasterInstallDir


# Possible fix for unbound variable issue?
SUDO=sudo

function install_ruby
{
    echo "RBENV_ROOT=/usr/lib/hippogriff/rbenv/" >> ~/.bashrc
    git clone https://github.com/rbenv/rbenv.git /tmp/rbenv
    git clone https://github.com/rbenv/ruby-build.git /tmp/rbenv/plugins/ruby-build
    mv /tmp/rbenv $MasterInstallDir/
    echo "# Ruby environment variables" >> ~/.bashrc
    echo 'export PATH="/usr/lib/hippogriff/rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'eval "$(rbenv init -)"' >> ~/.bashrc
    echo 'export PATH="/usr/lib/hippogriff/rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc
    source ~/.bashrc
    echo "This might take awhile depending on your CPU resources."
    rbenv install 2.7.1
    echo "" >> ~/.bashrc
    echo "# Ruby Version added as alias to run proper" ~/.bashrc
    echo "alias ruby=/usr/lib/hippogriff/rbenv/versions/2.7.1/bin/ruby" >> ~/.bashrc
}


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
    echo "# UpDog Alias for .bashrc" >> ~/.bashrc
    echo "alias updog=~/.local/bin/updog" >> ~/.bashrc
}

function install_go
{
    rm -rf ~/.go /root/.go
    sudo su -c "wget -q -O - https://raw.githubusercontent.com/canha/golang-tools-install-script/master/goinstall.sh | bash"
    source ~/.bashrc

}

function install_cloudscraper
{
    pip3 install requests rfc3987 termcolor BeautifulSoup4
    mkdir /tmp/CloudScraper
    mkdir $MasterInstallDir/CloudScraper/
    cd /tmp/CloudScraper
    wget "https://raw.githubusercontent.com/jordanpotti/CloudScraper/master/CloudScraper.py" -O /tmp/CloudScraper/cloudscraper.py
    wget "https://raw.githubusercontent.com/jordanpotti/CloudScraper/master/LICENSE" -O /tmp/CloudScraper/LICENSE
    cp /tmp/CloudScraper/* $MasterInstallDir/CloudScraper/
    echo "" >> ~/.bashrc
    echo "# CloudScraper alias for .bashrc to make work." >> ~/.bashrc
    echo 'alias cloudscraper="python3 /usr/lib/hippogriff/CloudScraper/cloudscraper.py"' >> ~/.bashrc
}

function install_linkfinder
{
    mkdir $MasterInstallDir/linkfinder/
    cd /tmp
    git clone https://github.com/GerbenJavado/LinkFinder.git
    cd /tmp/LinkFinder
    pip3 install -r requirements.txt
    cp -r * $MasterInstallDir/linkfinder/
    echo "" >> ~/.bashrc
    echo "# Linkfinder alias for .bashrc to make work." >> ~/.bashrc
    echo 'alias linkfinder="python3 /usr/lib/hippogriff/linkfinder/linkfinder.py"' >> ~/.bashrc
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
    echo "WARNING: Distro not detected, using apt-get as default package manager."
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
install_cloudscraper
install_ffuf
install_updog
install_go
install_ruby
install_linkfinder
echo "Core Utils Installed"

# Requires goLang to be installed to run these
install_waybackurls

echo "goLang Utils Installed"
# Requires ruby


echo "Ruby Utils Installed"

###############
# Post execution cleanup and stuff
###############
source ~/.bashrc
rm -rf /tmp/* 