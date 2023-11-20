#!/bin/bash

PACKAGE_NAME="$(cat ../package_name.txt)"
PYTHON_DIR="$HOME/.${PACKAGE_NAME}/Python-3.9/"
PYX_TARGET="prebuild"

function clean () {
    if [ -f "main.o" ]; then rm main.o; fi
    if [ -f "${PYX_TARGET}.o" ]; then rm ${PYX_TARGET}.o; fi
    if [ -f "${PYX_TARGET}/${PYX_TARGET}.c" ]; then rm ${PYX_TARGET}/${PYX_TARGET}.c; fi
    if [ -f "${PYX_TARGET}/${PYX_TARGET}.h" ]; then rm ${PYX_TARGET}/${PYX_TARGET}.h; fi
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

function prebuild () {
    cd ${PYX_TARGET}/
    export LD_LIBRARY_PATH=${PYTHON_DIR}
    ./${PYX_TARGET}
    if [ ${?} -ne 0 ]; then cd ../; clean; exit 1; fi
    cd ../
}

cythonize
compile
clean

prebuild

exit 0
