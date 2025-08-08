require 'rails_helper'

RSpec.describe VotesHelper, type: :helper do
  let(:user) { create(:user) }
  let(:author) { create(:user) }
  let(:question) { create(:question, user: author) }
  let(:answer) { create(:answer, question: question, user: author) }

  describe '#render_voting_controls' do
    context 'when user is not authenticated' do
      before { allow(helper).to receive(:current_user).and_return(nil) }

      it 'returns empty string' do
        expect(helper.render_voting_controls(question)).to eq('')
      end
    end

    context 'when user is the author' do
      before { allow(helper).to receive(:current_user).and_return(author) }

      it 'returns empty string' do
        expect(helper.render_voting_controls(question)).to eq('')
      end
    end

    context 'when user is authenticated and not the author' do
      before { allow(helper).to receive(:current_user).and_return(user) }

      it 'renders voting controls' do
        expect(helper.render_voting_controls(question)).to include('flex items-center space-x-2')
        expect(helper.render_voting_controls(question)).to include('⬆')
        expect(helper.render_voting_controls(question)).to include('⬇')
      end

      it 'includes the resource rating' do
        expect(helper.render_voting_controls(question)).to include(question.rating.to_s)
      end

      context 'when user has already voted' do
        before { question.votes.create(user: user, value: 1) }

        it 'highlights the upvote button' do
          expect(helper.render_voting_controls(question)).to include('text-green-600')
        end

        it 'includes cancel vote button' do
          expect(helper.render_voting_controls(question)).to include('✕')
        end
      end
    end
  end

  describe '#render_vote_button' do
    before { allow(helper).to receive(:current_user).and_return(user) }

    it 'renders a button with correct attributes' do
      result = helper.render_vote_button(question, 1, '⬆', 'test-class')
      expect(result).to include('test-class')
      expect(result).to include('⬆')
      expect(result).to include('data-action="click-')
      expect(result).to include('votes#vote')
      expect(result).to include('up')
    end

    it 'renders a down vote button for negative value' do
      result = helper.render_vote_button(question, -1, '⬇', 'test-class')
      expect(result).to include('down')
    end
  end

  describe '#render_cancel_vote_button' do
    before do
      allow(helper).to receive(:current_user).and_return(user)
    end

    context 'when user has voted' do
      let!(:vote) { question.votes.create(user: user, value: 1) }

      it 'renders cancel button' do
        result = helper.render_cancel_vote_button(question)
        expect(result).to include('✕')
        expect(result).to include('data-action="click-')
        expect(result).to include('votes#cancelVote')
      end
    end

    context 'when user has not voted' do
      it 'returns empty string' do
        expect(helper.render_cancel_vote_button(question)).to eq('')
      end
    end
  end
end
