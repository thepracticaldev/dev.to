require "rails_helper"

RSpec.describe "Hiding A Comment", type: :system, js: true do
  let(:user) { create(:user) }
  let(:some_user) { create(:user) }
  let!(:article) { create(:article, show_comments: true, user: user) }
  let!(:comment) do
    create(:comment,
           commentable: article,
           user: some_user,
           body_markdown: Faker::Lorem.paragraph)
  end

  before do
    sign_in user
  end

  context "when user hides comment on their own article" do
    it "refreshes the page and collapses the comment" do
      visit article.path.to_s
      wait_for_javascript

      within("#comment-node-#{comment.id}") do
        click_on(class: "comment__dropdown-trigger")
        accept_confirm do
          click_link("Hide")
        end
      end
      wait_for_javascript
      expect(page).to have_css("span.js-collapse-comment-content", text: some_user.name)
    end
  end
end
