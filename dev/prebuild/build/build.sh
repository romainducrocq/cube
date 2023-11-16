#!/bin/bash

PYTHON_DIR="/opt/Python-3.9.18/"
PYX_TARGET="prebuild"

function cythonize() {
    cd ../${PYX_TARGET}/
    cython -3 ${PYX_TARGET}.pyx
    cd ../build/
}

function make() {
    if [ -f "${PYX_TARGET}" ]; then rm ${PYX_TARGET}; fi
    gcc -I${PYTHON_DIR} -I${PYTHON_DIR}Include -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall \
        -c ../${PYX_TARGET}/*.c main.c
    gcc *.o -o ${PYX_TARGET} -L${PYTHON_DIR} -lpython3.9 -lcrypt -lpthread -ldl  -lutil -lm -lm
}

function clean() {
    rm *.o ../${PYX_TARGET}/*.c ../${PYX_TARGET}/*.h
}

cythonize
make
clean
