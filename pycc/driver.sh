#!/bin/bash

function pack() {
    if [ ! -d "$HOME/.python/" ]; then
        mkdir ~/.python/
    fi

    if [[ ! "${PYTHONPATH}" == *":$HOME/.python:"* ]] ; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.python"
    fi

    if [ ! -L "$HOME/.python/pycc" ] && [ ! -e "$HOME/.python/pycc" ]; then
        ln -s $(pwd) ~/.python/
    fi
}

function clean () {
  if [ -f ${1}.i ]; then rm ${1}.i; fi
  if [ -f ${1}.s ]; then rm ${1}.s; fi
}

FILE=${@: -1}
FILE=${FILE%.*}

gcc -E -P ${FILE}.c -o ${FILE}.i
if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi

pack && python3 compiler.py ${FILE}.i ${@:1:$#-1}
if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi

echo ${@:1:$#-1} | grep -q -e "--lex" -e "--parse" -e "--codegen"
if [ ${?} -ne 0 ]; then
    gcc ${FILE}.s -o ${FILE}
    if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi
fi

clean ${FILE} && exit 0
