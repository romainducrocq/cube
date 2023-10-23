from helper import iota, AttributeDict


TOKEN_KIND: AttributeDict[str, int] = AttributeDict({
    "identifier": iota(init=True),  # [a-zA-Z_]\w*\b
    "constant": iota(),             # [0-9]+\b
    "key_int": iota(),              # int\b
    "key_void": iota(),             # void\b
    "key_return": iota(),           # return\b
    "parenthesis_open": iota(),     # \(
    "parenthesis_close": iota(),    # \)
    "brace_open": iota(),           # {
    "brace_close": iota(),          # }
    "semicolon": iota()             # ;
})


TOKEN_REGEX: AttributeDict[int, str] = AttributeDict({
    TOKEN_KIND.identifier: "[a-zA-Z_]\\w*\\b",
    TOKEN_KIND.constant: "[0-9]+\\b",
    TOKEN_KIND.key_int: "int\\b",
    TOKEN_KIND.key_void: "void\\b",
    TOKEN_KIND.key_return: "return\\b",
    TOKEN_KIND.parenthesis_open: "\\(",
    TOKEN_KIND.parenthesis_close: "\\)",
    TOKEN_KIND.brace_open: "{",
    TOKEN_KIND.brace_close: "}",
    TOKEN_KIND.semicolon: ";"
})


# if __name__ == "__main__":
#     for token_kind in TOKEN_KIND:
#         print(token_kind, TOKEN_KIND[token_kind], TOKEN_REGEX[TOKEN_KIND[token_kind]])
