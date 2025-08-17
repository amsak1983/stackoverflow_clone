# frozen_string_literal: true

class CommentBroadcaster
  class << self
    def append(comment)
      commentable = comment.commentable
      stream = [ commentable, :comments ]
      target = "#{ActionView::RecordIdentifier.dom_id(commentable)}_comments"

      Turbo::StreamsChannel.broadcast_append_to(
        stream,
        target: target,
        partial: "comments/comment",
        locals: { comment: comment }
      )
    end

    def remove(comment)
      commentable = comment.commentable
      stream = [ commentable, :comments ]
      target = ActionView::RecordIdentifier.dom_id(comment)

      Turbo::StreamsChannel.broadcast_remove_to(
        stream,
        target: target
      )
    end
  end
end
