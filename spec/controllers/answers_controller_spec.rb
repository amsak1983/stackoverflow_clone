require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:user) { create(:user) }
  let(:question) { create(:question, user: user) }

  describe 'POST #create' do
    before { login(user) }
    
    context 'with valid attributes' do
      let(:valid_params) { { question_id: question, answer: attributes_for(:answer) } }

      it 'saves a new answer in the database' do
        expect { post :create, params: valid_params }.to change(question.answers, :count).by(1)
      end

      context 'after request' do
        before { post :create, params: valid_params }

        it 'redirects to question show view' do
          expect(response).to redirect_to question_path(question)
        end

        include_examples 'sets flash message', :notice, 'Answer was successfully created'
      end
    end

    context 'with invalid attributes' do
      let(:invalid_params) { { question_id: question, answer: attributes_for(:answer, body: nil) } }

      it 'does not save the answer' do
        expect { post :create, params: invalid_params }.to_not change(Answer, :count)
      end

      context 'after request' do
        before { post :create, params: invalid_params }

        include_examples 'renders template', 'questions/show'
        include_examples 'request status', :unprocessable_entity

        it 'assigns the question' do
          expect(assigns(:question)).to eq question
        end

        it 'assigns answers collection ordered by newest first' do
          expect(assigns(:answers)).to eq question.answers.newest_first
        end
      end
    end
  end

  describe 'error handling' do
    context 'when question not found' do
      before do 
        login(user)
        post :create, params: { question_id: 999, answer: attributes_for(:answer) }
      end

      include_examples 'redirects to', :questions_path
      include_examples 'sets flash message', :alert, 'Question not found'
    end
  end
end
