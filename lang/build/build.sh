#!/bin/bash

PYTHON_DIR="/opt/Python-3.9.18/"
PACKAGE_NAME="ccc"

function clean () {
    if [ -f "main.o" ]; then rm main.o; fi
    if [ -f "main.c" ]; then rm main.c; fi
    if [ -f "${PACKAGE_NAME}.o" ]; then rm ${PACKAGE_NAME}.o; fi
    if [ -f "${PACKAGE_NAME}/${PACKAGE_NAME}.c" ]; then rm ${PACKAGE_NAME}/${PACKAGE_NAME}.c; fi
    if [ -f "${PACKAGE_NAME}/${PACKAGE_NAME}.h" ]; then rm ${PACKAGE_NAME}/${PACKAGE_NAME}.h; fi
}

function requirements () {
    python3.9 -m pip install Cython==3.0.5
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function prebuild () {
    mkdir -p ./${PACKAGE_NAME}/
    cd prebuild/
    ./build.sh
    if [ ${?} -ne 0 ]; then cd ../; clean; exit 1; fi
    cd ../
}

function gen_main () {
    sed -e "s/PACKAGE_NAME/${PACKAGE_NAME}/g" ./main.c.in > ./main.c
}

function cythonize () {
    cd ${PACKAGE_NAME}/
    cython -3 ${PACKAGE_NAME}.pyx
    if [ ${?} -ne 0 ]; then cd ../; clean; exit 1; fi
    cd ../
}

function compile () {
    if [ -f "${PACKAGE_NAME}/${PACKAGE_NAME}" ]; then rm ${PACKAGE_NAME}/${PACKAGE_NAME}; fi
    gcc -I${PYTHON_DIR} -I${PYTHON_DIR}Include -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall \
        -c ${PACKAGE_NAME}/*.c main.c
    if [ ${?} -ne 0 ]; then clean; exit 1; fi
    gcc *.o -o ${PACKAGE_NAME}/${PACKAGE_NAME} -L${PYTHON_DIR} -lpython3.9 -lcrypt -lpthread -ldl  -lutil -lm -lm
    if [ ${?} -ne 0 ]; then clean; exit 1; fi
}

function install () {
    cp ../../${PACKAGE_NAME}/driver.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../${PACKAGE_NAME}/make.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../${PACKAGE_NAME}/install.sh ./${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    rm -r ../../${PACKAGE_NAME}/*
    if [ ${?} -ne 0 ]; then exit 1; fi

    cp -r ./${PACKAGE_NAME}/* ../../${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi
    rm -r ../../${PACKAGE_NAME}/${PACKAGE_NAME}.pyx
    if [ ${?} -ne 0 ]; then exit 1; fi
}

requirements
prebuild
gen_main
cythonize
compile
clean

install

exit 0
