from ccc.parser_c_ast cimport *
from ccc.parser_lexer cimport TOKEN_KIND, Token
from ccc.parser_precedence cimport parse_token_precedence


cdef list[Token] tokens = []
cdef Token next_token = Token('', TOKEN_KIND.get('error'))
cdef Token peek_token = Token('', TOKEN_KIND.get('error'))


cdef void expect_next_is(Token _next_token, int expected_token):
    if _next_token.token_kind != expected_token:
        raise RuntimeError(
            f"""Expected token {
                list(TOKEN_KIND.iter().keys())[
                       list(TOKEN_KIND.iter().values()).index(expected_token)
            ]} but found \"{_next_token.token}\"""")


cdef void expect_next_in(Token _next_token, tuple[int, ...] expected_tokens):
    if _next_token.token_kind not in expected_tokens:
        raise RuntimeError(
            f"""Expected token in kinds { tuple([
                list(TOKEN_KIND.iter().keys())[
                       list(TOKEN_KIND.iter().values()).index(expected_token)
                ] for expected_token in expected_tokens])
            } but found \"{_next_token.token}\"""")


cdef Token pop_next():
    global next_token

    try:
        next_token = tokens.pop(0)
        return next_token
    except IndexError:
        raise StopIteration


cdef Token peek_next():
    global peek_token

    try:
        peek_token = tokens[0]
        return peek_token
    except IndexError:
        raise StopIteration


cdef TIdentifier parse_identifier():
    # <identifier> ::= ? An identifier token ?
    expect_next_is(pop_next(), TOKEN_KIND.get('identifier'))
    return TIdentifier(next_token.token)


cdef TInt parse_int():
    # <int> ::= ? A constant token ?
    expect_next_is(pop_next(), TOKEN_KIND.get('constant'))
    return TInt(int(next_token.token))


cdef CBinaryOp parse_binary_op():
    # <binop> ::= "-" | "+" | "*" | "/" | "%" | "&" | "|" | "^" | "<<" | ">>" | "&&" | "||" | "==" | "!="
    #                 | "<" | "<=" | ">" | ">="
    expect_next_in(pop_next(), (TOKEN_KIND.get('unop_negation'),
                   TOKEN_KIND.get('binop_addition'),
                   TOKEN_KIND.get('binop_multiplication'),
                   TOKEN_KIND.get('binop_division'),
                   TOKEN_KIND.get('binop_remainder'),
                   TOKEN_KIND.get('binop_bitand'),
                   TOKEN_KIND.get('binop_bitor'),
                   TOKEN_KIND.get('binop_bitxor'),
                   TOKEN_KIND.get('binop_bitshiftleft'),
                   TOKEN_KIND.get('binop_bitshiftright'),
                   TOKEN_KIND.get('binop_lessthan'),
                   TOKEN_KIND.get('binop_lessthanorequal'),
                   TOKEN_KIND.get('binop_greaterthan'),
                   TOKEN_KIND.get('binop_greaterthanorequal'),
                   TOKEN_KIND.get('binop_equalto'),
                   TOKEN_KIND.get('binop_notequal'),
                   TOKEN_KIND.get('binop_and'),
                   TOKEN_KIND.get('binop_or'),
                   TOKEN_KIND.get('assignment_plus'),
                   TOKEN_KIND.get('assignment_difference'),
                   TOKEN_KIND.get('assignment_product'),
                   TOKEN_KIND.get('assignment_quotient'),
                   TOKEN_KIND.get('assignment_remainder'),
                   TOKEN_KIND.get('assignment_bitand'),
                   TOKEN_KIND.get('assignment_bitor'),
                   TOKEN_KIND.get('assignment_bitxor'),
                   TOKEN_KIND.get('assignment_bitshiftleft'),
                   TOKEN_KIND.get('assignment_bitshiftright')))
    if next_token.token_kind in (TOKEN_KIND.get('unop_negation'),
                                 TOKEN_KIND.get('assignment_difference')):
        return CSubtract()
    if next_token.token_kind in (TOKEN_KIND.get('binop_addition'),
                                 TOKEN_KIND.get('assignment_plus')):
        return CAdd()
    if next_token.token_kind in (TOKEN_KIND.get('binop_multiplication'),
                                 TOKEN_KIND.get('assignment_product')):
        return CMultiply()
    if next_token.token_kind in (TOKEN_KIND.get('binop_division'),
                                 TOKEN_KIND.get('assignment_quotient')):
        return CDivide()
    if next_token.token_kind in (TOKEN_KIND.get('binop_remainder'),
                                 TOKEN_KIND.get('assignment_remainder')):
        return CRemainder()
    if next_token.token_kind in (TOKEN_KIND.get('binop_bitand'),
                                 TOKEN_KIND.get('assignment_bitand')):
        return CBitAnd()
    if next_token.token_kind in (TOKEN_KIND.get('binop_bitor'),
                                 TOKEN_KIND.get('assignment_bitor')):
        return CBitOr()
    if next_token.token_kind in (TOKEN_KIND.get('binop_bitxor'),
                                 TOKEN_KIND.get('assignment_bitxor')):
        return CBitXor()
    if next_token.token_kind in (TOKEN_KIND.get('binop_bitshiftleft'),
                                 TOKEN_KIND.get('assignment_bitshiftleft')):
        return CBitShiftLeft()
    if next_token.token_kind in (TOKEN_KIND.get('binop_bitshiftright'),
                                 TOKEN_KIND.get('assignment_bitshiftright')):
        return CBitShiftRight()
    if next_token.token_kind == TOKEN_KIND.get('binop_and'):
        return CAnd()
    if next_token.token_kind == TOKEN_KIND.get('binop_or'):
        return COr()
    if next_token.token_kind == TOKEN_KIND.get('binop_equalto'):
        return CEqual()
    if next_token.token_kind == TOKEN_KIND.get('binop_notequal'):
        return CNotEqual()
    if next_token.token_kind == TOKEN_KIND.get('binop_lessthan'):
        return CLessThan()
    if next_token.token_kind == TOKEN_KIND.get('binop_lessthanorequal'):
        return CLessOrEqual()
    if next_token.token_kind == TOKEN_KIND.get('binop_greaterthan'):
        return CGreaterThan()
    if next_token.token_kind == TOKEN_KIND.get('binop_greaterthanorequal'):
        return CGreaterOrEqual()


