#!/bin/bash

PACKAGE_NAME="$(cat ../build/package_name.txt)"
PYTHON_VERSION="$(cat ../build/python_version.txt)"

function clean () {
    echo ${@} |\
       grep -q -e "--clean"
    if [ ${?} -eq 0 ]; then
        rm *.c > /dev/null 2>&1
        if [ -d "./build/" ]; then rm -r ./build/; fi
        if [ -d "./${PACKAGE_NAME}/" ]; then rm -r ./${PACKAGE_NAME}/; fi
    fi
}

function sanitize () {
    echo ${@} |\
       grep -q -e "--sanitize"
    if [ ${?} -eq 0 ]; then
        EXTS=("pyx" "pxd")
        for EXT in "${EXTS[@]}"; do
            for FILE in $(find . -maxdepth 1 -name "*.${EXT}" -type f); do
                vi $(readlink -f ${FILE}) +'e ++ff=dos | set ff=unix | wq!'
                if [ ${?} -ne 0 ]; then exit 1; fi
            done
        done
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
    cp ../../${PACKAGE_NAME}/python_version.txt ./${PACKAGE_NAME}/
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
clean ${@}
sanitize ${@}
compile
install

exit 0
