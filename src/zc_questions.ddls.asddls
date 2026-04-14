@EndUserText.label: 'Question Projection View'
@AccessControl.authorizationCheck: #NOT_REQUIRED
@Metadata.allowExtensions: true

define view entity ZC_Questions
  as projection on ZI_Questions
{
    key QuestionId,
    QuizId,
    QuestionText,
    UserAnswer,
    CorrectAnswer,
    Status,
    StatusCriticality, 
    Weightage,
    
    _Quiz : redirected to parent ZC_Quiz
}
