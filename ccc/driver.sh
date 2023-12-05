#!/bin/bash

PACKAGE_NAME="$(cat $(dirname $(readlink -f ${0}))/package_name.txt)"
PYTHON_VERSION="$(cat $(dirname $(readlink -f ${0}))/python_version.txt)"

ARGC=${#}
ARGV=(${@})

function usage () {
    echo ${@} |\
       grep -q -e "--help"
    if [ ${?} -eq 0 ]; then
        if [ -f "$HOME/.${PACKAGE_NAME}/${PACKAGE_NAME}/${PACKAGE_NAME}" ]; then
            echo "Usage: ${PACKAGE_NAME} [Help option] [Link option] FILE"
            echo ""
            echo "[Help option]:"
            echo "    --help       print help and exit"
            echo "    -v           enable verbose mode"
            echo ""
            echo "[Link option]:"
            echo "    -c           compile, but do not link"
            echo ""
            echo "FILE:            .c file to compile"
        else
            echo "Usage: ${PACKAGE_NAME} [Help option] [Debug option] [Link option] FILE"
            echo ""
            echo "[Help option]:"
            echo "    --help       print help and exit"
            echo "    -v           enable verbose mode"
            echo ""
            echo "[Debug option]:"
            echo "    --lex        print lexing and exit"
            echo "    --parse      print parsing and exit"
            echo "    --validate   print semantic analysis and exit"
            echo "    --tacky      print tac representation and exit"
            echo "    --codegen    print assembly generation and exit"
            echo "    --codeemit   print code emission and exit"
            echo "    -S           print optimization and exit"
            echo ""
            echo "[Link option]:"
            echo "    -c           compile, but do not link"
            echo ""
            echo "FILE:            .c file to compile"
        fi
        exit 0
    fi
}

function clean () {
    if [ -f ${FILE}.i ]; then rm ${FILE}.i; fi
    if [ -f ${FILE}.s ]; then rm ${FILE}.s; fi
}

function shift_arg () {
    if [ ${i} -lt ${ARGC} ]; then
        ARG="${ARGV[${i}]}"
        i=$((i+1))
        return 0
    else
        ARG=""
        return 1
    fi
}

function debug_arg () {
    if [ "${ARG}" = "--lex" ] ||\
       [ "${ARG}" = "--parse" ] ||\
       [ "${ARG}" = "--validate" ] ||\
       [ "${ARG}" = "--tacky" ] ||\
       [ "${ARG}" = "--codegen" ] ||\
       [ "${ARG}" = "--codeemit" ]; then
        DEBUG_FLAG="${ARG}"
    else
        return 1
    fi
    return 0
}

function link_arg () {
    if [ "${ARG}" = "-c" ]; then
        LINK_CODE=1
    else
        return 1
    fi
    return 0
}

function file_arg () {
    FILE=$(readlink -f ${ARG})
    FILE=${FILE%.*}
}

function parse_args () {
    i=0

    shift_arg
    if [ ${?} -ne 0 ]; then return; fi
    debug_arg

    if [ ${?} -eq 0 ]; then
        shift_arg
        if [ ${?} -ne 0 ]; then return; fi
    fi
    link_arg

    if [ ${?} -eq 0 ]; then
        shift_arg
        if [ ${?} -ne 0 ]; then return; fi
    fi
    file_arg

    if [ ${?} -eq 0 ]; then
        shift_arg
        if [ ${?} -eq 0 ]; then exit 1; fi
    else
        exit 1
    fi
}

function preprocess () {
    echo "Preprocess -> ${FILE}.c"
    gcc -E -P ${FILE}.c -o ${FILE}.i
    if [ ${?} -ne 0 ]; then clean; exit 1; fi
}

function compile () {
    if [[ ! "${PYTHONPATH}" == *":$HOME/.${PACKAGE_NAME}:"* ]] ; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.${PACKAGE_NAME}"
    fi

    echo "Compile    -> ${FILE}.i"

    if [ -f "$HOME/.${PACKAGE_NAME}/${PACKAGE_NAME}/${PACKAGE_NAME}" ]; then
        $HOME/.${PACKAGE_NAME}/${PACKAGE_NAME}/${PACKAGE_NAME} ${DEBUG_FLAG} ${FILE}.i
        if [ ${?} -ne 0 ]; then clean; exit 1; fi
    else
        python${PYTHON_VERSION} -c "from ${PACKAGE_NAME}.main_compiler import main_py; main_py()" ${DEBUG_FLAG} ${FILE}.i
        if [ ${?} -ne 0 ]; then clean; exit 1; fi
    fi
}

function link () {
    if [ -z "${DEBUG_FLAG}" ]; then
        echo "Link       -> ${FILE}.s"
        if [ ${LINK_CODE} -eq 0 ]; then
            gcc ${FILE}.s -o ${FILE}
            if [ ${?} -ne 0 ]; then clean; exit 1; fi
            echo "Executable -> ${FILE}"
        elif [ ${LINK_CODE} -eq 1 ]; then
            gcc -c ${FILE}.s -o ${FILE}.o
            if [ ${?} -ne 0 ]; then clean; exit 1; fi
            echo "Object     -> ${FILE}.o"
        else
            if [ ${?} -ne 0 ]; then clean; exit 1; fi
        fi
    fi
}

usage ${@}

DEBUG_FLAG=""
LINK_CODE=0
FILE=""
parse_args

preprocess
compile
link

clean
exit 0
