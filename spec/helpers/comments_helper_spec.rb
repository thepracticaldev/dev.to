require "rails_helper"

describe CommentsHelper, type: :helper do
  let(:current_user) { create(:user) }
  let(:other_user) { create(:user) }
  let(:article) { create(:article, user: current_user) }
  let!(:comment) { create(:comment, commentable: article, hidden_by_commentable_user: true) }
  let!(:root_comment) { create(:comment, commentable: article) }

  describe "#should_be_collapsed?" do
    context "when hidden by commentable user and not root comment" do
      it "is collapsed" do
        expect(helper.should_be_collapsed?(comment, root_comment)).to be true
      end
    end

    context "when hidden by commentable user but is root comment" do
      it "is not collapsed" do
        expect(helper.should_be_collapsed?(comment, comment)).to be false
      end
    end

    context "when not hidden by commentable user" do
      before do
        comment.update(hidden_by_commentable_user: false)
      end

      it "is not collapsed" do
        expect(helper.should_be_collapsed?(comment, root_comment)).to be false
      end
    end
  end

  describe "#should_be_hidden?" do
    context "when is not collapsed" do
      before do
        comment.update(hidden_by_commentable_user: false)
      end

      it "is not hidden" do
        expect(helper.should_be_hidden?(comment, root_comment, current_user)).to be false
      end
    end

    context "when is collapsed" do
      it "is hidden when no current_user present" do
        expect(helper.should_be_hidden?(comment, root_comment, nil)).to be true
      end

      it "is not hidden when commentable of current_user present" do
        expect(helper.should_be_hidden?(comment, root_comment, current_user)).to be false
      end

      it "is hidden when commentable of a different user than current_user" do
        article.update(user: other_user)
        expect(helper.should_be_hidden?(comment, root_comment, current_user)).to be true
        article.update(user: current_user)
      end
    end
  end
end
