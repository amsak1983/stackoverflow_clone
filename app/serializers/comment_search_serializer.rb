class CommentSearchSerializer
  include Rails.application.routes.url_helpers

  def initialize(comment)
    @comment = comment
  end

  def as_json
    owner = @comment.commentable
    owner_title = case owner
    when Question then owner.title
    when Answer then "Answer to: #{owner.question.title}"
    else owner.class.name
    end

    {
      model: "Comment",
      title: "Comment to: #{owner_title.to_s.truncate(60)}",
      text: @comment.body.to_s.truncate(180),
      path: comment_path(owner),
      created_at: @comment.created_at
    }
  end

  private

  def comment_path(owner)
    case owner
    when Question then question_path(owner, anchor: "comment_#{@comment.id}")
    when Answer then question_path(owner.question, anchor: "comment_#{@comment.id}")
    else "#"
    end
  end
end
