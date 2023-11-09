#!/bin/bash

function clean () {
    for FILE in $(find . -type f -name "*.c"); do rm ${FILE}; done
    for FILE in $(find . -type f -name "*.pyx"); do rm ${FILE}; done
    if [ -f "./setup.py" ]; then rm ./setup.py; fi
    if [ -d "./build/" ]; then rm -r ./build/; fi
    if [[ "${1}" == "-y" ]]; then
        if [ -d "./cycc/" ]; then rm -r ./cycc/; fi
    fi
}

function setup () {
    echo -n '' > setup.py
    echo 'from distutils.core import setup' >> setup.py
    echo 'from distutils.extension import Extension' >> setup.py
    echo 'from Cython.Distutils import build_ext' >> setup.py
    echo '' >> setup.py
    echo 'ext_modules = [' >> setup.py
    for FILE in $(find . -iname "*.py" | grep --invert-match -e __init__.py -e setup.py)
    do
        sed -e 's/pycc/cycc/g' ${FILE} > ${FILE}'x'
        PKG=$(echo "cycc$(echo ${FILE}'x' | rev | cut -d '.' -f2 | rev | tr '/' '.')")
        echo '    Extension("'"${PKG}"'",  ["'"${FILE}"'x"]),' >> setup.py
    done
    echo ']' >> setup.py
    echo '' >> setup.py
    echo 'for ext_module in ext_modules:' >> setup.py
    echo '    ext_module.cython_directives = {"language_level": "3"}' >> setup.py
    echo '' >> setup.py
    echo 'setup(' >> setup.py
    echo '    name="cycc",' >> setup.py
    echo '    version="0.1",' >> setup.py
    echo '    license="MIT",' >> setup.py
    echo '    python_requires="==3.9",' >> setup.py
    echo '    cmdclass={"build_ext": build_ext},' >> setup.py
    echo '    ext_modules=ext_modules' >> setup.py
    echo ')' >> setup.py
}

function compile () {
    if [[ ! "${PYTHONPATH}" == *":$HOME/.python:"* ]]; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.python"
    fi

    python3.9 setup.py build_ext --inplace 2> /dev/null
    if [ ${?} -ne 0 ]; then clean -y && exit 1; fi
}

clean -y
setup
compile
clean && exit 0
