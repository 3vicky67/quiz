@EndUserText.label: 'Quiz Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define root view entity ZC_Quiz
  provider contract transactional_query
  as projection on ZI_Quiz
{
    key QuizId,
    ParticipantName,
    Title,
    Difficulty,
    TotalMarks,
    DifficultyCriticality,
    LastChangedAt,            

    _Questions : redirected to composition child ZC_Questions
}
