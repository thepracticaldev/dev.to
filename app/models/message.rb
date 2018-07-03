class Message < ApplicationRecord
  belongs_to :user
  belongs_to :chat_channel

  validates :message_html, presence: true
  validates :message_markdown, presence: true, length: { maximum: 600 }
  validate :channel_permission

  before_save       :determine_user_validity
  before_validation :evaluate_markdown
  after_create      :update_chat_channel_last_message_at
  after_create      :update_all_has_unopened_messages_statuses

  def preferred_user_color
    color_options = [user.bg_color_hex || "#000000", user.text_color_hex || "#000000"]
    HexComparer.new(color_options).brightness(0.9)
  end

  def determine_user_validity
    raise unless chat_channel.status == "active" && (chat_channel.has_member?(user) || chat_channel.channel_type == "open")
  end

  def send_push
    reciever_ids = chat_channel.chat_channel_memberships.
      where.not(user_id: user.id).pluck(:user_id)
    PushNotificationSubscription.where(user_id: reciever_ids).each do |sub|
      return if should_send_push?(sub)
      Webpush.payload_send(
        endpoint: sub.endpoint,
        message: ActionView::Base.full_sanitizer.sanitize(message_html),
        p256dh: sub.p256dh_key,
        auth: sub.auth_key,
        ttl: 24 * 60 * 60,
        vapid: {
            subject: "https://dev.to",
            public_key: ENV["VAPID_PUBLIC_KEY"],
            private_key: ENV["VAPID_PRIVATE_KEY"],
      })
    end
  end

  private

  def update_chat_channel_last_message_at
    chat_channel.touch(:last_message_at)
    chat_channel.index!
    chat_channel.delay.index!
  end

  def update_all_has_unopened_messages_statuses
    chat_channel.
      chat_channel_memberships.
      where("last_opened_at < ?", 4.seconds.ago).
      where.
      not(user_id: user_id).
      update_all(has_unopened_messages: true)
  end

  def evaluate_markdown
    self.message_html = MarkdownParser.new(message_markdown).evaluate_inline_markdown
  end

  def channel_permission
    if chat_channel_id.blank?
      errors.add(:base, "Must be part of channel.")
    end
    channel = ChatChannel.find(chat_channel_id)
    return if channel.channel_type == "open"
    if channel.has_member?(user)
      # this is fine
    else
      errors.add(:base, "You are not a participant of this chat channel.")
    end
  end

  def should_send_push?(sub)
    membership = sub.user.chat_channel_memberships.order("last_opened_at DESC").first
    membership.last_opened_at > 40.seconds.ago
  end
end
