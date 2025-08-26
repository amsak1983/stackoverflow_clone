require 'rails_helper'

RSpec.describe QuestionBroadcaster, type: :service do
  let(:question) { create(:question) }

  describe '.append' do
    it 'broadcasts question with correct data' do
      rendered_html = '<div>Question HTML</div>'

      expect(ApplicationController).to receive(:render).with(
        partial: "questions/question",
        locals: { question: question }
      ).and_return(rendered_html)

      expect(ActionCable.server).to receive(:broadcast).with(
        "questions",
        { html: rendered_html }
      )

      QuestionBroadcaster.append(question)
    end
  end

  describe '.update' do
    it 'broadcasts question update with id' do
      rendered_html = '<div>Updated Question HTML</div>'

      expect(ApplicationController).to receive(:render).with(
        partial: "questions/question",
        locals: { question: question }
      ).and_return(rendered_html)

      expect(ActionCable.server).to receive(:broadcast).with(
        "questions",
        { html: rendered_html, id: question.id }
      )

      QuestionBroadcaster.update(question)
    end
  end

  describe '.remove' do
    it 'broadcasts remove action with question id' do
      expect(ActionCable.server).to receive(:broadcast).with(
        "questions",
        { id: question.id, action: "remove" }
      )

      QuestionBroadcaster.remove(question)
    end
  end
end
