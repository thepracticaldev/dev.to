module Admin
  class BadgeAchievementsController < Admin::ApplicationController
    layout "admin"

    def index
      @q = BadgeAchievement
        .includes(:badge)
        .includes(:user)
        .order(created_at: :desc)
        .ransack(params[:q])
      @badge_achievements = @q.result.page(params[:page] || 1).per(15)
    end

    def destroy
      @badge_achievement = BadgeAchievement.find(params[:id])

      if @badge_achievement.destroy
        flash[:success] = "Badge achievement has been deleted!"
      else
        flash[:danger] = @badge_achievement.errors_as_sentence
      end
      if FeatureFlag.enabled?(:admin_restructure)
        redirect_to admin_content_manager_badge_achievements_path
      else
        redirect_to admin_badge_achievements_path
      end
    end

    def award
      @all_badges = Badge.all.select(:title, :slug)
    end

    def award_badges
      raise ArgumentError, "Please choose a badge to award" if permitted_params[:badge].blank?

      usernames = permitted_params[:usernames].downcase.split(/\s*,\s*/)
      message = permitted_params[:message_markdown].presence || "Congrats!"
      BadgeAchievements::BadgeAwardWorker.perform_async(usernames, permitted_params[:badge], message)

      flash[:success] = "Badges are being rewarded. The task will finish shortly."
      if FeatureFlag.enabled?(:admin_restructure)
        redirect_to admin_content_manager_badge_achievements_path
      else
        redirect_to admin_badge_achievements_path
      end
    rescue ArgumentError => e
      flash[:danger] = e.message
      if FeatureFlag.enabled?(:admin_restructure)
        redirect_to admin_content_manager_badge_achievements_path
      else
        redirect_to admin_badge_achievements_path
      end
    end

    private

    def permitted_params
      params.permit(:usernames, :badge, :message_markdown)
    end
  end
end
