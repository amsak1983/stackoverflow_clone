class SearchController < ApplicationController
  # Simple, beginner-friendly search across 4 models via Elasticsearch.
  # Params:
  # - params[:query] — search query string
  # - params[:model] — one of: "all", "questions", "answers", "comments", "users"
  # Default: global search (all).
  def index
    @query = params[:query].to_s.strip
    @model = params[:model].presence || "all"

    @results = SearchService.new(@query, @model).call
  end
end
