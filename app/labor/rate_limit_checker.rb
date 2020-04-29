class RateLimitChecker
  attr_reader :user, :action

  RETRY_AFTER = {
    article_update: 30,
    image_upload: 30,
    published_article_creation: 30,
    organization_creation: 300
  }.with_indifferent_access.freeze

  CONFIG_LIMIT_KEYS = %i[
    rate_limit_follow_count_daily
    rate_limit_comment_creation
    rate_limit_published_article_creation
    rate_limit_image_upload
    rate_limit_email_recipient
  ].freeze

  def initialize(user = nil)
    @user = user
  end

  class LimitReached < StandardError
    attr_reader :retry_after

    def initialize(retry_after)
      @retry_after = retry_after
    end

    def message
      "Rate limit reached, try again in #{retry_after} seconds"
    end
  end

  class UploadRateLimitReached < LimitReached; end

  def limit_by_action(action)
    check_method = "check_#{action}_limit"
    result = respond_to?(check_method, true) ? send(check_method) : false

    if result
      @action = action

      Slack::Messengers::RateLimit.call(user: user, action: action)
    end
    result
  end

  def track_image_uploads
    expires_in = RETRY_AFTER[:image_upload].seconds
    Rails.cache.increment("#{@user.id}_image_upload", 1, expires_in: expires_in)
  end

  def track_article_updates
    expires_in = RETRY_AFTER[:article_update].seconds
    Rails.cache.increment("#{@user.id}_article_update", 1, expires_in: expires_in)
  end

  def limit_by_email_recipient_address(address)
    # This is related to the recipient, not the "user" initiator, like in action.
    EmailMessage.where(to: address).where("sent_at > ?", 2.minutes.ago).size >
      SiteConfig.rate_limit_email_recipient
  end

  def track_organization_creation
    expires_in = RETRY_AFTER[:organization_creation].seconds
    Rails.cache.increment("#{@user.id}_organization_creation", 1, expires_in: expires_in)
  end

  private

  def check_comment_creation_limit
    user.comments.where("created_at > ?", 30.seconds.ago).size >
      SiteConfig.rate_limit_comment_creation
  end

  def check_published_article_creation_limit
    user.articles.published.where("created_at > ?", 30.seconds.ago).size >
      SiteConfig.rate_limit_published_article_creation
  end

  def check_organization_creation_limit
    Rails.cache.read("#{user.id}_organization_creation").to_i >=
      SiteConfig.rate_limit_organization_creation
  end

  def check_image_upload_limit
    Rails.cache.read("#{user.id}_image_upload").to_i >
      SiteConfig.rate_limit_image_upload
  end

  def check_article_update_limit
    Rails.cache.read("#{user.id}_article_update").to_i >
      SiteConfig.rate_limit_article_update
  end

  def check_follow_account_limit
    user_today_follow_count > SiteConfig.rate_limit_follow_count_daily
  end

  def user_today_follow_count
    following_users_count = user.following_users_count
    return following_users_count if following_users_count < SiteConfig.rate_limit_follow_count_daily

    now = Time.zone.now
    user.follows.where(created_at: (now.beginning_of_day..now)).size
  end
end
