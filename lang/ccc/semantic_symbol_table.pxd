from ccc.abc_builtin_ast cimport AST, TInt, TLong, TUInt, TULong, TDouble


cdef class Type(AST):
    pass


cdef class Int(Type):
    pass


cdef class Long(Type):
    pass


cdef class UInt(Type):
    pass


cdef class ULong(Type):
    pass


cdef class Double(Type):
    pass


cdef class FunType(Type):
    cdef public list[Type] param_types
    cdef public Type ret_type


cdef class StaticInit(AST):
    pass


cdef class IntInit(StaticInit):
    cdef public TInt value


cdef class LongInit(StaticInit):
    cdef public TLong value


cdef class UIntInit(StaticInit):
    cdef public TUInt value


cdef class ULongInit(StaticInit):
    cdef public TULong value


cdef class InitialValue(AST):
    pass


cdef class Tentative(InitialValue):
    pass


cdef class Initial(InitialValue):
    cdef public StaticInit static_init


cdef class NoInitializer(InitialValue):
    pass


cdef class IdentifierAttr(AST):
    pass


cdef class FunAttr(IdentifierAttr):
    cdef public bint is_defined
    cdef public bint is_global


cdef class StaticAttr(IdentifierAttr):
    cdef public InitialValue init
    cdef public bint is_global


cdef class LocalAttr(IdentifierAttr):
    pass


cdef class Symbol(AST):
    cdef public Type type_t
    cdef public IdentifierAttr attrs


cdef dict[str, Symbol] symbol_table
