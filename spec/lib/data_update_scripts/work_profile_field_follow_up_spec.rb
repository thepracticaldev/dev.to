require "rails_helper"
require Rails.root.join(
  "lib/data_update_scripts/20210712044513_work_profile_field_follow_up.rb",
)

describe DataUpdateScripts::WorkProfileFieldFollowUp do
  it "removes the three obsolete profile fields" do
    ProfileField.find_or_create_by(attribute_name: "employer_name", label: "Employer name")
    ProfileField.find_or_create_by(attribute_name: "employer_url", label: "Employer URL")
    ProfileField.find_or_create_by(attribute_name: "employment_title", label: "Employer title")

    expect { described_class.new.run }.to change(ProfileField, :count).by(-3)
  end

  it "changes the group of the work field" do
    work_field = ProfileField.find_or_create_by(attribute_name: "work", label: "Work")
    expect { described_class.new.run }
      .to change { work_field.reload.profile_field_group }.from(nil)
  end
end
