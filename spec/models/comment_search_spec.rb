# frozen_string_literal: true

require "rails_helper"

RSpec.describe Comment, type: :model do
  describe ".search_simple" do
    let(:query) { "help" }

    it "returns none when query is blank" do
      expect(described_class.search_simple("").records).to eq([])
    end

    it "delegates to __elasticsearch__.search with match on body" do
      es = double("ESResult", records: [])
      expect(described_class.__elasticsearch__).to receive(:search).with(
        hash_including(
          query: hash_including(
            match: hash_including(
              body: query
            )
          )
        )
      ).and_return(es)

      expect(described_class.search_simple(query).records).to eq([])
    end
  end
end
