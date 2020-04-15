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
    APT_CANDIDATES="git build-essential mtd-utils gzip bzip2 tar arj lhasa p7zip p7zip-full cabextract cramfsprogs cramfsswap squashfs-tools zlib1g-dev liblzma-dev liblzo2-dev sleuthkit default-jdk lzop srecord cpio $PKG_PYTHON3_CANDIDATES libyaml-dev libssl-dev libreadline-dev libncurses5-dev libgdbm-dev bison autotools-dev autoconf automake"
fi

FULLAPT_CANDIDATES="$APT_CANDIDATES"


###################
# Misc Global Variables
###################
PIP_COMMANDS="pip3"
PKGCMD=apt
PKGCMD_OPTS="install -y"
PKG_CANDIDATES="$APT_CANDIDATES"
PKG_PYTHON3_CANDIDATES="python3-crypto python3-pip python3-tk"
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


function install_ruby
{
    source ~/.bashrc
    git clone https://github.com/rbenv/rbenv.git ~/.rbenv
    cd ~/.rbenv && src/configure && make -C src
    echo "# Ruby environment variables" >> ~/.bashrc
    echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bashrc
    echo 'export PATH="$HOME/.rbenv/versions/2.7.1/bin:$PATH"'  >> ~/.bashrc
    ~/.rbenv/bin/rbenv init
    source ~/.bashrc
    mkdir -p "$(rbenv root)"/plugins
    git clone https://github.com/rbenv/ruby-build.git "$(rbenv root)"/plugins/ruby-build
    rbenv install 2.7.1
    curl -fsSL https://github.com/rbenv/rbenv-installer/raw/master/bin/rbenv-doctor | bash
}   

function install_aquatone
{
    source ~/.bashrc
    gem install aquatone
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

function install_secretz
{
    go get -u github.com/lc/secretz
    echo "enter your TravisCI api key now" && \
    read TravisCIKey && \
    echo "Please make sure this is correct." 
    echo $TravisCIKey 
    
    read -r -p "Does it look correct? [y/N] " travisCIResponse
    if [[ "$travisCIResponse" =~ ^([yY][eE][sS]|[yY])$ ]]
        then
            echo "Thank you, User! I'll go ahead and tuck this away somewhere safe."
            secretz -setkey $TravisCIKey 
        else
            echo "Sorry, Please run secretz -setkey <yourapikey> after the installer completes to add your API key." 
    fi
    
}


function install_pip_package
{
    PACKAGE="$1"

    for PIP_COMMAND in $PIP_COMMANDS
    do
        sudo $PIP_COMMAND install $PACKAGE
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
    echo "WARNING:  This script will download and install all required and optional dependencies for Gryphon-Legion."
    echo "          This script has only been tested on, and is only intended for, Debian based systems."
    echo "          This script requires internet access."
    echo "          This script requires root privileges."
    echo "          This script does take a few minutes to install, depending on CPU resources availible, as there  "
    echo "           is a decent amount of code compilation that occurs."
    echo ""
    echo ""
    echo "          This script puts files in the following directories:"
    echo "          /usr/bin/hippogriff  $HOME/.rbenv/  /tmp/ "             
    echo ""
    echo "          This script makes changes to the following file(s) "
    echo "          $HOME/.bashrc"             
    echo ""
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
sudo $PKGCMD $PKGCMD_OPTS $PKG_CANDIDATES
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
install_secretz

echo "goLang Utils Installed"
# Requires ruby
install_aquatone

echo "Ruby Utils Installed"

###############
# Post execution cleanup and stuff
###############
source ~/.bashrc
rm -rf /tmp/* 