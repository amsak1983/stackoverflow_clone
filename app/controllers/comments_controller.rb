class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable

  def create
    @comment = @commentable.comments.build(comment_params.merge(user: current_user))
    if @comment.save
      broadcast_comment(@comment)
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, notice: 'Comment created' }
        format.turbo_stream
      end
    else
      respond_to do |format|
        format.html { redirect_back fallback_location: root_path, alert: @comment.errors.full_messages.to_sentence }
        format.turbo_stream { head :unprocessable_content }
      end
    end
  end

  private

  def set_commentable
    if params[:question_id]
      @commentable = Question.find(params[:question_id])
    elsif params[:answer_id]
      @commentable = Answer.find(params[:answer_id])
    else
      head :bad_request
    end
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def broadcast_comment(comment)
    question_id = case comment.commentable
                  when Question then comment.commentable_id
                  when Answer then comment.commentable.question_id
                  end

    rendered = ApplicationController.render(
      partial: 'comments/comment',
      locals: { comment: comment }
    )

    ActionCable.server.broadcast("questions/#{question_id}/comments", { html: rendered, dom_id: "comment_#{comment.id}" })
  end
end 
