from libc.stdio cimport *
cdef extern from "stdio.h":
    FILE *fopen(const char *, const char *)
    int fclose(FILE *)
    ssize_t getline(char **, size_t *, FILE *)


cdef FILE *cfile = NULL


cdef void file_open(str filename):
    global cfile
    cfile = NULL

    cdef bytes b_filename = filename.encode("UTF-8")
    cdef char *c_filename = b_filename

    cfile = fopen(c_filename, "rb")
    if cfile == NULL:

        raise RuntimeError(
            f"File {filename} does not exist")


cdef tuple[bint, str] get_line():

    cdef size_t l = 0
    cdef char *cline = NULL
    cdef ssize_t read = getline(&cline, &l, cfile)

    if read == -1:
        return True, ''

    return False, str(cline.decode("UTF-8"))


cdef void file_close():

    fclose(cfile)

