#!/bin/bash
#
# This script installs 'haproxy' package
# and sets it to run at boot

# Config file location
CFG_FILE="/etc/haproxy/haproxy.cfg"
# Config file desired permissions
CFG_PERMS=400

echo -e "\nInstalling HAProxy"

if ! [ -x /usr/bin/sudo ]; then
    echo -e "\nPlease install 'sudo' package first. Exiting.\n"
    exit 1
fi


echo -e "Updating packages repositories\n"
/usr/bin/sudo /usr/bin/apt-get update


echo -e "Installing HAProxy package\n"
/usr/bin/sudo /usr/bin/apt-get install -y haproxy

if [ $? -ne 0 ]; then
    echo -e "\nERROR installing package. Exiting\n"
    exit 1
fi

echo -e "\nPackage successfully installed."
echo "Configuration file: ${CFG_FILE}"
echo -e "\nEnabling service at startup"

/usr/bin/sudo /usr/bin/systemctl enable haproxy

echo "Fixing config file permissions (${CFG_PERMS})"
/usr/bin/sudo /usr/bin/chmod ${CFG_PERMS} ${CFG_FILE}

if [ $? -ne 0 ]; then
    echo -e "WARNING: Error while fixing permissions. Please fix them manually to ${CFG_PERMS}"
fi

echo -e "\nDONE."

exit 0
