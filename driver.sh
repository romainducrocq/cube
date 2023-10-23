#!/bin/bash

function clean () {
  if [ -f ${1}.i ]; then rm ${1}.i; fi
  if [ -f ${1}.s ]; then rm ${1}.s; fi
}

FILE=${@: -1}
FILE=${FILE%.*}

gcc -E -P ${FILE}.c -o ${FILE}.i
if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi

python3 compiler.py ${FILE}.i ${@:1:$#-1}
if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi

#gcc ${FILE}.s -o ${FILE}
#if [ ${?} -ne 0 ]; then clean ${FILE} && exit 1; fi

clean ${FILE} && exit 0
