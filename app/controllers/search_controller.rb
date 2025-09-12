class SearchController < ApplicationController
  # Simple, beginner-friendly search across 4 models via Elasticsearch.
  # Params:
  # - params[:query] — search query string
  # - params[:model] — one of: "all", "questions", "answers", "comments", "users"
  # Default: global search (all).
  def index
    @query = params[:query].to_s.strip
    @model = params[:model].presence || "all"

    @results = []

    return if @query.blank? # Empty query: just show the form/placeholder

    case @model
    when "questions"
      @results = wrap_results(Question.search_simple(@query).records)
    when "answers"
      @results = wrap_results(Answer.search_simple(@query).records)
    when "comments"
      @results = wrap_results(Comment.search_simple(@query).records)
    when "users"
      @results = wrap_results(User.search_simple(@query).records)
    else # "all"
      results = []
      results += wrap_results(Question.search_simple(@query).records)
      results += wrap_results(Answer.search_simple(@query).records)
      results += wrap_results(Comment.search_simple(@query).records)
      results += wrap_results(User.search_simple(@query).records)
      # For simplicity, sort by creation time if available
      @results = results.sort_by { |r| r[:created_at] || Time.at(0) }.reverse
    end
  end

  private

  # Convert model records to a unified, simple hash for rendering in the view.
  def wrap_results(records)
    Array(records).map do |record|
      case record
      when Question
        {
          model: "Question",
          title: record.title,
          text:  record.body.to_s.truncate(180),
          path:  Rails.application.routes.url_helpers.question_path(record),
          created_at: record.created_at
        }
      when Answer
        {
          model: "Answer",
          title: "Answer to question: #{record.question.title.truncate(60)}",
          text:  record.body.to_s.truncate(180),
          path:  Rails.application.routes.url_helpers.question_path(record.question, anchor: "answer_#{record.id}"),
          created_at: record.created_at
        }
      when Comment
        owner = record.commentable
        owner_title = case owner
        when Question then owner.title
        when Answer then "Answer to: #{owner.question.title}"
        else owner.class.name
        end
        {
          model: "Comment",
          title: "Comment to: #{owner_title.to_s.truncate(60)}",
          text:  record.body.to_s.truncate(180),
          path:  case owner
                 when Question then Rails.application.routes.url_helpers.question_path(owner, anchor: "comment_#{record.id}")
                 when Answer then Rails.application.routes.url_helpers.question_path(owner.question, anchor: "comment_#{record.id}")
                 else "#"
                 end,
          created_at: record.created_at
        }
      when User
        {
          model: "User",
          title: record.name,
          text:  record.email,
          path:  "#", # No public profile in this project — keep as #
          created_at: record.created_at
        }
      else
        { model: record.class.name, title: record.try(:to_s), text: "", path: "#" }
      end
    end
  end
end
