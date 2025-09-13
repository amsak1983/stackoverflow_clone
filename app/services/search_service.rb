class SearchService
  SEARCHABLE_MODELS = %w[questions answers comments users].freeze

  def initialize(query, model = "all")
    @query = query.to_s.strip
    @model = model.presence || "all"
  end

  def call
    return [] if @query.blank?

    case @model
    when *SEARCHABLE_MODELS
      search_single_model(@model)
    else
      search_all_models
    end
  end

  private

  def search_single_model(model_name)
    model_class = model_name.singularize.classify.constantize
    serialize_results(model_class.search_simple(@query).records)
  end

  def search_all_models
    results = SEARCHABLE_MODELS.flat_map do |model_name|
      model_class = model_name.singularize.classify.constantize
      serialize_results(model_class.search_simple(@query).records)
    end

    results.sort_by { |r| r[:created_at] || Time.at(0) }.reverse
  end

  def serialize_results(records)
    Array(records).map do |record|
      SearchResultSerializer.new(record).as_json
    end
  end
end
