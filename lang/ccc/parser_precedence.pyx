from ccc.parser_lexer cimport TOKEN_KIND


cdef dict[int, int] TOKEN_PRECEDENCE = {
    TOKEN_KIND.get('binop_multiplication'): 50,
    TOKEN_KIND.get('binop_division'): 50,
    TOKEN_KIND.get('binop_remainder'): 50,
    TOKEN_KIND.get('unop_negation'): 45,
    TOKEN_KIND.get('binop_addition'): 45,
    TOKEN_KIND.get('binop_bitshiftleft'): 40,
    TOKEN_KIND.get('binop_bitshiftright'): 40,
    TOKEN_KIND.get('binop_lessthan'): 35,
    TOKEN_KIND.get('binop_lessthanorequal'): 35,
    TOKEN_KIND.get('binop_greaterthan'): 35,
    TOKEN_KIND.get('binop_greaterthanorequal'): 35,
    TOKEN_KIND.get('binop_equalto'): 30,
    TOKEN_KIND.get('binop_notequal'): 30,
    TOKEN_KIND.get('binop_bitand'): 25,
    TOKEN_KIND.get('binop_bitxor'): 20,
    TOKEN_KIND.get('binop_bitor'): 15,
    TOKEN_KIND.get('binop_and'): 10,
    TOKEN_KIND.get('binop_or'): 5,
    TOKEN_KIND.get('assignment_simple'): 1,
    TOKEN_KIND.get('assignment_plus'): 1,
    TOKEN_KIND.get('assignment_difference'): 1,
    TOKEN_KIND.get('assignment_product'): 1,
    TOKEN_KIND.get('assignment_quotient'): 1,
    TOKEN_KIND.get('assignment_remainder'): 1,
    TOKEN_KIND.get('assignment_bitand'): 1,
    TOKEN_KIND.get('assignment_bitor'): 1,
    TOKEN_KIND.get('assignment_bitxor'): 1,
    TOKEN_KIND.get('assignment_bitshiftleft'): 1,
    TOKEN_KIND.get('assignment_bitshiftright'): 1
}


cdef int parse_token_precedence(int token_kind):

    cdef int precedence
    try:
        precedence = TOKEN_PRECEDENCE[token_kind]
    except KeyError:

        raise RuntimeError(
            f"""An error occurred in precedence management, unmanaged token {
                list(TOKEN_KIND.iter().keys())[list(TOKEN_KIND.iter().values()).index(token_kind)]}""")

    return precedence
