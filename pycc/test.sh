#!/bin/bash

LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m'

function file () {
    FILE=$(readlink -f ${1})
    FILE=${FILE%.*}
    echo "${FILE}"
}

function ret_gcc () {
    FILE=${1}
    gcc ${FILE}.c -o ${FILE} > /dev/null 2>&1 && ${1}
    echo "${?}"
}

function ret_pycc () {
    FILE=${1}
    pycc ${FILE}.c > /dev/null 2>&1 && ${1}
    echo "${?}"
}

function test_file () {
    FILE=${1}
    FILE=$(file ${FILE})

    RET_GCC=$(ret_gcc ${FILE})
    RET_PYCC=$(ret_pycc ${FILE})

    RES=""
    FILE=$(echo "${FILE}" | rev | cut -d"/" -f1 | rev)'.c'
    if [[ "${RET_GCC}" == "${RET_PYCC}" ]]; then
        RES="${LIGHT_GREEN}[y] ${FILE}${NC}"
    else
        RES="${LIGHT_RED}[n] ${FILE}${NC}"
    fi
    echo -e "${RES} -> gcc: ${RET_GCC}, pycc: ${RET_PYCC}"
}

function test_dir () {
    PASS=0
    TOTAL=0
    DIR=${1}

    for SUBDIR in $(find ${DIR} -type d); do
        DIR=$(readlink -f ${SUBDIR})
        if [[ ! "${SUBDIR: -1}" == "/" ]]; then
            SUBDIR=${SUBDIR}'/'
        fi

        for FILE in $(find ${DIR} -maxdepth 1 -name "*.c" -type f); do
            FILE=$(file ${FILE})

            RET_GCC=$(ret_gcc ${FILE})
            RET_PYCC=$(ret_pycc ${FILE})

            RES=""
            FILE=$(echo "${FILE}" | rev | cut -d"/" -f1 | rev)'.c'
            if [[ "${RET_GCC}" == "${RET_PYCC}" ]]; then
                RES="${LIGHT_GREEN}[y] ${SUBDIR}${FILE}${NC}"
                let PASS+=1
            else
                RES="${LIGHT_RED}[n] ${SUBDIR}${FILE}${NC}"
            fi
            echo -e "${RES} -> gcc: ${RET_GCC}, pycc: ${RET_PYCC}"

            let TOTAL+=1
        done
    done

    echo "----------------------------------------------------------------------"

    RES="${PASS} / ${TOTAL}"
    if [ ${PASS} -eq ${TOTAL} ]; then
        RES="${LIGHT_GREEN}PASS: ${RES}${NC}"
    else
        RES="${LIGHT_RED}FAIL: ${RES}${NC}"
    fi
    echo -e "${RES}"
}

if [ -f ${1} ]; then
    test_file ${1}
fi

if [ -d ${1} ]; then
    test_dir ${1}
fi