cdef CUnaryOp parse_unary_op():
    # <unop> ::= "-" | "~" | "!"
    expect_next_in(pop_next(), (TOKEN_KIND.get('unop_complement'),
                   TOKEN_KIND.get('unop_negation'),
                   TOKEN_KIND.get('unop_not')))
    if next_token.token_kind == TOKEN_KIND.get('unop_complement'):
        return CComplement()
    if next_token.token_kind == TOKEN_KIND.get('unop_negation'):
        return CNegate()
    if next_token.token_kind == TOKEN_KIND.get('unop_not'):
        return CNot()


cdef CExp parse_factor():
    # <factor> ::= <int> | <identifier> | <unop> <factor> | "(" <exp> ")"
    expect_next_in(peek_next(),(TOKEN_KIND.get('constant'),
                   TOKEN_KIND.get('identifier'),
                   TOKEN_KIND.get('unop_complement'),
                   TOKEN_KIND.get('unop_negation'),
                   TOKEN_KIND.get('unop_not'),
                   TOKEN_KIND.get('parenthesis_open')))
    cdef CUnaryOp unary_op
    cdef CExp inner_exp
    if peek_token.token_kind in (TOKEN_KIND.get('unop_complement'),
                                 TOKEN_KIND.get('unop_negation'),
                                 TOKEN_KIND.get('unop_not')):
        unary_op = parse_unary_op()
        inner_exp = parse_factor()
        return CUnary(unary_op, inner_exp)
    cdef TInt value
    if peek_token.token_kind == TOKEN_KIND.get('constant'):
        value = parse_int()
        return CConstant(value)
    cdef TIdentifier name
    if peek_token.token_kind == TOKEN_KIND.get('identifier'):
        name = parse_identifier()
        return CVar(name)
    if pop_next().token_kind == TOKEN_KIND.get('parenthesis_open'):
        inner_exp = parse_exp()
        expect_next_is(pop_next(), TOKEN_KIND.get('parenthesis_close'))
        return inner_exp


