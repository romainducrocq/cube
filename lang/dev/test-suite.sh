#!/bin/bash

PACKAGE_DIR="$(dirname $(readlink -f ../))"
PACKAGE_NAME="$(cat ../build/package_name.txt)"

function test () {
    echo ""
    echo "----------------------------------------------------------------------"
    echo "${@}"
    ./test_compiler ./driver.sh ${@}
    # if [ ${?} -ne 0 ]; then exit 1; fi
}

cd ../../../writing-a-c-compiler-tests/
find . -maxdepth 1 -type l -delete
ln -s ${PACKAGE_DIR}/${PACKAGE_NAME}/* .

if [ ${#} -ne 0 ]; then
    test ${@}
else
    for i in $(seq 1 13); do
        test --chapter ${i} --latest-only --bitwise --compound --goto --nan
    done
fi

exit 0
