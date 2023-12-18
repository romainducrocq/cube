from libc.stdint cimport int32_t, int64_t, uint32_t, uint64_t

cdef int32_t str_to_int32(str s_str)
cdef int64_t str_to_int64(str s_str)
cdef uint32_t str_to_uint32(str s_str)
cdef uint64_t str_to_uint64(str s_str)

ctypedef int32_t int32
ctypedef int64_t int64
ctypedef uint32_t uint32
ctypedef uint64_t uint64
