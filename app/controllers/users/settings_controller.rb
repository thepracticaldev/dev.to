module Users
  class SettingsController < ApplicationController
    ALLOWED_PARAMS = %i[id
                        config_theme
                        config_font
                        config_navbar
                        display_announcements
                        display_sponsors
                        editor_version
                        experience_level
                        feed_fetched_at
                        feed_mark_canonical
                        feed_referential_link
                        feed_url
                        inbox_guidelines
                        inbox_type
                        permit_adjacent_sponsors
                        user_id].freeze

    def update
      users_setting = Users::Setting.find(params[:id])
      tab = params["users_setting"]["tab"] || "profile"

      if users_setting.update(users_setting_params)
        import_articles_from_feed(users_setting)

        notice = "Your config has been updated. Refresh to see all changes."

        if users_setting.experience_level.present?
          cookies.permanent[:user_experience_level] =
            users_setting.experience_level.to_s
        end
        users_setting.user.touch(:profile_updated_at)
        flash[:settings_notice] = notice
      else
        Honeycomb.add_field("error", users_setting.errors.messages.reject { |_, v| v.empty? })
        Honeycomb.add_field("errored", true)
        flash[:error] = users_setting.errors.full_messages.join(", ")
      end
      redirect_to user_settings_path(tab)
    end

    private

    def import_articles_from_feed(users_setting)
      return if users_setting.feed_url.blank?

      Feeds::ImportArticlesWorker.perform_async(nil, users_setting.user_id)
    end

    def users_setting_params
      params.require(:users_setting).permit(ALLOWED_PARAMS)
    end
  end
end
