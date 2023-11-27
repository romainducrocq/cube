#!/bin/bash

PACKAGE_NAME="$(cat ../build/package_name.txt)"

function test () {
    echo ""
    echo "----------------------------------------------------------------------"
    echo "${@}"
    ./test_compiler ./driver.sh ${@}
    if [ ${?} -ne 0 ]; then exit 1; fi
}

cd ../../../writing-a-c-compiler-tests/
find . -maxdepth 1 -type l -delete
ln -s ../LANG-CCC/${PACKAGE_NAME}/* .

if [ ${#} -ne 0 ]; then
    test ${@}
else
    test --chapter 1 --latest-only
    test --chapter 2 --latest-only
    test --chapter 3 --latest-only --bitwise
    test --chapter 4 --latest-only --bitwise
    test --chapter 5 --latest-only --extra-credit
    test --chapter 6 --stage parse --latest-only
fi

exit 0
