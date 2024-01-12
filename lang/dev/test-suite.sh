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
#    for i in $(seq 1 12); do
#        test --chapter ${i} --stage codegen --latest-only --bitwise --compound --goto
#    done
    test --chapter 13 --stage codegen --latest-only --bitwise --compound --goto
fi

exit 0
