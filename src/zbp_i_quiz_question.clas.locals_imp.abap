" ======================================================================
" HANDLER CLASS FOR QUESTIONS (ITEMS)
" ======================================================================
CLASS lhc_Question DEFINITION INHERITING FROM cl_abap_behavior_handler.
  PRIVATE SECTION.
    " ---> REMOVED: METHODS create FOR MODIFY... <---
    METHODS update FOR MODIFY IMPORTING entities FOR UPDATE Question.
    METHODS delete FOR MODIFY IMPORTING keys     FOR DELETE Question.
    METHODS read   FOR READ   IMPORTING keys     FOR READ Question RESULT result.

    METHODS calculateScore FOR DETERMINE ON MODIFY
      IMPORTING keys FOR Question~calculateScore.

    METHODS get_global_authorizations FOR GLOBAL AUTHORIZATION
      IMPORTING REQUEST requested_authorizations FOR Question RESULT result.
ENDCLASS.

CLASS lhc_Question IMPLEMENTATION.

  METHOD get_global_authorizations.
  ENDMETHOD.

  " ---> REMOVED: METHOD create... ENDMETHOD. <---

  METHOD update.
    DATA: ls_db_item TYPE zquiz_questions.
    LOOP AT entities INTO DATA(ls_entity).
      SELECT SINGLE * FROM zquiz_questions
        WHERE question_id = @ls_entity-QuestionId
        INTO @ls_db_item.

      ls_db_item-question_id = ls_entity-QuestionId.
      IF ls_entity-QuizId IS NOT INITIAL.
        ls_db_item-quiz_id = ls_entity-QuizId.
      ENDIF.

      IF ls_entity-%control-QuestionText = if_abap_behv=>mk-on.
        ls_db_item-question_text = ls_entity-QuestionText.
      ENDIF.
      IF ls_entity-%control-UserAnswer = if_abap_behv=>mk-on.
        ls_db_item-user_answer = ls_entity-UserAnswer.
      ENDIF.
      IF ls_entity-%control-CorrectAnswer = if_abap_behv=>mk-on.
        ls_db_item-correct_answer = ls_entity-CorrectAnswer.
      ENDIF.
      IF ls_entity-%control-Status = if_abap_behv=>mk-on.
        ls_db_item-status = ls_entity-Status.
      ENDIF.
      IF ls_entity-%control-StatusCriticality = if_abap_behv=>mk-on.
        ls_db_item-criticality = ls_entity-StatusCriticality.
      ENDIF.
      IF ls_entity-%control-Weightage = if_abap_behv=>mk-on.
        ls_db_item-weightage = ls_entity-Weightage.
      ENDIF.

      APPEND ls_db_item TO zbp_i_quiz_header=>mt_item_buffer.
    ENDLOOP.
  ENDMETHOD.

  METHOD delete.
    " Push ID to buffer instead of direct DB delete
    LOOP AT keys INTO DATA(ls_key).
      APPEND ls_key-QuestionId TO zbp_i_quiz_header=>mt_item_del.
    ENDLOOP.
  ENDMETHOD.

  METHOD read.
    SELECT * FROM zquiz_questions
      FOR ALL ENTRIES IN @keys
      WHERE question_id = @keys-QuestionId
      INTO TABLE @DATA(lt_res).

    LOOP AT lt_res INTO DATA(ls_db).
      INSERT VALUE #(
        %tky              = VALUE #( QuestionId = ls_db-question_id )
        QuestionId        = ls_db-question_id
        QuizId            = ls_db-quiz_id
        QuestionText      = ls_db-question_text
        UserAnswer        = ls_db-user_answer
        CorrectAnswer     = ls_db-correct_answer
        Status            = ls_db-status
        StatusCriticality = ls_db-criticality
        Weightage         = ls_db-weightage
      ) INTO TABLE result.
    ENDLOOP.
  ENDMETHOD.

  METHOD calculateScore.
    READ ENTITIES OF ZI_Quiz IN LOCAL MODE
      ENTITY Question ALL FIELDS WITH CORRESPONDING #( keys )
      RESULT DATA(lt_questions).

    LOOP AT lt_questions ASSIGNING FIELD-SYMBOL(<fs_q>).
      " Determine individual status and color
      IF <fs_q>-UserAnswer = <fs_q>-CorrectAnswer AND <fs_q>-UserAnswer IS NOT INITIAL.
        <fs_q>-Status = '✔ Correct'.
        <fs_q>-StatusCriticality = 3. " Green
      ELSEIF <fs_q>-UserAnswer IS NOT INITIAL.
        <fs_q>-Status = '✘ Wrong'.
        <fs_q>-StatusCriticality = 1. " Red
      ENDIF.

      " Update ONLY the Question (Leave the Header alone for manual entry)
      MODIFY ENTITIES OF ZI_Quiz IN LOCAL MODE
        ENTITY Question UPDATE FIELDS ( Status StatusCriticality )
        WITH VALUE #( ( %tky              = <fs_q>-%tky
                        Status            = <fs_q>-Status
                        StatusCriticality = <fs_q>-StatusCriticality ) ).
    ENDLOOP.
  ENDMETHOD.

ENDCLASS.
