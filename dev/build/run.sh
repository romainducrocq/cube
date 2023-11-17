#!/bin/bash

PYTHON_DIR="/opt/Python-3.9.18/"
PYX_TARGET="ccc"

cd ${PYX_TARGET}/
export LD_LIBRARY_PATH=${PYTHON_DIR}
./${PYX_TARGET} ${@}
