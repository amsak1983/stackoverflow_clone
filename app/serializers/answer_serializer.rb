class AnswerSerializer < ApplicationSerializer
  attributes :id, :body, :question_id, :user_id, :best, :created_at, :updated_at, :files_urls

  has_many :comments, serializer: CommentSerializer
  has_many :links, serializer: LinkSerializer

  def files_urls
    object.files.map { |file| Rails.application.routes.url_helpers.rails_blob_url(file, only_path: false) }
  end
end
