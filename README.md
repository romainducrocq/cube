# [Lang] Cython C Compiler 

****

- Writing a C Compiler - Build a Real Programming Language from Scratch, Nora Sandler: https://nostarch.com/writing-c-compiler  
    - Test suite: https://github.com/nlsandler/writing-a-c-compiler-tests.git  
    - OCaml reference implementation: https://github.com/nlsandler/nqcc2  

****

## Development

- [x] Int constants  
- [x] Unary operators  
- [x] Binary operators  
- [x] Logical and relational operators  
- [x] Local variables  
- [ ] Cythonize  

## How To _

### Build
```
cd ccc/
./configure.sh
./make.sh
./install.sh
```

### Build for dev
```
cd ccc/
./configure.sh
cd ../lang/dev/
./build.sh
cd ../../ccc/
./install.sh
```

### Test
```
cd lang/dev/
./test.sh ../../tests/
```

### Run
```
ccc path/to/file.c
```

### Help
```
Usage: ccc FILE [Options]

Options:
    --help       print help and exit
    --lex        print lexing and exit
    --parse      print parsing and exit
    --validate   print semantic analysis and exit
    --tacky      print tac representation and exit
    --codegen    print assembly generation and exit
    --codeemit   print code emission and exit
    -S           print optimization and exit

FILE:            .c file to compile
```

****

@romainducrocq
