#!/bin/bash

PACKAGE_NAME="$(cat ../build/package_name.txt)"
PYTHON_VERSION="$(cat ../build/python_version.txt)"

function clean () {
    if [[ "${1}" == "--clean" ]]; then
        rm *.c
        if [ -d "./build/" ]; then rm -r ./build/; fi
        if [ -d "./${PACKAGE_NAME}/" ]; then rm -r ./${PACKAGE_NAME}/; fi
    fi
}

function compile () {
    if [[ ! "${PYTHONPATH}" == *":$HOME/.${PACKAGE_NAME}:"* ]]; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.${PACKAGE_NAME}"
    fi

    python${PYTHON_VERSION} setup.py build_ext --inplace
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function install () {
    cp ../../${PACKAGE_NAME}/package_name.txt ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
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
compile
install

exit 0
