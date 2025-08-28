require 'rails_helper'
require_relative 'policy_spec_helper'

RSpec.describe LinkPolicy, type: :policy do
  subject { described_class.new(user, link) }

  let(:question) { create(:question) }
  let(:link) { create(:link, linkable: question) }

  context "for a visitor" do
    let(:user) { nil }

    it_behaves_like "denies action", :destroy
  end

  context "for a user who doesn't own the linkable" do
    let(:user) { create(:user) }

    it_behaves_like "denies action", :destroy
  end

  context "for the author of the linkable" do
    let(:user) { question.user }

    it_behaves_like "permits action", :destroy
  end
end
