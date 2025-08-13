class CommentsChannel < ApplicationCable::Channel
  def subscribed
    question = Question.find(params[:question_id])
    stream_from "question_#{question.id}_comments"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
