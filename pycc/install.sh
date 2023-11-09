#!/bin/bash

if [ ! -d "$HOME/.python/" ]; then
    mkdir ~/.python/
fi

if [ ! -L "$HOME/.python/pycc" ] && [ ! -e "$HOME/.python/pycc" ]; then
    ln -s $(pwd) ~/.python/
fi

sudo find /usr/local/bin/ -maxdepth 1 -iname "pycc" -type l -delete
sudo ln -s $(pwd)/driver.sh /usr/local/bin/pycc

if [[ "${1}" == "--cython" ]]; then
    python3.9 -m pip install Cython==3.0.5
    ./cython.sh
    if [ ${?} -ne 0 ]; then exit 1; fi

    cd ../cycc/
    if [ ! -L "$HOME/.python/cycc" ] && [ ! -e "$HOME/.python/cycc" ]; then
        ln -s $(pwd) ~/.python/
    fi

    sudo find /usr/local/bin/ -maxdepth 1 -iname "cycc" -type l -delete
    sudo ln -s $(pwd)/driver.sh /usr/local/bin/cycc
fi

exit 0
