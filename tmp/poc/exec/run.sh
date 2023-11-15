#!/bin/bash

PYTHON_DIR="/opt/Python-3.9.18/"

export LD_LIBRARY_PATH=${PYTHON_DIR}
./main ${@}
