from libc.stdint cimport int32_t, int64_t, uint32_t, uint64_t, intmax_t, uintmax_t


from libc.errno cimport ERANGE
cdef extern from "errno.h":
    int errno
cdef extern from "inttypes.h":
    intmax_t strtoimax(const char *, char **, int)
    uintmax_t strtoumax(const char *, char**, int)


cdef intmax_t str_to_int(str s_str):
    cdef bytes b_str = s_str.encode("UTF-8")
    cdef char *c_str = b_str
    cdef char *end_ptr = NULL
    errno = 0
    cdef intmax_t val = strtoimax(c_str, &end_ptr, 10)
    if end_ptr == c_str:

        raise RuntimeError(
            f"String \"{s_str}\" is not an integer")

    if (errno == ERANGE) \
       or (errno != 0 and val == 0):

        raise RuntimeError(
            f"String \"{s_str}\" is out of range")

    return val


cdef uintmax_t str_to_uint(str s_str):
    cdef bytes b_str = s_str.encode("UTF-8")
    cdef char *c_str = b_str
    cdef char *end_ptr = NULL
    errno = 0
    cdef uintmax_t val = strtoumax(c_str, &end_ptr, 10)
    if end_ptr == c_str:

        raise RuntimeError(
            f"String \"{s_str}\" is not an integer")

    if (errno == ERANGE) \
       or (errno != 0 and val == 0):

        raise RuntimeError(
            f"String \"{s_str}\" is out of range")

    return val


cdef int32_t str_to_int32(str s_str):
    return <int32_t>str_to_int(s_str)


cdef int64_t str_to_int64(str s_str):
    return <int64_t>str_to_int(s_str)


cdef uint32_t str_to_uint32(str s_str):
    return <uint32_t>str_to_uint(s_str)


cdef uint64_t str_to_uint64(str s_str):
    return <uint64_t>str_to_uint(s_str)
