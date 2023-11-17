#!/bin/bash

PYTHON_DIR="/opt/Python-3.9.18/"
PYX_TARGET="ccc"

function clean () {
    rm *.o ${PYX_TARGET}/*.c ${PYX_TARGET}/*.h
}

function requirements () {
    python3.9 -m pip install Cython==3.0.5
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function prebuild () {
    cd prebuild/
    ./build.sh
    if [ ${?} -ne 0 ]; then cd ../; clean; exit 1; fi
    cd ../
}

function cythonize () {
    cd ${PYX_TARGET}/
    cython -3 ${PYX_TARGET}.pyx
    if [ ${?} -ne 0 ]; then cd ../; clean; exit 1; fi
    cd ../
}

function compile () {
    if [ -f "${PYX_TARGET}/${PYX_TARGET}" ]; then rm ${PYX_TARGET}/${PYX_TARGET}; fi
    gcc -I${PYTHON_DIR} -I${PYTHON_DIR}Include -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall \
        -c ${PYX_TARGET}/*.c main.c
    if [ ${?} -ne 0 ]; then clean; exit 1; fi
    gcc *.o -o ${PYX_TARGET}/${PYX_TARGET} -L${PYTHON_DIR} -lpython3.9 -lcrypt -lpthread -ldl  -lutil -lm -lm
    if [ ${?} -ne 0 ]; then clean; exit 1; fi
}

#function install () {
#    cp ./ccc/ccc ./ccc/
#    if [ ${?} -ne 0 ]; then exit 1; fi
#    cp ../../ccc/install.sh ./ccc/
#    if [ ${?} -ne 0 ]; then exit 1; fi
#    rm -r ../../ccc/
#    if [ ${?} -ne 0 ]; then exit 1; fi
#
#    cp -r ./ccc/ ../../
#}

requirements
prebuild
cythonize
compile
clean
