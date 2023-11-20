#!/bin/bash

PACKAGE_NAME="$(cat "$(dirname "$(readlink -f "$0")")/package_name.txt")"

if [ ! -d "$HOME/.${PACKAGE_NAME}/" ]; then
    mkdir ~/.${PACKAGE_NAME}/
fi

find ~/.${PACKAGE_NAME}/ -maxdepth 1 -name "${PACKAGE_NAME}" -type l -delete
ln -s $(pwd) ~/.${PACKAGE_NAME}/

sudo find /usr/local/bin/ -maxdepth 1 -name "${PACKAGE_NAME}" -type l -delete
sudo ln -s $(pwd)/driver.sh /usr/local/bin/${PACKAGE_NAME}

exit 0
