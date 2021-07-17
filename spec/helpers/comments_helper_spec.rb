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
    end

    context "when is collapsed and is for commentable of a different user than current user" do
      before do
        article.update(user: other_user)
      end

      it "is hidden" do
        expect(helper.should_be_hidden?(comment, root_comment, current_user)).to be true
      end
    end
  end

  describe "#tree_for" do
    context "when comment is hidden by commentable user" do
      it "returns blank when no current_user" do
        expect(helper.tree_for(comment, [], article, nil)).to be_empty
      end

      it "returns blank when current_user is not the commentable user" do
        expect(helper.tree_for(comment, [], article, other_user)).to be_empty
      end

      it "is not empty when current_user is the commentable user but has hidden-by-commentable-user class" do
        comment_tree = helper.tree_for(comment, [], article, current_user)
        expect(comment_tree).not_to be_empty
        expect(comment_tree).to include("hidden-by-commentable-user")
      end
    end

    context "when comment not hidden by commentable user" do
      before do
        comment.update(hidden_by_commentable_user: false)
      end

      it "is not empty" do
        comment_tree = helper.tree_for(comment, [], article, current_user)
        expect(comment_tree).not_to be_empty
        expect(comment_tree).to exclude("hidden-by-commentable-user")
      end
    end
  end
end
