require "rails_helper"

RSpec.describe "internal/organizations", type: :request do
  let(:admin) { create(:user, :super_admin) }

  before do
    create_list :organization, 5
    sign_in(admin)
  end

  describe "GETS /internal/organizations" do
    let(:organizations) { Organization.all.map { |o| CGI.escapeHTML(o.name) } }

    it "lists all organizations" do
      get "/internal/organizations"
      expect(response.body).to include(*organizations)
    end
  end

  describe "GET /internal/orgnaizations/:id" do
    let(:organization) { Organization.first }

    it "renders the correct organization" do
      get "/internal/organizations/#{organization.id}"
      expect(response.body).to include(organization.name)
    end
  end
end
