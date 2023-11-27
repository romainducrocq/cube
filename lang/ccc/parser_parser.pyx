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

    if tokens:
        next_token = tokens.pop(0)
        return next_token

    raise RuntimeError(
        "An error occurred in parser, all Tokens were consumed before end of program")


cdef Token peek_next():
    global peek_token

    if tokens:
        peek_token = tokens[0]
        return peek_token

    raise RuntimeError(
        "An error occurred in parser, all Tokens were consumed before end of program")


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


cdef CVar parse_var_factor():
    cdef TIdentifier name = parse_identifier()
    return CVar(name)


cdef CConstant parse_constant_factor():
    cdef TInt value = parse_int()
    return CConstant(value)


cdef CUnary parse_unary_factor():
    cdef CUnaryOp unary_op = parse_unary_op()
    cdef CExp exp = parse_factor()
    return CUnary(unary_op, exp)


cdef CExp parse_inner_exp_factor():
    cdef CExp inner_exp = parse_exp()
    expect_next_is(pop_next(), TOKEN_KIND.get('parenthesis_close'))
    return inner_exp


cdef CExp parse_factor():
    # <factor> ::= <int> | <identifier> | <unop> <factor> | "(" <exp> ")"
    expect_next_in(peek_next(),(TOKEN_KIND.get('constant'),
                   TOKEN_KIND.get('identifier'),
                   TOKEN_KIND.get('unop_complement'),
                   TOKEN_KIND.get('unop_negation'),
                   TOKEN_KIND.get('unop_not'),
                   TOKEN_KIND.get('parenthesis_open')))
    if peek_token.token_kind == TOKEN_KIND.get('identifier'):
        return parse_var_factor()
    if peek_token.token_kind == TOKEN_KIND.get('constant'):
        return parse_constant_factor()
    if peek_token.token_kind in (TOKEN_KIND.get('unop_complement'),
                                 TOKEN_KIND.get('unop_negation'),
                                 TOKEN_KIND.get('unop_not')):
        return parse_unary_factor()
    if pop_next().token_kind == TOKEN_KIND.get('parenthesis_open'):
        return parse_inner_exp_factor()


cdef CAssignment parse_assigment_exp(CExp exp_left, int precedence):
    _ = pop_next()
    cdef CExp exp_right = parse_exp(precedence)
    return CAssignment(exp_left, exp_right)


cdef CAssignmentCompound parse_assigment_compound_exp(CExp exp_left, int precedence):
    cdef CBinaryOp binary_op = parse_binary_op()
    cdef CExp exp_right = parse_exp(precedence)
    return CAssignmentCompound(binary_op, exp_left, exp_right)


cdef CConditional parse_ternary_exp(CExp exp_left, int precedence):
    _ = pop_next()
    cdef CExp exp_middle = parse_exp()
    expect_next_is(pop_next(), TOKEN_KIND.get('ternary_else'))
    cdef CExp exp_right = parse_exp(precedence)
    return CConditional(exp_left, exp_middle, exp_right)


cdef CBinary parse_binary_exp(CExp exp_left, int precedence):
    cdef CBinaryOp binary_op = parse_binary_op()
    cdef CExp exp_right = parse_exp(precedence + 1)
    return CBinary(binary_op, exp_left, exp_right)


cdef CExp parse_exp(int min_precedence = 0):
    # <exp> ::= <factor> | <exp> <binop> <exp> | <exp> "?" <exp> ":" <exp>
    cdef int precedence
    cdef CBinaryOp binary_op
    cdef CExp exp_right
    cdef CExp exp_middle
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
                                     TOKEN_KIND.get('assignment_bitshiftright'),
                                     TOKEN_KIND.get('ternary_if')):
        precedence = parse_token_precedence(peek_token.token_kind)
        if precedence < min_precedence:
            break
        if peek_token.token_kind == TOKEN_KIND.get('assignment_simple'):
            exp_left = parse_assigment_exp(exp_left, precedence)
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
            exp_left = parse_assigment_compound_exp(exp_left, precedence)
        elif peek_token.token_kind == TOKEN_KIND.get('ternary_if'):
            exp_left = parse_ternary_exp(exp_left, precedence)
        else:
            exp_left = parse_binary_exp(exp_left, precedence)
    return exp_left


cdef CNull parse_null_statement():
    _ = pop_next()
    return CNull()


cdef CReturn parse_return_statement():
    _ = pop_next()
    cdef CExp exp = parse_exp()
    expect_next_is(pop_next(), TOKEN_KIND.get('semicolon'))
    return CReturn(exp)


cdef CIf parse_if_statement():
    _ = pop_next()
    expect_next_is(pop_next(), TOKEN_KIND.get('parenthesis_open'))
    cdef CExp condition = parse_exp()
    expect_next_is(pop_next(), TOKEN_KIND.get('parenthesis_close'))
    _ = peek_next()
    cdef CStatement then = parse_statement()
    cdef CStatement else_fi
    if peek_next().token_kind == TOKEN_KIND.get('key_else'):
        _ = pop_next()
        _ = peek_next()
        else_fi = parse_statement()
    else:
        else_fi = None
    return CIf(condition, then, else_fi)


cdef CExpression parse_expression_statement():
    cdef CExp exp = parse_exp()
    expect_next_is(pop_next(), TOKEN_KIND.get('semicolon'))
    return CExpression(exp)


cdef CStatement parse_statement():
    # <statement> ::= "return" <exp> ";" | <exp> ";" | "if" "(" <exp> ")" <statement> [ "else" <statement> ] | ";"
    if peek_token.token_kind == TOKEN_KIND.get('semicolon'):
        return parse_null_statement()
    if peek_token.token_kind == TOKEN_KIND.get('key_return'):
        return parse_return_statement()
    if peek_token.token_kind == TOKEN_KIND.get('key_if'):
        return parse_if_statement()
    if True:
        return parse_expression_statement()


cdef CDecl parse_decl_declaration():
    _ = pop_next()
    cdef TIdentifier name = parse_identifier()
    cdef CExp init
    if peek_next().token_kind == TOKEN_KIND.get('assignment_simple'):
        _ = pop_next()
        init = parse_exp()
    else:
        init = None
    expect_next_is(pop_next(), TOKEN_KIND.get('semicolon'))
    return CDecl(name, init)


cdef CDeclaration parse_declaration():
    # <declaration> ::= "int" <identifier> [ "=" <exp> ] ";"
    if peek_token.token_kind == TOKEN_KIND.get('key_int'):
        return parse_decl_declaration()


cdef CD parse_d_block_item():
    cdef CDeclaration declaration = parse_declaration()
    return CD(declaration)


cdef CS parse_s_block_item():
    cdef CStatement statement = parse_statement()
    return CS(statement)


cdef CBlockItem parse_block_item():
    # <block-item> ::= <statement> | <declaration>
    if peek_token.token_kind == TOKEN_KIND.get('key_int'):
        return parse_d_block_item()
    if True:
        return parse_s_block_item()


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
    next_token = Token('', TOKEN_KIND.get('error'))
    peek_token = Token('', TOKEN_KIND.get('error'))

    cdef AST c_ast = parse_program()

    if tokens:
        raise RuntimeError(
            "An error occurred in parser, not all Tokens were consumed")

    if not c_ast:
        raise RuntimeError(
            "An error occurred in parser, Ast was not parsed")

    return c_ast