cdef CExp parse_exp(int min_precedence = 0):
    # <exp> ::= <factor> | <exp> <binop> <exp>
    cdef int precedence
    cdef CBinaryOp binary_op
    cdef CExp exp_right
    cdef CExp exp_left = parse_factor()
    while peek_next().token_kind in (TOKEN_KIND.get('unop_negation'),
                                     TOKEN_KIND.get('binop_addition'),
                                     TOKEN_KIND.get('binop_multiplication'),
                                     TOKEN_KIND.get('binop_division'),
                                     TOKEN_KIND.get('binop_remainder'),
                                     TOKEN_KIND.get('binop_bitand'),
                                     TOKEN_KIND.get('binop_bitor'),
                                     TOKEN_KIND.get('binop_bitxor'),
                                     TOKEN_KIND.get('binop_bitshiftleft'),
                                     TOKEN_KIND.get('binop_bitshiftright'),
                                     TOKEN_KIND.get('binop_lessthan'),
                                     TOKEN_KIND.get('binop_lessthanorequal'),
                                     TOKEN_KIND.get('binop_greaterthan'),
                                     TOKEN_KIND.get('binop_greaterthanorequal'),
                                     TOKEN_KIND.get('binop_equalto'),
                                     TOKEN_KIND.get('binop_notequal'),
                                     TOKEN_KIND.get('binop_and'),
                                     TOKEN_KIND.get('binop_or'),
                                     TOKEN_KIND.get('assignment_simple'),
                                     TOKEN_KIND.get('assignment_plus'),
                                     TOKEN_KIND.get('assignment_difference'),
                                     TOKEN_KIND.get('assignment_product'),
                                     TOKEN_KIND.get('assignment_quotient'),
                                     TOKEN_KIND.get('assignment_remainder'),
                                     TOKEN_KIND.get('assignment_bitand'),
                                     TOKEN_KIND.get('assignment_bitor'),
                                     TOKEN_KIND.get('assignment_bitxor'),
                                     TOKEN_KIND.get('assignment_bitshiftleft'),
                                     TOKEN_KIND.get('assignment_bitshiftright')):
        precedence = parse_token_precedence(peek_token.token_kind)
        if precedence < min_precedence:
            break
        if peek_token.token_kind == TOKEN_KIND.get('assignment_simple'):
            _ = pop_next()
            exp_right = parse_exp(precedence)
            exp_left = CAssignment(exp_left, exp_right)
        elif peek_token.token_kind in (TOKEN_KIND.get('assignment_plus'),
                                       TOKEN_KIND.get('assignment_difference'),
                                       TOKEN_KIND.get('assignment_product'),
                                       TOKEN_KIND.get('assignment_quotient'),
                                       TOKEN_KIND.get('assignment_remainder'),
                                       TOKEN_KIND.get('assignment_bitand'),
                                       TOKEN_KIND.get('assignment_bitor'),
                                       TOKEN_KIND.get('assignment_bitxor'),
                                       TOKEN_KIND.get('assignment_bitshiftleft'),
                                       TOKEN_KIND.get('assignment_bitshiftright')):
            binary_op = parse_binary_op()
            exp_right = parse_exp(precedence)
            exp_left = CAssignmentCompound(binary_op, exp_left, exp_right)
        else:
            binary_op = parse_binary_op()
            exp_right = parse_exp(precedence + 1)
            exp_left = CBinary(binary_op, exp_left, exp_right)
    return exp_left


cdef CStatement parse_statement():
    # <statement> ::= "return" <exp> ";" | <exp> ";" | ";"
    if peek_token.token_kind == TOKEN_KIND.get('semicolon'):
        _ = pop_next()
        return CNull()
    cdef CExp return_exp
    if peek_token.token_kind == TOKEN_KIND.get('key_return'):
        _ = pop_next()
        return_exp = parse_exp()
        expect_next_is(pop_next(), TOKEN_KIND.get('semicolon'))
        return CReturn(return_exp)
    if True:
        return_exp = parse_exp()
        expect_next_is(pop_next(), TOKEN_KIND.get('semicolon'))
        return CExpression(return_exp)


cdef CDeclaration parse_declaration():
    # <declaration> ::= "int" <identifier> [ "=" <exp> ] ";"
    expect_next_is(pop_next(), TOKEN_KIND.get('key_int'))
    cdef TIdentifier name = parse_identifier()
    cdef CExp init
    if peek_next().token_kind == TOKEN_KIND.get('assignment_simple'):
        _ = pop_next()
        init = parse_exp()
    else:
        init = None
    expect_next_is(pop_next(), TOKEN_KIND.get('semicolon'))
    return CDecl(name, init)


cdef CBlockItem parse_block_item():
    # <block-item> ::= <statement> | <declaration>
    cdef CDeclaration declaration
    if peek_token.token_kind == TOKEN_KIND.get('key_int'):
        declaration = parse_declaration()
        return CD(declaration)
    cdef CStatement statement
    if True:
        statement = parse_statement()
        return CS(statement)


cdef CFunctionDef parse_function_def():
    # <function> ::= "int" <identifier> "(" "void" ")" "{" { <block-item> } "}"
    expect_next_is(pop_next(), TOKEN_KIND.get('key_int'))
    cdef TIdentifier name = parse_identifier()
    expect_next_is(pop_next(), TOKEN_KIND.get('parenthesis_open'))
    expect_next_is(pop_next(), TOKEN_KIND.get('key_void'))
    expect_next_is(pop_next(), TOKEN_KIND.get('parenthesis_close'))
    expect_next_is(pop_next(), TOKEN_KIND.get('brace_open'))
    cdef CBlockItem block_item
    cdef list[CBlockItem] body = []
    while peek_next().token_kind != TOKEN_KIND.get('brace_close'):
        block_item = parse_block_item()
        body.append(block_item)
    expect_next_is(pop_next(), TOKEN_KIND.get('brace_close'))
    return CFunction(name, body)


cdef CProgram parse_program():
    # <program> ::= <function>
    cdef CFunctionDef function_def = parse_function_def()
    return CProgram(function_def)


cdef AST parsing(list[Token] lex_tokens):
    global tokens
    global next_token
    global peek_token
    tokens = lex_tokens

    cdef AST c_ast
    while True:
        try:
            next_token: Token = Token('', TOKEN_KIND.get('error'))
            peek_token: Token = Token('', TOKEN_KIND.get('error'))
            c_ast = parse_program()

        except StopIteration:
            break

    if tokens:
        raise RuntimeError(
            "An error occurred in parser, not all Tokens were consumed")

    if not c_ast:
        raise RuntimeError(
            "An error occurred in parser, Ast was not parsed")

    return c_ast
