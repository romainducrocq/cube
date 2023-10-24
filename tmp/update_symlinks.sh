#!/bin/bash

find . -maxdepth 1 -type l -delete

sudo ln -s ../writing-c-compiler/driver.sh ./driver.sh
for i in $(ls ../writing-c-compiler/*.py)
do
    sudo ln -s ${i} $(echo ${i} | rev | cut -d"/" -f1 | rev)
done
