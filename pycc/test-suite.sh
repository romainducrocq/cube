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
    test --chapter 1 --latest-only
    test --chapter 2 --latest-only
    test --chapter 3 --latest-only --bitwise
fi
