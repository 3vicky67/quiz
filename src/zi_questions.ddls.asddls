@AccessControl.authorizationCheck: #NOT_REQUIRED
@EndUserText.label: 'Quiz Question'

define view entity ZI_Questions
  as select from zquiz_questions
  association to parent ZI_Quiz as _Quiz on $projection.QuizId = _Quiz.QuizId
{
      @UI.hidden: true
  key question_id    as QuestionId,

      @UI.hidden: true
      quiz_id        as QuizId,

      @UI.lineItem:       [{ position: 10, label: 'Question Text' }]
      @UI.identification: [{ position: 10, label: 'Question Text' }]
      question_text  as QuestionText,

      @UI.lineItem:       [{ position: 20, label: 'Your Answer' }]
      @UI.identification: [{ position: 20, label: 'Your Answer' }]
      user_answer    as UserAnswer,

      @UI.lineItem:       [{ position: 30, label: 'Correct Answer' }]
      @UI.identification: [{ position: 30, label: 'Correct Answer' }]
      correct_answer as CorrectAnswer,

      @UI.lineItem:       [{ position: 40, label: 'Status', criticality: 'StatusCriticality', criticalityRepresentation: #WITH_ICON }]
      @UI.identification: [{ position: 40, label: 'Status', criticality: 'StatusCriticality', criticalityRepresentation: #WITH_ICON }]
      status         as Status,

      @UI.hidden: true
      criticality    as StatusCriticality,

      @UI.lineItem:       [{ position: 50, label: 'Score' }]
      @UI.identification: [{ position: 50, label: 'Score' }]
      weightage      as Weightage,

      _Quiz
}
