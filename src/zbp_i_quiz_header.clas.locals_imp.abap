" ======================================================================
" 1. HANDLER CLASS FOR QUIZ HEADER
" ======================================================================
CLASS lhc_Quiz DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    METHODS create FOR MODIFY IMPORTING entities FOR CREATE Quiz.
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Quiz.
    METHODS delete FOR MODIFY IMPORTING keys     FOR DELETE Quiz.
    METHODS read   FOR READ   IMPORTING keys     FOR READ Quiz RESULT result.
    METHODS lock   FOR LOCK   IMPORTING keys     FOR LOCK Quiz.

    METHODS cba_Questions FOR MODIFY IMPORTING entities_cba FOR CREATE Quiz\_Questions.

    METHODS get_instance_authorizations FOR INSTANCE AUTHORIZATION
      IMPORTING keys REQUEST requested_authorizations FOR Quiz RESULT result.
ENDCLASS.

CLASS lhc_Quiz IMPLEMENTATION.

  METHOD get_instance_authorizations.
  ENDMETHOD.

 METHOD create.
    GET TIME STAMP FIELD DATA(lv_ts).
    LOOP AT entities INTO DATA(ls_entity).
      APPEND VALUE #(
        quiz_id          = ls_entity-QuizId
        participant_name = ls_entity-ParticipantName
        title            = ls_entity-Title
        difficulty       = ls_entity-Difficulty
        total_marks      = ls_entity-TotalMarks " <-- ADDED THIS LINE
        created_by       = sy-uname
        last_changed_at  = lv_ts
      ) TO zbp_i_quiz_header=>mt_header_buffer.
    ENDLOOP.
  ENDMETHOD.

  METHOD update.
    GET TIME STAMP FIELD DATA(lv_ts).
    LOOP AT entities INTO DATA(ls_entity).
      APPEND VALUE #(
        quiz_id          = ls_entity-QuizId
        participant_name = ls_entity-ParticipantName
        title            = ls_entity-Title
        difficulty       = ls_entity-Difficulty
        total_marks      = ls_entity-TotalMarks " <-- ADDED THIS LINE
        last_changed_at  = lv_ts
      ) TO zbp_i_quiz_header=>mt_header_buffer.
    ENDLOOP.
  ENDMETHOD.
  METHOD delete.
    " Push ID to buffer instead of direct DB delete
    LOOP AT keys INTO DATA(ls_key).
      APPEND ls_key-QuizId TO zbp_i_quiz_header=>mt_header_del.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zquiz_header FOR ALL ENTRIES IN @keys
      WHERE quiz_id = @keys-QuizId INTO TABLE @DATA(lt_res).

    LOOP AT lt_res INTO DATA(ls_db).
      INSERT VALUE #(
        %tky            = VALUE #( QuizId = ls_db-quiz_id )
        QuizId          = ls_db-quiz_id
        ParticipantName = ls_db-participant_name
        Title           = ls_db-title
        Difficulty      = ls_db-difficulty
        TotalMarks      = ls_db-total_marks
        LastChangedAt   = ls_db-last_changed_at
      ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD lock.
  ENDMETHOD.

  METHOD cba_Questions.
    DATA: ls_db_item TYPE zquiz_questions.
    LOOP AT entities_cba INTO DATA(ls_cba).
      LOOP AT ls_cba-%target INTO DATA(ls_target).
        CLEAR ls_db_item.
        ls_db_item-question_id    = ls_target-QuestionId.
        ls_db_item-quiz_id        = ls_cba-QuizId.
        ls_db_item-question_text  = ls_target-QuestionText.
        ls_db_item-user_answer    = ls_target-UserAnswer.
        ls_db_item-correct_answer = ls_target-CorrectAnswer.
        ls_db_item-status         = ls_target-Status.
        ls_db_item-criticality    = ls_target-StatusCriticality.
        ls_db_item-weightage      = ls_target-Weightage.
        APPEND ls_db_item TO zbp_i_quiz_header=>mt_item_buffer.
      ENDLOOP.
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.

" ======================================================================
" 2. SAVER CLASS (OPTION B COMMIT)
" ======================================================================
CLASS lsc_ZI_QUIZ DEFINITION INHERITING FROM cl_abap_behavior_saver.
  PROTECTED SECTION.
    METHODS save    REDEFINITION.
    METHODS cleanup REDEFINITION.
ENDCLASS.

CLASS lsc_ZI_QUIZ IMPLEMENTATION.

  METHOD save.
    IF zbp_i_quiz_header=>mt_header_buffer IS NOT INITIAL.
      MODIFY zquiz_header FROM TABLE @zbp_i_quiz_header=>mt_header_buffer.
    ENDIF.

    IF zbp_i_quiz_header=>mt_item_buffer IS NOT INITIAL.
      MODIFY zquiz_questions FROM TABLE @zbp_i_quiz_header=>mt_item_buffer.
    ENDIF.

    " Process Header Deletions
    IF zbp_i_quiz_header=>mt_header_del IS NOT INITIAL.
      LOOP AT zbp_i_quiz_header=>mt_header_del INTO DATA(lv_h_id).
        DELETE FROM zquiz_header    WHERE quiz_id = @lv_h_id.
        DELETE FROM zquiz_questions WHERE quiz_id = @lv_h_id.
      ENDLOOP.
    ENDIF.

    " Process Item Deletions
    IF zbp_i_quiz_header=>mt_item_del IS NOT INITIAL.
      LOOP AT zbp_i_quiz_header=>mt_item_del INTO DATA(lv_i_id).
        DELETE FROM zquiz_questions WHERE question_id = @lv_i_id.
      ENDLOOP.
    ENDIF.
  ENDMETHOD.

  METHOD cleanup.
    CLEAR: zbp_i_quiz_header=>mt_header_buffer,
           zbp_i_quiz_header=>mt_item_buffer,
           zbp_i_quiz_header=>mt_header_del,
           zbp_i_quiz_header=>mt_item_del.
  ENDMETHOD.

ENDCLASS.
