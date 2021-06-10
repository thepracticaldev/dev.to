module Settings
  class SMTP < RailsSettings::Base
    self.table_name = :settings_smtp

    OPTIONS = %i[address port authentication user_name password domain].freeze

    # The configuration is cached, change this if you want to force update
    # the cache, or call Settings::Smtp.clear_cache
    cache_prefix { "v1" }

    field :address, type: :string, default: ApplicationConfig["SMTP_ADDRESS"]
    field :authentication, type: :string, default: ApplicationConfig["SMTP_AUTHENTICATION"],
                           validates: { inclusion: %w[plain login cram_md5] }
    field :domain, type: :string, default: ApplicationConfig["SMTP_DOMAIN"]
    field :password, type: :string, default: ApplicationConfig["SMTP_PASSWORD"]
    field :port, type: :integer, default: ApplicationConfig["SMTP_PORT"] # should default to nil wtf
    field :user_name, type: :string, default: ApplicationConfig["SMTP_USER_NAME"]

    class << self
      def enabled?
        (user_name.present? && password.present?) || ApplicationConfig["SENDGRID_API_KEY"].present?
      end

      def settings
        return sendgrid_settings if ApplicationConfig["SENDGRID_API_KEY"].present?

        keys.index_with { |k| public_send(k) }.symbolize_keys
      end

      private

      def sendgrid_settings
        {
          address: "smtp.sendgrid.net",
          port: 587,
          authentication: :plain,
          user_name: "apikey",
          password: ApplicationConfig["SENDGRID_API_KEY"],
          domain: ApplicationConfig["APP_DOMAIN"]
        }
      end
    end
  end
end
