module Constants
  module Role
    BASE_ROLES = %w[
      Warn
      Comment Suspend
      Suspend
      Regular Member
      Trusted
      Pro
    ].freeze

    SPECIAL_ROLES = %w[
      Admin
      Tech Admin
      Super Admin
      Resource Admin: Article
      Resource Admin: BadgeAchievement
      Resource Admin: Badge
      Resource Admin: Broadcast
      Resource Admin: BufferUpdate
      Resource Admin: ChatChannel
      Resource Admin: Comment
      Resource Admin: Config
      Resource Admin: DisplayAd
      Resource Admin: DataUpdateScript
      Resource Admin: FeedbackMessage
      Resource Admin: HtmlVariant
      Resource Admin: ListingCategory
      Resource Admin: Page
      Resource Admin: Tag
    ].freeze
  end
end
