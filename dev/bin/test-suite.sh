#!/bin/bash

function test () {
    echo ""
    echo "----------------------------------------------------------------------"
    echo "${@}"
    ./test_compiler ./driver.sh ${@}
    if [ ${?} -ne 0 ]; then exit 1; fi
}

cd ../../../writing-a-c-compiler-tests/
find . -maxdepth 1 -type l -delete
ln -s ../MOOC-NoStarch-Writing_a_C_Compiler/ccc/* .

if [ ${#} -ne 0 ]; then
    test ${@}
else
    test --chapter 1 --stage tacky --latest-only
    test --chapter 2 --stage tacky --latest-only
    test --chapter 3 --stage tacky --latest-only --bitwise
    test --chapter 4 --stage tacky --latest-only --bitwise
    test --chapter 5 --stage tacky --latest-only --extra-credit
fi

exit 0
