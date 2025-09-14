class QuestionSearchSerializer
  include Rails.application.routes.url_helpers

  def initialize(question)
    @question = question
  end

  def as_json
    {
      model: "Question",
      title: @question.title,
      text: @question.body.to_s.truncate(180),
      path: question_path(@question),
      created_at: @question.created_at
    }
  end
end
