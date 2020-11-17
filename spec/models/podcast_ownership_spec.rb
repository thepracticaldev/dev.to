require "rails_helper"

RSpec.describe PodcastOwnership, type: :model do
  let(:podcast_ownership) { create(:podcast_ownership) }

  describe "validations" do
    it { is_expected.to belong_to(:owner).class_name("User").with_foreign_key(:user_id).inverse_of(:podcasts_owned) }
    it { is_expected.to belong_to(:podcast) }

    it { is_expected.to validate_presence_of(:podcast_id) }
    it { is_expected.to validate_presence_of(:user_id) }
    it { is_expected.to validate_uniqueness_of(:podcast_id).scoped_to(:user_id) }
  end
end
