namespace :fastly do
  desc "Update VCL for whitelisted params on Fastly"
  task update_whitelisted_params: :environment do
    fastly_credentials = %w[
      FASTLY_API_KEY
      FASTLY_SERVICE_ID
      WHITELIST_PARAMS_SNIPPET_NAME
    ]

    if fastly_credentials.any? { |cred| ApplicationConfig[cred].blank? }
      puts "Fastly not configured. Please set FASTLY_API_KEY, FASTLY_SERVICE_ID, WHITELIST_PARAMS_SNIPPET_NAME in your environment."
      exit
    end

    FastlyVCL::WhitelistedParams.update
  end
end
