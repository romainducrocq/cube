#!/bin/bash

exit -1

if [ ! -d "$HOME/.python/" ]; then
    mkdir ~/.python/
fi

find ~/.python/ -maxdepth 1 -name "ccc" -type l -delete
ln -s $(pwd) ~/.python/

sudo find /usr/local/bin/ -maxdepth 1 -name "ccc" -type l -delete
sudo ln -s $(pwd)/driver.sh /usr/local/bin/ccc

exit 0
