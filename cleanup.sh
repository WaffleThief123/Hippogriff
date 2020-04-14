#!/bin/bash
# Check for root privileges
if [[ $UID != 0 ]]; then
    echo "Please run this script with sudo:"
    echo "sudo $0 $*"
    exit 1
fi
###############
# Global Vars #
###############

MasterInstallDir=/usr/lib/hippogriff


echo "This script is to enable build-testing. will not be around long."


rm -rf /tmp/*
rm -rf $MasterInstallDir
rm -rf ~/.rbenv

echo "Don't forget to clean up your ~/.bashrc!!!!"
sleep 5 && vim ~/.bashrc