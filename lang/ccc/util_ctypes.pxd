from libc.stdint cimport int32_t, int64_t, uint32_t, uint64_t

cdef int32_t str_to_int32(str str_int32)
cdef int64_t str_to_int64(str str_int64)
cdef uint32_t str_to_uint32(str str_uint32)
cdef uint64_t str_to_uint64(str str_uint64)
cdef int32_t int64_to_int32(int64_t val_int64)
cdef int64_t int32_to_int64(int32_t val_int32)

ctypedef int32_t int32
ctypedef int64_t int64
ctypedef uint32_t uint32
ctypedef uint64_t uint64
