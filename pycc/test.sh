#!/bin/bash

function test () {
    echo ""
    echo "----------------------------------------------------------------------"
    echo "${@}"
    ./test_compiler ./driver.sh ${@}
    if [ ${?} -ne 0 ]; then exit 1; fi
}

cd ../../writing-a-c-compiler-tests/
find . -maxdepth 1 -type l -delete
ln -s ../MOOC-NoStarch-Writing_a_C_Compiler/pycc/* .

if [ ${#} -ne 0 ]; then
    test ${@}
else
    test --chapter 1
    test --chapter 2 --stage lex
    test --chapter 2 --stage parse
    test --chapter 2 --stage tacky
fi
