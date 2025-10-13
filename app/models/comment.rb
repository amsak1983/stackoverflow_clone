class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true, length: { maximum: 2000 }

  include Elasticsearch::Model
  # Callbacks disabled to prevent 500 errors if Elasticsearch is unavailable
  # Use Comment.__elasticsearch__.import for manual indexing if needed
  # include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 1, number_of_replicas: 0 } do
    mappings dynamic: false do
      indexes :body, type: :text
    end
  end

  def as_indexed_json(_options = {})
    { body: body }
  end

  def self.search_simple(query)
    return none if query.blank?

    __elasticsearch__.search(
      query: { match: { body: query } }
    )
  end
end
