# frozen_string_literal: true

require "rails_helper"

RSpec.describe User, type: :model do
  describe ".search_simple" do
    let(:query) { "john" }

    it "returns none when query is blank" do
      expect(described_class.search_simple("").records).to eq([])
    end

    it "delegates to __elasticsearch__.search with multi_match on email and name" do
      es = double("ESResult", records: [])
      expect(described_class.__elasticsearch__).to receive(:search).with(
        hash_including(
          query: hash_including(
            multi_match: hash_including(
              query: query,
              fields: %w[email name]
            )
          )
        )
      ).and_return(es)

      expect(described_class.search_simple(query).records).to eq([])
    end
  end
end
