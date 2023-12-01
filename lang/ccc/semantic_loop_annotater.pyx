from ccc.parser_c_ast cimport CWhile, CDoWhile, CFor, CBreak, CContinue


cdef void annotate_while_loop(CWhile node):
    pass


cdef void annotate_do_while_loop(CDoWhile node):
    pass


cdef void annotate_for_loop(CFor node):
    pass


cdef void annotate_break_loop(CBreak node):
    pass


cdef void annotate_continue_loop(CContinue node):
    pass
