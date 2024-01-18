# [Lang] Cython C Compiler 

****

- Writing a C Compiler - Build a Real Programming Language from Scratch, Nora Sandler: https://nostarch.com/writing-c-compiler  
    - Test suite: https://github.com/nlsandler/writing-a-c-compiler-tests.git  
    - OCaml reference implementation: https://github.com/nlsandler/nqcc2  

****

## Development

### Language features

- [x] Integer constants  
- [x] Unary operators  
- [x] Binary operators  
- [x] Logical and relational operators  
- [x] Local variables  
- [x] Statements and conditional expressions  
- [x] Compound statements  
- [x] Loops  
- [x] Functions  
- [x] File-scope variables and storage-class specifiers  

### Types

- [x] Long integers  
- [x] Unsigned integers  
- [x] Floating-point numbers  
- [ ] Pointers  
- [ ] Arrays and pointer arithmetic  
- [ ] Characters and strings  
- [ ] Supporting dynamic memory allocation  
- [ ] Structures  

### Optimization

- [ ] Optimizing TAC programs  
- [ ] Register allocation  

## How To _

### Build
```
cd ccc/
./configure.sh
./make.sh
./install.sh
. ~/.bashrc
```

### Build for dev
```
cd ccc/
./configure.sh
cd ../lang/dev/
./build.sh
cd ../../ccc/
./install.sh
. ~/.bashrc
```

### Test
```
cd lang/dev/
./test.sh [Test suite]
```

### Run
```
ccc path/to/file.c
```

### Help
```
Usage: ccc [Help] [Link] FILE

[Help]:
    --help       print help and exit
    -v           enable verbose mode

[Link]:
    -c           compile, but do not link

FILE:            .c file to compile
```

### Help for dev
```
Usage: ccc [Help] [Debug] [Link] FILE

[Help]:
    --help       print help and exit

[Debug]:
    --lex        print lexing and exit
    --parse      print parsing and exit
    --validate   print semantic analysis and exit
    --tacky      print tac representation and exit
    --codegen    print assembly generation and exit
    --codeemit   print code emission and exit

[Link]:
    -c           compile, but do not link

FILE:            .c file to compile
```

****

## Code format restrictions

*The source code is preprocessed and cythonized before being compiled. <ins>It must strictly follow these formatting rules</ins>:*
- All `.{pyx,pxd}` files must be in `lang/ccc/` package, submodules are not supported.
- All `.{pyx,pxd}` files must be in `unix` file format, `dos` file format is not supported.
- All `.pyx` source files must be added to `lang/ccc/setup.py`.
- Every `.pyx` source file must have a `pxd` declaration file with same name, even if empty.
- All `.{pyx,pxd}` files must be named with format `<package_name>_<file_name>.{pyx,pxd}`.
- Only `.pyx` source files can be added to project, `.py` source files are not supported.
- All local imports must have format `from <package_name>.<file_name> cimport <a_class>, <a_func>`.
- All comments must be hashtags comments `#`, triple quotes `"""` comments are not supported.
- All comments must be on a separate line, inlined comments are not supported.
- There must be no special character `#` in hardcoded strings, matching lines are stripped.
- There must be no global scope symbols (variables, functions and classes) in hardcoded strings.
- There must be no double whitespaces in code lines, except from python indentation and format.
- All global variables must be declared with `cdef` (`cdef object` must be used for python objects).
- All classes declared in a `.pxd` declaration file must be declared with `cdef class`.
- All functions declared in a `.pxd` declaration file must be declared with `cdef` or `cpdef`.
- All global typedefs must be declared at the end of a `.pxd` declaration file with `ctypedef`.
- Standard exceptions must be used (`RuntimeError`, ...), custom exceptions are not supported.
- Python entry point `main.py` in `lang/ccc/<file_main>.{pyx,pxd}` must be declared with `cpdef`.
- Python entry point `main.py` must be at the end of file, everything from here on is ignored. 
- C entry point `main_c` in `lang/ccc/<file_main>.pyx` must be the only public symbol.
- Avoid python `import` as much as possible, it makes the generated code bulky and slower.

****

@romainducrocq
