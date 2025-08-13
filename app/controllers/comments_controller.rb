class CommentsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_commentable
  before_action :set_comment, only: [:destroy]
  before_action :check_author, only: [:destroy]

  def create
    @comment = @commentable.comments.build(comment_params)
    @comment.user = current_user

    if @comment.save
      # Broadcast new comment to all subscribers
      ActionCable.server.broadcast(
        "question_#{question_id}_comments",
        {
          action: 'create',
          comment: render_comment(@comment),
          commentable_type: @commentable.class.name.downcase,
          commentable_id: @commentable.id
        }
      )

      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to question_path(question_id) }
      end
    else
      respond_to do |format|
        format.turbo_stream { render turbo_stream: turbo_stream.replace("comment_form_#{@commentable.class.name.downcase}_#{@commentable.id}", partial: 'comments/form', locals: { commentable: @commentable, comment: @comment }) }
        format.html { redirect_to question_path(question_id), alert: 'Comment could not be created.' }
      end
    end
  end

  def destroy
    @comment.destroy

    # Broadcast comment deletion to all subscribers
    ActionCable.server.broadcast(
      "question_#{question_id}_comments",
      {
        action: 'destroy',
        comment_id: @comment.id
      }
    )

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to question_path(question_id) }
    end
  end

  private

  def set_commentable
    if params[:question_id]
      @commentable = Question.find(params[:question_id])
    elsif params[:answer_id]
      @commentable = Answer.find(params[:answer_id])
    end
  end

  def set_comment
    @comment = Comment.find(params[:id])
  end

  def check_author
    return if current_user&.author_of?(@comment.commentable) || current_user == @comment.user

    respond_to do |format|
      format.html { redirect_to root_path, alert: "Access denied" }
      format.turbo_stream { head :forbidden }
    end
    head :forbidden and return
  end

  def comment_params
    params.require(:comment).permit(:body)
  end

  def question_id
    if @commentable.is_a?(Question)
      @commentable.id
    elsif @commentable.is_a?(Answer)
      @commentable.question.id
    end
  end

  def render_comment(comment)
    ApplicationController.render(
      partial: 'comments/comment',
      locals: { comment: comment }
    )
  end
end
