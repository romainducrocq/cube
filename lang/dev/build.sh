#!/bin/bash

PACKAGE_NAME="$(cat ../build/package_name.txt)"

function clean () {
    if [[ "${1}" == "--clean" ]]; then
        rm *.c
        if [ -d "./build/" ]; then rm -r ./build/; fi
        if [ -d "./${PACKAGE_NAME}/" ]; then rm -r ./${PACKAGE_NAME}/; fi
    fi
}

function requirements () {
    python3.9 -m pip install Cython==3.0.5
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function compile () {
    if [[ ! "${PYTHONPATH}" == *":$HOME/.${PACKAGE_NAME}:"* ]]; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.${PACKAGE_NAME}"
    fi

    python3.9 setup.py build_ext --inplace
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function install () {
    cp ../../${PACKAGE_NAME}/driver.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../${PACKAGE_NAME}/configure.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../${PACKAGE_NAME}/make.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../${PACKAGE_NAME}/install.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    rm -r ../../${PACKAGE_NAME}/*
    if [ ${?} -ne 0 ]; then exit 1; fi

    cp -r ./${PACKAGE_NAME}/* ../../${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
}

cd ../${PACKAGE_NAME}/
clean ${1}
requirements
compile
install

exit 0
