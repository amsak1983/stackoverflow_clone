require 'rails_helper'

RSpec.shared_context "policy context" do
  let(:user) { create(:user) }
  let(:admin) { create(:user, admin: true) }
  let(:other_user) { create(:user) }
end

# Custom matcher for Pundit policies
RSpec::Matchers.define :permit_action do |action|
  match do |policy|
    policy.public_send("#{action}?")
  end

  failure_message do |policy|
    "#{policy.class} does not permit #{action} for #{policy.user.inspect} on #{policy.record.inspect}."
  end

  failure_message_when_negated do |policy|
    "#{policy.class} does not forbid #{action} for #{policy.user.inspect} on #{policy.record.inspect}."
  end
end

RSpec.shared_examples "permits action" do |action|
  it "permits #{action}" do
    expect(subject).to permit_action(action)
  end
end

RSpec.shared_examples "denies action" do |action|
  it "denies #{action}" do
    expect(subject).not_to permit_action(action)
  end
end

RSpec.configure do |config|
  config.include_context "policy context", type: :policy
end
