#!/bin/bash

PACKAGE_NAME="$(cat ../build/package_name.txt)"

LIGHT_RED='\033[1;31m'
LIGHT_GREEN='\033[1;32m'
NC='\033[0m'

TEST_DIR="../../tests/"

TEST_DIRS=(
"1_int_constants"
"2_unary_operators"
"3_binary_operators"
"4_logical_and_relational_operators"
"5_local_variables"
"6_statements_and_conditional_expressions"
"7_compound_statements"
"8_loops"
"9_functions"
)

function print_check () {
    echo " - check ${1} -> ${2}"
}

function indent () {
    echo -n "$(echo "${TOTAL} [ ] ${FILE}.c" | sed -r 's/./ /g')"
}

function file () {
    FILE=${1%.*}
    if [ -f "${FILE}" ]; then rm ${FILE}; fi
    echo "${FILE}"
}

function total () {
    echo "----------------------------------------------------------------------"
    RES="${PASS} / ${TOTAL}"
    if [ ${PASS} -eq ${TOTAL} ]; then
        RES="${LIGHT_GREEN}PASS: ${RES}${NC}"
    else
        RES="${LIGHT_RED}FAIL: ${RES}${NC}"
    fi
    echo -e "${RES}"
}

function print_fail () {
    echo -e -n "${TOTAL} ${RES} ${FILE}.c${NC}"
    print_check "fail" "[${PACKAGE_NAME}: ${RET_CCC}]"
}

function check_fail () {
    ${PACKAGE_NAME} ${FILE}.c > /dev/null 2>&1
    RET_CCC=${?}

    if [ ${RET_CCC} -ne 0 ]; then
        RES="${LIGHT_GREEN}[y]"
        let PASS+=1
    else
        RES="${LIGHT_RED}[n]"
    fi

    print_fail
}

function check_pass () {
    if [ ${RET_CCC} -ne 0 ]; then
        RES="${LIGHT_RED}[n]"
        return 1
    fi

    OUT_CCC=$(${FILE})
    RET_CCC=${?}
    rm ${FILE}

    if [ ${RET_GCC} -eq ${RET_CCC} ]; then
        if [[ "${OUT_GCC}" == "${OUT_CCC}" ]]; then
            RES="${LIGHT_GREEN}[y]"
            let PASS+=1
        fi
    else
        RES="${LIGHT_RED}[n]"
    fi

    return 0
}

print_single () {
    echo -e -n "${TOTAL} ${RES} ${FILE}.c${NC}"
    if [ ${RET_PASS} -ne 0 ]; then
        print_check "return" "[${COMP_2}: ${RET_CCC}]"
    else
        print_check "return" "[${COMP_1}: ${RET_GCC}, ${COMP_2}: ${RET_CCC}]"
        if [ ! -z "${OUT_CCC}" ]; then
            indent
            print_check "stdout" "[${COMP_1}: \"${OUT_GCC}\", ${COMP_2}: \"${OUT_CCC}\"]"
        fi
    fi
}

function check_single () {
    gcc -pedantic -Werror ${FILE}.c -o ${FILE} > /dev/null 2>&1
    RET_GCC=${?}

    if [ ${RET_GCC} -ne 0 ]; then
        check_fail
        return
    fi

    OUT_GCC=$(${FILE})
    RET_GCC=${?}
    rm ${FILE}

    ${PACKAGE_NAME} ${FILE}.c > /dev/null 2>&1
    RET_CCC=${?}

    check_pass
    RET_PASS=${?}

    COMP_1="gcc"
    COMP_2="${PACKAGE_NAME}"
    print_single
}

function check_client () {
    echo -e -n "${TOTAL} ${FILE}.c${NC}"
    echo " -> CLIENT"
}

function check_test () {
    FILE=$(file ${1})
    if [[ "${FILE}" == *"_client" ]]; then
      return
    fi

    let TOTAL+=1

    if [ -f "${FILE}_client.c" ]; then
      check_client
      return
    fi

    check_single
}

function tests () {
    for DIR in ${TEST_DIRS[@]}
    do
        for FILE in $(find ${DIR} -name "*.c" -type f | sort --uniq)
        do
            check_test ${FILE}
        done
    done
}

PASS=0
TOTAL=0
cd ${TEST_DIR}
tests
total
