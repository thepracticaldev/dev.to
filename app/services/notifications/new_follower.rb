# send notifications about the new followers
module Notifications
  class NewFollower
    # @param follow_data [Hash]
    #   * :followable_id [Integer]
    #   * :followable_type [String] - "User" or "Organization"
    #   * :follower_id [Integer] - user id
    def initialize(follow_data, is_read = false)
      @followable_id = follow_data.fetch(:followable_id)
      @followable_type = follow_data.fetch(:followable_type)
      @follower_id = follow_data.fetch(:follower_id)
      @is_read = is_read
    end

    def self.call(*args)
      new(*args).call
    end

    def call
      recent_follows = Follow.where(followable_type: followable_type, followable_id: followable_id).
        where("created_at > ?", 24.hours.ago).order("created_at DESC")

      notification_params = { action: "Follow" }
      if followable_type == "User"
        notification_params[:user_id] = followable_id
      elsif followable_type == "Organization"
        notification_params[:organization_id] = followable_id
      end

      followers = User.where(id: recent_follows.pluck(:follower_id))
      aggregated_siblings = followers.map { |f| user_data(f) }
      if aggregated_siblings.size.zero?
        notification = Notification.find_by(notification_params)&.destroy
      else
        json_data = { user: user_data(follower), aggregated_siblings: aggregated_siblings }
        notification = Notification.find_or_create_by(notification_params)
        notification.notifiable_id = recent_follows.first.id
        notification.notifiable_type = "Follow"
        notification.json_data = json_data
        notification.notified_at = Time.current
        notification.read = is_read
        notification.save!
      end
      notification
    end

    private

    attr_reader :followable_id, :followable_type, :follower_id, :is_read

    def follower
      User.find(follower_id)
    end

    def user_data(user)
      {
        id: user.id,
        class: { name: "User" },
        name: user.name,
        username: user.username,
        path: user.path,
        profile_image_90: user.profile_image_90,
        comments_count: user.comments_count,
        created_at: user.created_at
      }
    end
  end
end
