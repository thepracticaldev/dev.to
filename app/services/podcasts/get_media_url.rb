module Podcasts
  class GetMediaUrl
    def initialize(enclosure_url)
      @enclosure_url = enclosure_url.to_s.downcase
    end

    def self.call(*args)
      new(*args).call
    end

    def call
      was_http = !enclosure_url.starts_with?("https")
      https_url = enclosure_url.sub(/http:/, "https:")

      # check https url first
      if url_reachable?(https_url)
        reachable = true
        url = https_url
      # if https is unreachable, check http url (if it was provided)
      else
        reachable = was_http ? url_reachable?(enclosure_url) : false
        url = enclosure_url
      end
      result_sctruct.new(https: url.starts_with?("https"), reachable: reachable, url: url)
    end

    private

    attr_reader :enclosure_url

    def result_sctruct
      Struct.new(:https, :reachable, :url, keyword_init: true)
    end

    def url_reachable?(url)
      HTTParty.head(url).code == 200
    rescue Net::OpenTimeout, Errno::ECONNREFUSED
      false
    end
  end
end
