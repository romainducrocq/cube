#!/bin/bash

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
    cp ../../ccc/driver.sh ./ccc/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../ccc/install.sh ./ccc/
    if [ ${?} -ne 0 ]; then exit 1; fi
    rm -r ../../ccc/
    if [ ${?} -ne 0 ]; then exit 1; fi

    cp -r ./ccc/ ../../
}

cd ../ccc/
requirements
compile
install

exit 0
