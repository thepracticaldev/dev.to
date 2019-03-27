require "rails_helper"

RSpec.describe Identity, type: :model do
  it { is_expected.to belong_to(:user) }
  it { is_expected.to validate_presence_of(:uid) }
  it { is_expected.to validate_presence_of(:provider) }
  it { is_expected.to validate_uniqueness_of(:uid).scoped_to(:provider) }
  # it { is_expected.to validate_uniqueness_of(:provider).scoped_to(:uid) }
  it { is_expected.to validate_uniqueness_of(:user_id).scoped_to(:provider) }
  it { is_expected.to validate_inclusion_of(:provider).in_array(%w[github twitter]) }
  it { is_expected.to serialize(:auth_data_dump) }

  describe ".find_for_oauth" do
    it "works" do
      allow(Identity).to receive(:find_or_create_by)
      auth = { uid: 0, provider: "github" }
      described_class.find_for_oauth(instance_double("request", auth))
      expect(Identity).to have_received(:find_or_create_by).with(auth)
    end
  end

  context "when a new record" do
    it "validates uniqueness of provider + uid" do
      create(:identity, provider: "twitter", uid: 100, user: create(:user))
      identity = build(:identity, provider: "twitter", uid: 100, user: create(:user))
      expect(identity).not_to be_valid
      expect(identity.errors[:uid].size).to eq(1)
    end

    it "validates uniqueness of provider + user_id" do
      user = create(:user)
      create(:identity, provider: "twitter", uid: 100, user: user)
      identity = build(:identity, provider: "twitter", uid: 11, user: user)
      expect(identity).not_to be_valid
      expect(identity.errors[:user_id].size).to eq(1)
    end
  end
end
