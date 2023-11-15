1. build python from sources
- ./configure --enable-shared
- make

2. copy every files in ccc/ccc.pyx
   (c module exec cannot handle cimport)
- make every global variable unique
a. merge pxd declarations into pyx definitions
b. find every cdef class, function, glob variable    
c. make unique by appending file name
- resolve include tree from cimports
- remove cimport lines
- append every processed file to ccc/ccc.pyx

3. ./build.sh && ./run.sh

Option 
1. change path to python3.9.so in build.sh && run.sh
2. preprocess input args in main.c
3. alternative -> see cython --embed
