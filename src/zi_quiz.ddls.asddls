@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Quiz Header'
define root view entity ZI_Quiz
  as select from zquiz_header
  composition [0..*] of ZI_Questions as _Questions
{
  key quiz_id         as QuizId,
  participant_name    as ParticipantName,
  title               as Title,
  difficulty          as Difficulty,
  total_marks         as TotalMarks,
  
  /* Virtual field or Logic for Difficulty Color */
  case when difficulty > 7 then 1      -- High: Red
       when difficulty > 4 then 2      -- Medium: Yellow
       else 3                          -- Low: Green
  end as DifficultyCriticality,
  
  @Semantics.systemDateTime.lastChangedAt: true
  last_changed_at     as LastChangedAt,

  _Questions
}
