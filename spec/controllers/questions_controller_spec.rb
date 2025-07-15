require 'rails_helper'

RSpec.describe QuestionsController, type: :controller do
  describe 'GET #new' do
    before { get :new }

    it 'returns http success' do
      expect(response).to have_http_status(:success)
    end

    it 'assigns a new Question to @question' do
      expect(assigns(:question)).to be_a_new(Question)
    end

    it 'renders new view' do
      expect(response).to render_template :new
    end
  end

  describe 'POST #create' do
    context 'with valid attributes' do
      it 'saves a new question in the database' do
        expect { post :create, params: { question: { title: 'Test question', body: 'Test body' } } }.to change(Question, :count).by(1)
      end

      it 'redirects to show view' do
        post :create, params: { question: { title: 'Test question', body: 'Test body' } }
        expect(response).to redirect_to question_path(assigns(:question))
      end
    end

    context 'with invalid attributes' do
      it 'does not save the question' do
        expect { post :create, params: { question: { title: nil, body: nil } } }.to_not change(Question, :count)
      end

      it 're-renders new view' do
        post :create, params: { question: { title: nil, body: nil } }
        expect(response).to render_template :new
      end
    end
  end

  describe 'GET #show' do
    let(:question) { Question.create(title: 'Test question', body: 'Test body') }

    before { get :show, params: { id: question } }

    it 'assigns the requested question to @question' do
      expect(assigns(:question)).to eq question
    end

    it 'renders show view' do
      expect(response).to render_template :show
    end
  end
end
