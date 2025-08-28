require 'rails_helper'
require_relative '../policy_spec_helper'

RSpec.describe ActiveStorage::AttachmentPolicy, type: :policy do
  subject { described_class.new(user, attachment) }

  let(:question) { create(:question) }
  let(:attachment) { instance_double(ActiveStorage::Attachment) }
  let(:record) { question }

  before do
    allow(attachment).to receive(:record).and_return(record)
  end

  context "for a visitor" do
    let(:user) { nil }

    it_behaves_like "denies action", :destroy
  end

  context "for a user who doesn't own the attached record" do
    let(:user) { create(:user) }

    it_behaves_like "denies action", :destroy
  end

  context "for the author of the attached record" do
    let(:user) { question.user }

    it_behaves_like "permits action", :destroy
  end
end
