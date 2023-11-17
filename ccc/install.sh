#!/bin/bash

PACKAGE_NAME="ccc"

if [ ! -d "$HOME/.python/" ]; then
    mkdir ~/.python/
fi

find ~/.python/ -maxdepth 1 -name "${PACKAGE_NAME}" -type l -delete
ln -s $(pwd) ~/.python/

sudo find /usr/local/bin/ -maxdepth 1 -name "${PACKAGE_NAME}" -type l -delete
sudo ln -s $(pwd)/driver.sh /usr/local/bin/${PACKAGE_NAME}

exit 0
