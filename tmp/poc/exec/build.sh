#!/bin/bash

PYTHON_DIR="/opt/Python-3.9.18/"

function cythonize() {
    cd ccc/
    cython -3 ccc.pyx
    cd ../
}

function make() {
    rm main
    gcc -I${PYTHON_DIR} -I${PYTHON_DIR}Include -Wno-unused-result -Wsign-compare -DNDEBUG -g -fwrapv -O3 -Wall -c ccc/*.c main.c
    gcc *.o -o main -L${PYTHON_DIR} -lpython3.9 -lcrypt -lpthread -ldl  -lutil -lm -lm
}

function clean() {
    rm *.o ccc/*.c ccc/*.h
}

cythonize
make
clean
