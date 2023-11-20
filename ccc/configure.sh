#!/bin/bash

PACKAGE_NAME="ccc"
PACKAGE_DIR=$(pwd)

sudo apt-get update
apt-get install gcc \
    build-essential \
    libpq-dev \
    libssl-dev \
    openssl \
    libffi-dev \
    sqlite3 \
    libsqlite3-dev \
    libbz2-dev \
    zlib1g-dev \
    cmake

if [ ! -d "$HOME/.${PACKAGE_NAME}/" ]; then
    mkdir ~/.${PACKAGE_NAME}/
fi

if [ ! -d "$HOME/.${PACKAGE_NAME}/Python-3.9/" ]; then
    PATCH=0
    while \
    wget -q --method=HEAD https://www.python.org/ftp/python/3.9.$(( $PATCH + 1 ))/Python-3.9.$(( $PATCH + 1 )).tar.xz
    do
        PATCH=$(( $PATCH + 1 ));
    done

    wget https://www.python.org/ftp/python/3.9.${PATCH}/Python-3.9.${PATCH}.tar.xz
    if [ ${?} -ne 0 ]; then exit 1; fi

    tar -xvf Python-3.9.${PATCH}.tar.xz -C ~/.${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi

    mv ~/.${PACKAGE_NAME}/Python-3.9.${PATCH}/ ~/.${PACKAGE_NAME}/Python-3.9/
    cd ~/.${PACKAGE_NAME}/Python-3.9/

    ./configure --enable-shared
    if [ ${?} -ne 0 ]; then exit 1; fi

    make
    if [ ${?} -ne 0 ]; then exit 1; fi

    which python3.9
    if [ ${?} -ne 0 ]; then
        make altinstall
        if [ ${?} -ne 0 ]; then exit 1; fi
    fi
fi

python3.9 -m pip install Cython==3.0.5
if [ ${?} -ne 0 ]; then exit 1; fi

cd ${PACKAGE_DIR}
echo -n "${PACKAGE_NAME}" > ./package_name.txt
if [ ${?} -ne 0 ]; then exit 1; fi

echo -n "${PACKAGE_NAME}" > ../lang/build/package_name.txt
if [ ${?} -ne 0 ]; then exit 1; fi

exit 0
