class AnswerNotificationJob < ApplicationJob
  queue_as :default

  def perform(answer_id)
    answer = Answer.find_by(id: answer_id)
    return unless answer

    question = answer.question

    question.subscribers
            .where.not(id: answer.user_id)
            .find_each(batch_size: 500) do |user|
      AnswerMailer.new_answer(user, answer).deliver_now
    end
  end
end
