require 'rails_helper'

RSpec.describe AnswersController, type: :controller do
  let(:question) { Question.create(title: 'Test question', body: 'Test body') }

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves a new answer in the database' do
        expect { post :create, params: { question_id: question, answer: { body: 'Test answer' } } }.to change(question.answers, :count).by(1)
      end

      it 'redirects to question show view' do
        post :create, params: { question_id: question, answer: { body: 'Test answer' } }
        expect(response).to redirect_to question_path(question)
      end
    end

    context 'with invalid attributes' do
      it 'does not save the answer' do
        expect { post :create, params: { question_id: question, answer: { body: nil } } }.to_not change(Answer, :count)
      end

      it 're-renders question show view' do
        post :create, params: { question_id: question, answer: { body: nil } }
        expect(response).to render_template 'questions/show'
      end
    end
  end
end
