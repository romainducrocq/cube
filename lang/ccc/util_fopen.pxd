cdef void file_open_read(str filename)

cdef void file_open_write(str filename)

cdef tuple[bint, str] read_line()

cdef void write_chunk(bytes chunk_fp, size_t chunk_l)

cdef void write_file(str stream, int chunk_size)

cdef void file_close_read()

cdef void file_close_write()
