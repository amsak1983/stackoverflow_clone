require 'rails_helper'
require_relative 'policy_spec_helper'

RSpec.describe ApplicationPolicy, type: :policy do
  subject { described_class.new(user, record) }

  let(:record) { Object.new }

  context "for a visitor" do
    let(:user) { nil }

    it_behaves_like "denies action", :index
    it_behaves_like "denies action", :show
    it_behaves_like "denies action", :create
    it_behaves_like "denies action", :new
    it_behaves_like "denies action", :update
    it_behaves_like "denies action", :edit
    it_behaves_like "denies action", :destroy
  end

  context "for a user" do
    let(:user) { create(:user) }

    it_behaves_like "denies action", :index
    it_behaves_like "denies action", :show
    it_behaves_like "denies action", :create
    it_behaves_like "denies action", :new
    it_behaves_like "denies action", :update
    it_behaves_like "denies action", :edit
    it_behaves_like "denies action", :destroy
  end

  describe "Scope" do
    let(:user) { create(:user) }
    let(:scope) { double("scope") }

    it "has a resolve method that should be implemented by subclasses" do
      scope_class = described_class::Scope.new(user, scope)
      expect { scope_class.resolve }.to raise_error(NotImplementedError, /You must define #resolve/)
    end
  end
end
