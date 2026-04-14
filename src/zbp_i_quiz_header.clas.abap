CLASS zbp_i_quiz_header DEFINITION PUBLIC ABSTRACT FINAL FOR BEHAVIOR OF zi_quiz.
  PUBLIC SECTION.
    CLASS-DATA:
      mt_header_buffer TYPE TABLE OF zquiz_header,
      mt_item_buffer   TYPE TABLE OF zquiz_questions,
      mt_header_del    TYPE TABLE OF sysuuid_x16,
      mt_item_del      TYPE TABLE OF sysuuid_x16.
ENDCLASS.

CLASS zbp_i_quiz_header IMPLEMENTATION.
ENDCLASS.
