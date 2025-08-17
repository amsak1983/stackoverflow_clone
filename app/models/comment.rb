class Comment < ApplicationRecord
  belongs_to :user
  belongs_to :commentable, polymorphic: true

  validates :body, presence: true, length: { maximum: 2000 }

  after_create_commit :broadcast_creation

  private

  def broadcast_creation
    stream = [commentable, :comments]
    target = "#{ActionView::RecordIdentifier.dom_id(commentable)}_comments"
    broadcast_append_to stream,
      target: target,
      partial: "comments/comment",
      locals: { comment: self }
  end
end
