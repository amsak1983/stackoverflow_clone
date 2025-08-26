require 'rails_helper'

RSpec.describe CommentBroadcaster, type: :service do
  let(:question) { create(:question) }
  let(:comment) { create(:comment, commentable: question) }

  describe '.append' do
    it 'broadcasts append action to correct stream' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_append_to).with(
        [question, :comments],
        target: "#{ActionView::RecordIdentifier.dom_id(question)}_comments",
        partial: "comments/comment",
        locals: { comment: comment }
      )

      CommentBroadcaster.append(comment)
    end
  end

  describe '.remove' do
    it 'broadcasts remove action to correct stream' do
      expect(Turbo::StreamsChannel).to receive(:broadcast_remove_to).with(
        [question, :comments],
        target: ActionView::RecordIdentifier.dom_id(comment)
      )

      CommentBroadcaster.remove(comment)
    end
  end
end
