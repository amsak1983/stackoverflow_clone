require 'rails_helper'
require_relative 'policy_spec_helper'

RSpec.describe RewardPolicy, type: :policy do
  subject { described_class.new(user, reward) }

  let(:question) { create(:question) }
  let(:reward) { create(:reward, question: question) }

  context "for a visitor" do
    let(:user) { nil }

    it_behaves_like "denies action", :index
  end

  context "for an authenticated user" do
    let(:user) { create(:user) }

    it_behaves_like "permits action", :index
  end
end
