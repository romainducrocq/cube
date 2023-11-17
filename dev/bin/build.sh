#!/bin/bash

PACKAGE_NAME="ccc"

function clean () {
    if [[ "${1}" == "--clean" ]]; then
        rm *.c
        rm -r ./${PACKAGE_NAME}/
        rm -r ./build/
    fi
}

function requirements () {
    python3.9 -m pip install Cython==3.0.5
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function compile () {
    if [[ ! "${PYTHONPATH}" == *":$HOME/.python:"* ]]; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.python"
    fi

    python3.9 setup.py build_ext --inplace
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function install () {
    cp ../../${PACKAGE_NAME}/driver.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../${PACKAGE_NAME}/install.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    rm -r ../../${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi

    cp -r ./${PACKAGE_NAME}/ ../../
}

cd ../${PACKAGE_NAME}/
clean ${1}
requirements
compile
install

exit 0
