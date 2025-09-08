class AnswerMailer < ApplicationMailer
  default from: "noreply@stackoverflow-clone.com"

  def new_answer(user, answer)
    @user = user
    @answer = answer
    @question = answer.question
    mail(to: @user.email, subject: "New answer to your question: #{@question.title}")
  end
end
