require "rails_helper"

RSpec.describe Search::Postgres::Username, type: :service do
  it "defines necessary constants" do
    expect(described_class::ATTRIBUTES).not_to be_nil
    expect(described_class::MAX_RESULTS).not_to be_nil
  end

  describe "::search_documents" do
    it "returns data in the expected format" do
      user = create(:user)

      result = described_class.search_documents(user.username)

      expect(result.first.keys).to match_array(
        %w[id name profile_image_90 username],
      )
    end

    it "finds a user by their username" do
      user = create(:user)

      expect(described_class.search_documents(user.username)).to be_present
    end

    it "finds a user by a partial username" do
      user = create(:user)

      expect(described_class.search_documents(user.username.first(1))).to be_present
    end

    it "finds multiple users whose names have common parts", :aggregate_failures do
      alex = create(:user, username: "alex")
      alexsmith = create(:user, username: "alexsmith")
      rhymes = create(:user, username: "rhymes")

      result = described_class.search_documents("ale")
      usernames = result.map { |r| r["username"] }

      expect(usernames).to include(alex.username)
      expect(usernames).to include(alexsmith.username)
      expect(usernames).not_to include(rhymes.username)
    end

    it "limits the number of results to the value of MAX_RESULTS" do
      max_results = 1
      stub_const("#{described_class}::MAX_RESULTS", max_results)

      alex = create(:user, username: "alex")
      alexsmith = create(:user, username: "alexsmith")

      results = described_class.search_documents("alex")

      expect(results.size).to eq(max_results)
      expect([alex.username, alexsmith.username]).to include(results.first["username"])
    end
  end
end
