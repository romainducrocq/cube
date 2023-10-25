#!/bin/bash

cd ../../writing-a-c-compiler-tests/
find . -maxdepth 1 -type l -delete
ln -s ../MOOC-NoStarch-Writing_a_C_Compiler/pycc/* .

./test_compiler ./driver.sh ${@}
