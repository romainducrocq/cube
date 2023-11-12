#!/bin/bash

exit -1

function usage () {
    echo ${@} |\
       grep -q -e "--help"
    if [ ${?} -eq 0 ]; then
        echo "Usage: ccc [Options] FILE"
        echo ""
        echo "Options:"
        echo "    --help       print help and exit"
        echo "    --lex        print lexing and exit"
        echo "    --parse      print parsing and exit"
        echo "    --validate   print semantic analysis and exit"
        echo "    --tacky      print tac representation and exit"
        echo "    --codegen    print assembly generation and exit"
        echo "    --codeemit   print code emission and exit"
        echo "    -S           print optimization and exit"
        echo ""
        echo "FILE:            .c file to compile"
        exit 0
    fi
}

function file () {
    FILE=$(readlink -f ${@: -1})
    FILE=${FILE%.*}
    echo "${FILE}"
}

function argv () {
    ARGV=${@:1:$#-1}
    echo "${ARGV}"
}

function clean () {
    FILE=${1}

    if [ -f ${FILE}.i ]; then rm ${FILE}.i; fi
    if [ -f ${FILE}.s ]; then rm ${FILE}.s; fi
}

function preprocess () {
    FILE=${1}

    echo "Preprocess -> ${FILE}.c"
    gcc -E -P ${FILE}.c -o ${FILE}.i
    if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi
}

function compile () {
    FILE=${1}
    ARGV=${@:2}

    if [[ ! "${PYTHONPATH}" == *":$HOME/.python:"* ]] ; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.python"
    fi

    echo "Compile    -> ${FILE}.i"
    python3.9 -c "from ccc.compiler import main; main()" ${FILE}.i ${ARGV}
    if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi
}

function link () {
    FILE=${1}
    ARGV=${@:2}

    echo ${ARGV} |\
        grep -q -e "--lex" -e "--parse" -e "--validate" \
                -e "--tacky" -e "--codegen" -e "--codeemit"
    if [ ${?} -ne 0 ]; then
        echo "Link       -> ${FILE}.s"
        gcc ${FILE}.s -o ${FILE}
        if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi
        echo "Executable -> ${FILE}"
    fi
}

usage ${@}

FILE=$(file ${@})
ARGV=$(argv ${@})

preprocess ${FILE}
compile ${FILE} ${ARGV}
link ${FILE} ${ARGV}

clean ${FILE}
exit 0
