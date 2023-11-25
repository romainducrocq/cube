#!/bin/bash

cd ../lang/build/
./build.sh
if [ ${?} -ne 0 ]; then exit 1; fi
exit 0
