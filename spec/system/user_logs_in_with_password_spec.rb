require "rails_helper"

RSpec.describe "Authenticating with a password" do
  let(:password) { "p4assw0rd" }
  let!(:user) { create(:user, password: password, password_confirmation: password) }

  before do
    visit sign_up_path
  end

  def submit_login_form(email, password)
    fill_in "Email", with: email
    fill_in "Password", with: password
    click_button "Log in"
  end

  context "when logging in with incorrect credentials" do
    it "displays an error when the email address is wrong" do
      submit_login_form("wrong@example.com", password)
      expect(page).to have_text("Invalid Email or password.")
    end

    it "displays an error when the password is wrong" do
      submit_login_form(user.email, "wr0ng")
      expect(page).to have_text("Invalid Email or password.")
    end

    it "displays a message when the user got locked out" do
      allow(User).to receive(:maximum_attempts).and_return(1)

      submit_login_form(user.email, "wr0ng")
      expect(page).to have_text("Your account is locked.")
    end
  end

  context "when logging in with the correct credentials" do
    it "allows the user to sign in with the correct password" do
      submit_login_form(user.email, password)
      expect(page).to have_current_path("/dashboard?signin=true")
    end
  end
end
