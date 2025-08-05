require 'rails_helper'

RSpec.describe "Rewards", type: :request do
  let(:user) { create(:user) }
  
  describe "GET /rewards" do
    context "when user is authenticated" do
      before { sign_in user }
      
      it "returns http success" do
        get rewards_path
        expect(response).to have_http_status(:success)
      end
      
      it "renders the index template" do
        get rewards_path
        expect(response).to render_template(:index)
      end
    end
    
    context "when user is not authenticated" do
      it "redirects to sign in" do
        get rewards_path
        expect(response).to redirect_to(new_user_session_path)
      end
    end
  end
end
