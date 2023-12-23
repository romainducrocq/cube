from libc.stdint cimport int32_t, int64_t, uint32_t, uint64_t, intmax_t, uintmax_t


from libc.errno cimport ERANGE
cdef extern from "errno.h":
    int errno
cdef extern from "inttypes.h":
    intmax_t strtoimax(const char *, char **, int)
    uintmax_t strtoumax(const char *, char**, int)


cdef intmax_t str_to_int(str str_int):
    cdef bytes b_str_int = str_int.encode("UTF-8")
    cdef char *c_str_int = b_str_int
    cdef char *end_ptr = NULL
    errno = 0
    cdef intmax_t val_int = strtoimax(c_str_int, &end_ptr, 10)
    if end_ptr == c_str_int:

        raise RuntimeError(
            f"String \"{str_int}\" is not an integer")

    if (errno == ERANGE) \
       or (errno != 0 and val_int == 0):

        raise RuntimeError(
            f"String \"{str_int}\" is out of range")

    return val_int


cdef uintmax_t str_to_uint(str str_uint):
    cdef bytes b_str_uint = str_uint.encode("UTF-8")
    cdef char *c_str_uint = b_str_uint
    cdef char *end_ptr = NULL
    errno = 0
    cdef uintmax_t val_uint = strtoumax(c_str_uint, &end_ptr, 10)
    if end_ptr == c_str_uint:

        raise RuntimeError(
            f"String \"{str_uint}\" is not an integer")

    if (errno == ERANGE) \
       or (errno != 0 and val_uint == 0):

        raise RuntimeError(
            f"String \"{str_uint}\" is out of range")

    return val_uint


cdef int32_t str_to_int32(str str_int32):
    return <int32_t>str_to_int(str_int32)


cdef int64_t str_to_int64(str str_int64):
    return <int64_t>str_to_int(str_int64)


cdef uint32_t str_to_uint32(str str_uint32):
    return <uint32_t>str_to_uint(str_uint32)


cdef uint64_t str_to_uint64(str str_uint64):
    return <uint64_t>str_to_uint(str_uint64)


cdef int64_t MAX_INT32 = 2147483647
cdef int64_t POW_2_32 = 4294967296


cdef bint is_int32_overflow(int64_t val_int64):
    return val_int64 > MAX_INT32


cdef int32_t int64_to_int32(int64_t val_int64):
    if is_int32_overflow(val_int64):
        val_int64 -= POW_2_32
    return <int32_t>val_int64


cdef int64_t int32_to_int64(int32_t val_int32):
    return <int64_t>val_int32
