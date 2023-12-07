from ccc.parser_c_ast cimport CWhile, CDoWhile, CFor, CBreak, CContinue

cdef void annotate_while_loop(CWhile node)
cdef void annotate_do_while_loop(CDoWhile node)
cdef void annotate_for_loop(CFor node)
cdef void annotate_break_loop(CBreak node)
cdef void annotate_continue_loop(CContinue node)
cdef void deannotate_loop()
cdef void init_annotate_loop()
