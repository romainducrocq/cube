#!/bin/bash

function requirements () {
    python3.9 -m pip install Cython==3.0.5
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function setup () {
    echo -n '' > __init__.py
    echo -n '' > __init__.pyx
    # echo -n '' > __init__.pxd

#    echo -n '' > setup.py
#    echo 'from distutils.core import setup' >> setup.py
#    echo 'from distutils.extension import Extension' >> setup.py
#    echo 'from Cython.Distutils import build_ext' >> setup.py
#    echo '' >> setup.py
#    echo 'ext_modules = [' >> setup.py
#for FILE in $(find . -type f -name "*.pyx" | grep --invert-match -e __init__.py -e setup.py)
#    do
        # PKG=$(echo "ccc$(echo ${FILE}.pyx | rev | cut -d '.' -f2 | rev | tr '/' '.')")
        # echo '    Extension("'"${PKG}"'",  ["'"${FILE}"'.pyx"]),' >> setup.py
#    done
#    echo ']' >> setup.py
#    echo '' >> setup.py
#    echo 'for ext_module in ext_modules:' >> setup.py
#    echo '    ext_module.cython_directives = {"language_level": "3"}' >> setup.py
#    echo '' >> setup.py
#    echo 'setup(' >> setup.py
#    echo '    name="ccc",' >> setup.py
#    echo '    version="0.1",' >> setup.py
#    echo '    license="MIT",' >> setup.py
#    echo '    python_requires="==3.9",' >> setup.py
#    echo '    cmdclass={"build_ext": build_ext},' >> setup.py
#    echo '    ext_modules=ext_modules' >> setup.py
#    echo ')' >> setup.py
}

function compile () {
    if [[ ! "${PYTHONPATH}" == *":$HOME/.python:"* ]]; then
        export PYTHONPATH="$PYTHONPATH:$HOME/.python"
    fi

    python3.9 setup.py build_ext --inplace
    if [ ${?} -ne 0 ]; then exit 1; fi
}

function install () {
    cp ../../ccc/driver.sh ./ccc/
    if [ ${?} -ne 0 ]; then exit 1; fi
    cp ../../ccc/install.sh ./ccc/
    if [ ${?} -ne 0 ]; then exit 1; fi
    rm -r ../../ccc/
    if [ ${?} -ne 0 ]; then exit 1; fi

    cp -r ./ccc/ ../../
}

cd ../ccc/
requirements
setup
compile
install

exit 0
