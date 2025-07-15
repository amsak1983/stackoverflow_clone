require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  let(:question) { create(:question) }

  describe 'GET #new' do
    before { get :new }

    include_examples 'request status', :success
    include_examples 'renders template', :new

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      let(:valid_params) { { question: attributes_for(:question) } }

      it 'saves a new question in the database' do
        expect { post :create, params: valid_params }.to change(Question, :count).by(1)
      end

      context 'after request' do
        before { post :create, params: valid_params }

        it 'redirects to show view' do
          expect(response).to redirect_to question_path(assigns(:question))
        end

        include_examples 'sets flash message', :notice, 'Вопрос успешно создан'
      end
    end

    context 'with invalid attributes' do
      let(:invalid_params) { { question: attributes_for(:question, title: nil, body: nil) } }

      it 'does not save the question' do
        expect { post :create, params: invalid_params }.to_not change(Question, :count)
      end

      context 'after request' do
        before { post :create, params: invalid_params }

        include_examples 'renders template', :new
        include_examples 'request status', :unprocessable_entity
      end
    end
  end

  describe 'GET #show' do
    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'assigns a new answer to @answer' do
      expect(assigns(:answer)).to be_a_new(Answer)
    end

    it 'assigns answers collection ordered by newest first' do
      expect(assigns(:answers)).to eq question.answers.newest_first
    end

    include_examples 'renders template', :show
  end

  describe 'error handling' do
    context 'when question not found' do
      before { get :show, params: { id: 999 } }

      include_examples 'redirects to', :questions_path
      include_examples 'sets flash message', :alert, 'Вопрос не найден'
    end
  end
end
