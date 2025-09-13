class SearchResultSerializer
  include Rails.application.routes.url_helpers

  def initialize(record)
    @record = record
  end

  def as_json
    case @record
    when Question
      QuestionSearchSerializer.new(@record).as_json
    when Answer
      AnswerSearchSerializer.new(@record).as_json
    when Comment
      CommentSearchSerializer.new(@record).as_json
    when User
      UserSearchSerializer.new(@record).as_json
    else
      { model: @record.class.name, title: @record.try(:to_s), text: "", path: "#" }
    end
  end
end

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

class UserSearchSerializer
  def initialize(user)
    @user = user
  end

  def as_json
    {
      model: "User",
      title: @user.name,
      text: @user.email,
      path: "#",
      created_at: @user.created_at
    }
  end
end
