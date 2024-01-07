from libc.stdint cimport int32_t, int64_t, uint32_t, uint64_t, intmax_t, uintmax_t


from libc.errno cimport ERANGE
cdef extern from "errno.h":
    int errno
cdef extern from "inttypes.h":
    intmax_t strtoimax(const char *, char **, int)
    uintmax_t strtoumax(const char *, char **, int)
cdef extern from "stdlib.h":
    double strtod(const char *, char **)


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


cdef double str_to_double(str str_double):
    cdef bytes b_str_double = str_double.encode("UTF-8")
    cdef char *c_str_double = b_str_double
    cdef char *end_ptr = NULL
    errno = 0
    cdef double val_double = strtod(c_str_double, &end_ptr)
    if end_ptr == c_str_double:

        raise RuntimeError(
            f"String \"{str_double}\" is not a floating point number")

    if (errno == ERANGE) \
       or (errno != 0 and val_double == 0):

        raise RuntimeError(
            f"String \"{str_double}\" is out of range")

    return val_double
