# append everything here

cdef another_func():
    print("another func")


cdef public main_func(int argc, char **argv):
    cdef int i
    cdef str arg
    for i in range(argc):
        arg = str(argv[i].decode("UTF-8"))
        print(arg)

    print("main func")
    another_func()
