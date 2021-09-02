#!/bin/bash
#
# This script installs 'haproxy' package
# and sets it to run at boot

echo -e "\nInstalling HAProxy"

if ! [ -x /usr/bin/sudo ]; then
    echo -e "\nPlease install 'sudo' package first. Exiting."
    exit 1
fi


echo "Updating packages repositories"
/usr/bin/sudo /usr/bin/apt-get update


echo "Installing HAProxy package"
/usr/bin/sudo /usr/bin/apt-get install -y haproxy

if [ $? -ne 0 ]; then
    echo -e "\nERROR installing package. Exiting\n"
    exit 1
fi

echo -e "\nPackage successfully installed."
echo -e "Configuration file is located in /etc/haproxy/haproxy.cfg"
echo -e "\nEnabling service at startup"

/usr/bin/sudo /usr/bin/systemctl enable haproxy

echo -e "\nDONE."

exit 0
