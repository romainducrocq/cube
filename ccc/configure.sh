#!/bin/bash

PACKAGE_NAME="ccc"
PYTHON_VERSION="3.9"
CYTHON_VERSION="3.0.5"

PACKAGE_DIR=$(pwd)

sudo apt-get update
sudo apt-get install gcc \
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

if [ ! -d "$HOME/.${PACKAGE_NAME}/Python-${PYTHON_VERSION}/" ]; then
    PATCH=13

    wget --no-check-certificate https://www.python.org/ftp/python/${PYTHON_VERSION}.${PATCH}/Python-${PYTHON_VERSION}.${PATCH}.tar.xz
    if [ ${?} -ne 0 ]; then exit 1; fi

    tar -xvf Python-${PYTHON_VERSION}.${PATCH}.tar.xz -C ~/.${PACKAGE_NAME}/
    if [ ${?} -ne 0 ]; then exit 1; fi

    rm Python-${PYTHON_VERSION}.${PATCH}.tar.xz
    if [ ${?} -ne 0 ]; then exit 1; fi

    mv ~/.${PACKAGE_NAME}/Python-${PYTHON_VERSION}.${PATCH}/ ~/.${PACKAGE_NAME}/Python-${PYTHON_VERSION}/
    cd ~/.${PACKAGE_NAME}/Python-${PYTHON_VERSION}/

    ./configure --enable-shared
    if [ ${?} -ne 0 ]; then exit 1; fi

    make
    if [ ${?} -ne 0 ]; then exit 1; fi
fi

which python${PYTHON_VERSION}
if [ ${?} -ne 0 ]; then
    cd ~/.${PACKAGE_NAME}/Python-${PYTHON_VERSION}/

    sudo make altinstall
    if [ ${?} -ne 0 ]; then exit 1; fi
fi

sudo python${PYTHON_VERSION} -m pip install Cython==${CYTHON_VERSION} \
    --trusted-host pypi.org --trusted-host pypi.python.org --trusted-host files.pythonhosted.org
if [ ${?} -ne 0 ]; then exit 1; fi

cd ${PACKAGE_DIR}

echo -n "${PACKAGE_NAME}" > ./package_name.txt
if [ ${?} -ne 0 ]; then exit 1; fi
echo -n "${PYTHON_VERSION}" > ./python_version.txt
if [ ${?} -ne 0 ]; then exit 1; fi

echo -n "${PACKAGE_NAME}" > ../lang/build/package_name.txt
if [ ${?} -ne 0 ]; then exit 1; fi
echo -n "${PYTHON_VERSION}" > ../lang/build/python_version.txt
if [ ${?} -ne 0 ]; then exit 1; fi

exit 0
