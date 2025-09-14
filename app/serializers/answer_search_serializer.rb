class AnswerSearchSerializer
  include Rails.application.routes.url_helpers

  def initialize(answer)
    @answer = answer
  end

  def as_json
    {
      model: "Answer",
      title: "Answer to question: #{@answer.question.title.truncate(60)}",
      text: @answer.body.to_s.truncate(180),
      path: question_path(@answer.question, anchor: "answer_#{@answer.id}"),
      created_at: @answer.created_at
    }
  end
end
