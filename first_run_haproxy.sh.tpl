#!/bin/bash
#
# This script installs 'haproxy' package
# and sets it to run at boot

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

echo -e "\nClonning repository with haproxy config template."
git clone https://github.com/rudenkotaras/Softserve2021_HW_Redmine.git /home/ubuntu/tmp

echo -e "\nReplacing haproxy config."
cp /home/ubuntu/tmp/haproxy.cfg.tmpl ${CFG_FILE}

echo -e "\nAdding redmine backend addresses to hosts file."
/usr/bin/sudo bash -c "echo ${REDMINE0_IP} redmine0 >> /etc/hosts"
/usr/bin/sudo bash -c "echo ${REDMINE1_IP} redmine1 >> /etc/hosts"


echo "Fixing config file permissions."
/usr/bin/sudo /usr/bin/chmod 400 ${CFG_FILE}

echo "Restarting haproxy."
/usr/bin/sudo /usr/bin/systemctl restart haproxy


echo -e "\nDONE."

exit 0
