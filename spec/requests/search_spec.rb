# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Search on homepage", type: :request do
  describe "GET /questions with search params" do
    let!(:user) { create(:user) }

    it "renders 200 without query and does not crash" do
      get questions_path
      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Questions")
    end

    it "performs questions-only search and renders found question" do
      question = create(:question, user: user, title: "Elasticsearch integration", body: "Simple guide")

      es_result = instance_double("ESResult", records: [ question ])
      expect(Question).to receive(:search_simple).with("Elastic").and_return(es_result)

      get questions_path, params: { query: "Elastic", model: "questions" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Elasticsearch integration")
      expect(response.body).to include("Question")
    end

    it "performs global search (all) and renders items from different models" do
      question = create(:question, user: user, title: "Ruby on Rails", body: "Search")
      answer   = create(:answer, user: user, question: question, body: "Use elasticsearch-model")
      comment  = create(:comment, user: user, commentable: question, body: "Nice article!")
      # user already exists

      q_res = instance_double("ESResult", records: [ question ])
      a_res = instance_double("ESResult", records: [ answer ])
      c_res = instance_double("ESResult", records: [ comment ])
      u_res = instance_double("ESResult", records: [ user ])

      expect(Question).to receive(:search_simple).and_return(q_res)
      expect(Answer).to receive(:search_simple).and_return(a_res)
      expect(Comment).to receive(:search_simple).and_return(c_res)
      expect(User).to receive(:search_simple).and_return(u_res)

      get questions_path, params: { query: "anything", model: "all" }

      expect(response).to have_http_status(:ok)
      expect(response.body).to include("Ruby on Rails")        # question title
      expect(response.body).to include("Use elasticsearch-model") # answer body snippet
      expect(response.body).to include("Nice article!")           # comment snippet
      expect(response.body).to include(user.name)                 # user name
    end
  end
end
