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
"10_file-scope_variables_and_storage-class_specifiers"
"11_long_integers"
"12_unsigned_integers"
"13_floating-point_numbers"
)

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

function print_check () {
    echo " - check ${1} -> ${2}"
}

function indent () {
    echo -n "$(echo "${TOTAL} [ ] ${FILE}.c" | sed -r 's/./ /g')"
}

function print_fail () {
    echo -e -n "${TOTAL} ${RES} ${FILE}.c${NC}"
    PRINT="${PACKAGE_NAME}: ${RET_CCC}"
    print_check "fail" "[${PRINT}]"
}

function print_single () {
    echo -e -n "${TOTAL} ${RES} ${FILE}.c${NC}"
    if [ ${RET_PASS} -ne 0 ]; then
        PRINT="${COMP_2}: ${RET_CCC}"
        print_check "return" "[${PRINT}]"
    else
        PRINT="${COMP_1}: ${RET_GCC}, ${COMP_2}: ${RET_CCC}"
        print_check "return" "[${PRINT}]"
        if [ ! -z "${OUT_CCC}" ]; then
            indent
            PRINT="${COMP_1}: \"${OUT_GCC}\", ${COMP_2}: \"${OUT_CCC}\""
            print_check "stdout" "[${PRINT}]"
        fi
    fi
}

print_client () {
    echo -e -n "${TOTAL} ${RES} ${FILE}.c${NC}"
    if [ ${RET_PASS} -ne 0 ]; then
        PRINT="${COMP_4}: ${RET_CCC}"
        print_check "return" "[${PRINT}]"
    else
        PRINT="${COMP_1}: ${RET_GCC}, ${COMP_2}: ${RET_GCC_CCC}, "
        PRINT="${PRINT}${COMP_3}: ${RET_CCC_GCC}, ${COMP_4}: ${RET_CCC}"
        print_check "return" "[${PRINT}]"
        if [ ! -z "${OUT_CCC}" ]; then
            indent
            PRINT="${COMP_1}: \"${OUT_GCC}\", ${COMP_2}: \"${OUT_GCC_CCC}\", "
            PRINT="${PRINT}${COMP_3}: \"${OUT_CCC_GCC}\", ${COMP_4}: \"${OUT_CCC}\""
            print_check "stdout" "[${PRINT}]"
        fi
    fi
}

function check_fail () {
    ${PACKAGE_NAME} ${FILE}.c > /dev/null 2>&1
    RET_CCC=${?}

    if [ ${RET_CCC} -ne 0 ]; then
        RES="${LIGHT_GREEN}[y]"
        if [ ${1} -eq 0 ]; then
            let PASS+=1
        fi
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
            if [ ${1} -eq 0 ]; then
                let PASS+=1
            fi
        fi
    else
        RES="${LIGHT_RED}[n]"
    fi

    return 0
}

function check_single () {
    gcc -pedantic-errors ${FILE}.c -o ${FILE} > /dev/null 2>&1
    RET_GCC=${?}

    if [ ${RET_GCC} -ne 0 ]; then
        check_fail 0
        return
    fi

    OUT_GCC=$(${FILE})
    RET_GCC=${?}
    rm ${FILE}

    ${PACKAGE_NAME} ${FILE}.c > /dev/null 2>&1
    RET_CCC=${?}

    check_pass 0
    RET_PASS=${?}

    COMP_1="gcc"
    COMP_2="${PACKAGE_NAME}"
    print_single
}

function compile_client () {
    ${PACKAGE_NAME} -c ${1} > /dev/null 2>&1
    RET_CCC=${?}

    if [ ${RET_CCC} -eq 0 ]; then
        gcc -pedantic-errors ${FILE}.o ${FILE}_client.o -o ${FILE} > /dev/null 2>&1
        RET_CCC=${?}
    fi

    if [ -f "${FILE}.o" ]; then rm ${FILE}.o; fi
    if [ -f "${FILE}_client.o" ]; then rm ${FILE}_client.o; fi
}

function check_client () {
    gcc -pedantic-errors ${FILE}.c ${FILE}_client.c -o ${FILE} > /dev/null 2>&1
    OUT_GCC=$(${FILE})
    RET_GCC=${?}
    rm ${FILE}

    if [ -f "${FILE}.o" ]; then rm ${FILE}.o; fi
    if [ -f "${FILE}_client.o" ]; then rm ${FILE}_client.o; fi

    gcc -pedantic-errors -c ${FILE}_client.c -o ${FILE}_client.o > /dev/null 2>&1
    compile_client ${FILE}.c
    check_pass 1
    RET_PASS=${?}
    RET_GCC_CCC=${RET_CCC}
    OUT_GCC_CCC=${OUT_CCC}
    if [ ${RET_PASS} -ne 0 ]; then
        COMP_4="gcc+${PACKAGE_NAME}"
        print_client
        return
    fi

    gcc -pedantic-errors -c ${FILE}.c  -o ${FILE}.o > /dev/null 2>&1
    compile_client ${FILE}_client.c
    check_pass 1
    RET_PASS=${?}
    RET_CCC_GCC=${RET_CCC}
    OUT_CCC_GCC=${OUT_CCC}
    if [ ${RET_PASS} -ne 0 ]; then
        COMP_4="${PACKAGE_NAME}+gcc"
        print_client
        return
    fi

    ${PACKAGE_NAME} -c ${FILE}.c > /dev/null 2>&1
    compile_client ${FILE}_client.c
    check_pass 0
    RET_PASS=${?}

    COMP_1="gcc"
    COMP_2="gcc+${PACKAGE_NAME}"
    COMP_3="${PACKAGE_NAME}+gcc"
    COMP_4="${PACKAGE_NAME}"
    print_client
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

function test_dir () {
    DIR=${1}
    for FILE in $(find ${DIR} -name "*.c" -type f | sort --uniq)
    do
        check_test ${FILE}
    done
}

function test_all () {
    for DIR in ${TEST_DIRS[@]}
    do
        test_dir ${DIR}
    done
}

PASS=0
TOTAL=0
cd ${TEST_DIR}
if [ ! -z "${1}" ]; then
    test_dir ${TEST_DIRS["$((${1} - 1))"]}
else
    test_all
fi
total
