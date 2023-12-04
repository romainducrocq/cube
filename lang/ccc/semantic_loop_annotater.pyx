from ccc.parser_c_ast cimport TIdentifier, CWhile, CDoWhile, CFor, CBreak, CContinue

from ccc.semantic_name cimport represent_label_identifier


cdef list[str] loop_labels = []


cdef void annotate_while_loop(CWhile node):
    node.target = represent_label_identifier("while")
    loop_labels.append(node.target.str_t)


cdef void annotate_do_while_loop(CDoWhile node):
    node.target = represent_label_identifier("do_while")
    loop_labels.append(node.target.str_t)


cdef void annotate_for_loop(CFor node):
    node.target = represent_label_identifier("for")
    loop_labels.append(node.target.str_t)


cdef void annotate_break_loop(CBreak node):
    if not loop_labels:

        raise RuntimeError(
            "An error occurred in loop annotation, break is outside of loop")

    node.target = TIdentifier(loop_labels[-1])


cdef void annotate_continue_loop(CContinue node):
    if not loop_labels:

        raise RuntimeError(
            "An error occurred in loop annotation, continue is outside of loop")

    node.target = TIdentifier(loop_labels[-1])


cdef void deannotate_loop():
    del loop_labels[-1]


cdef void init_annotate_loop():
    global loop_labels
    loop_labels = []
