from libc.stdio cimport FILE
cdef extern from "stdio.h":
    FILE *fopen(const char *, const char *)
    int fclose(FILE *)
    ssize_t getline(char **, size_t *, FILE *)
    size_t fwrite(const void *, size_t, size_t, FILE *)


cdef FILE *c_file_in = NULL
cdef FILE *c_file_out = NULL
cdef str stream_buf = ""


cdef void file_open_read(str filename):
    global c_file_in
    c_file_in = NULL

    cdef bytes b_filename = filename.encode("UTF-8")
    cdef char *c_filename = b_filename

    c_file_in = fopen(c_filename, "rb")
    if c_file_in == NULL:

        raise RuntimeError(
            f"File {filename} does not exist")


cdef void file_open_write(str filename):
    global c_file_out
    global stream_buf
    c_file_out = NULL
    stream_buf = ""

    cdef bytes b_filename = filename.encode("UTF-8")
    cdef char *c_filename = b_filename

    c_file_out = fopen(c_filename, "wb")
    if c_file_out == NULL:

        raise RuntimeError(
            f"File {filename} does not exist")


cdef tuple[bint, str] read_line():

    cdef size_t l = 0
    cdef char *c_line = NULL
    cdef ssize_t read = getline(&c_line, &l, c_file_in)

    if read == -1:
        return True, ''

    return False, str(c_line.decode("UTF-8"))


cdef void write_chunk(bytes chunk_fp, size_t chunk_l):

    cdef char *c_chunk_fp = chunk_fp
    fwrite(c_chunk_fp, sizeof(char), chunk_l, c_file_out)


cdef void write_file(str stream, Py_ssize_t chunk_size = 4096):
    global stream_buf

    stream_buf += stream
    while len(stream_buf) >= chunk_size:
        write_chunk(stream_buf[:chunk_size].encode("UTF-8"),
                    chunk_size)

        stream_buf = stream_buf[chunk_size:]


cdef void write_line(str line):
    write_file(line + "\n")


cdef void file_close_read():

    fclose(c_file_in)


cdef void file_close_write():

    write_chunk(stream_buf.encode("UTF-8"), len(stream_buf))
    fclose(c_file_out)
