class SearchResultSerializer
  include Rails.application.routes.url_helpers

  ALLOWED_SERIALIZERS = %w[Question Answer Comment User].freeze

  def initialize(record)
    @record = record
  end

  def as_json
    klass = @record.class.name
    if ALLOWED_SERIALIZERS.include?(klass)
      serializer_class = "#{klass}SearchSerializer".safe_constantize
      return serializer_class.new(@record).as_json if serializer_class
    end

    { model: klass, title: @record.try(:to_s), text: "", path: "#" }
  end
end
