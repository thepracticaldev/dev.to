module CommentsHelper
  MAX_COMMENTS_TO_RENDER = 250
  MIN_COMMENTS_TO_RENDER = 8

  def comment_class(comment, is_view_root: false)
    if comment.root? || is_view_root
      "root"
    else
      "child"
    end
  end

  def comment_user_id_unless_deleted(comment)
    comment.deleted ? 0 : comment.user_id
  end

  def commentable_author_is_op?(commentable, comment)
    commentable &&
      [
        commentable.user_id,
        commentable.co_author_ids,
      ].flatten.any?(comment.user_id)
  end

  def get_ama_or_op_banner(commentable)
    commentable.decorate.cached_tag_list_array.include?("ama") ? "Ask Me Anything" : "Author"
  end

  def tree_for(comment, sub_comments, commentable, current_user)
    nested_comments(tree: { comment => sub_comments },
                    commentable: commentable,
                    is_view_root: true,
                    current_user: current_user)
  end

  def should_be_hidden?(comment, root_comment, current_user)
    commentable = comment.commentable
    has_commentable_of_current_user = [commentable.user_id, commentable.co_author_ids].flatten.any?(current_user&.id)
    should_be_collapsed?(comment, root_comment) && !has_commentable_of_current_user
  end

  def should_be_collapsed?(comment, root_comment)
    comment.hidden_by_commentable_user && comment != root_comment
  end

  def high_number_of_comments?(comments_number)
    comments_number > MAX_COMMENTS_TO_RENDER
  end

  def view_all_comments?(comments_number)
    comments_number > MIN_COMMENTS_TO_RENDER
  end

  def number_of_comments_to_render
    MAX_COMMENTS_TO_RENDER
  end

  def comment_count(view)
    view == "comments" ? MAX_COMMENTS_TO_RENDER : MIN_COMMENTS_TO_RENDER
  end

  def like_button_text(comment)
    case comment.public_reactions_count
    when 0
      "Like"
    when 1
      "&nbsp;like"
    else
      "&nbsp;likes"
    end
  end

  private

  def nested_comments(tree:, commentable:, current_user:, is_view_root: false)
    comments = tree.map do |comment, sub_comments|
      render("comments/comment", comment: comment, commentable: commentable,
                                 is_view_root: is_view_root, is_childless: sub_comments.empty?,
                                 subtree_html: nested_comments(tree: sub_comments,
                                                               commentable: commentable,
                                                               current_user: current_user),
                                 current_user: current_user)
    end

    safe_join(comments)
  end
end
