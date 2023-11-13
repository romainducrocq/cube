cdef class IotaEnum:

    def __init__(self, tuple[unicode] names):
        cdef unicode name

        self.iota_counter = 0
        self.iota_enum = {}
        for name in names:
            self.iota_enum[name] = self.iota_counter
            self.iota_counter += 1

    cpdef int get(self, unicode key):
        return self.iota_enum[key]
