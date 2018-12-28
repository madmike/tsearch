require 'rest-client'
require 'json'

module TSearch
  class Client
    @base_url = nil
    @login_token = nil

    def self.connect(options)
      options = {
        url: 'http://localhost:11988/api',
        login: nil
      }.merge(options)

      @base_url = URI(options[:url])
      @login_token ||= login(options[:login]) unless options[:login].nil?
    end

    def self.get(action, params = {})
      begin
        status = Timeout::timeout(5) {
          uri = @base_url.merge(action)
          JSON.parse(RestClient.get(uri.to_s, {params: params}.merge(default_params)))
        }
      rescue Exception => e
        Rails.logger.warn e.message
        Object.new
      end
    end

    def self.post(action, params = {})
      begin
        status = Timeout::timeout(5) {
          uri = @base_url.merge(action)
          JSON.parse(RestClient.post(uri.to_s, params.to_json, default_params))
        }
      rescue Exception => e
        Rails.logger.warn e.message
        Object.new
      end
    end

    def self.put(action, params = {})
      begin
        status = Timeout::timeout(5) {
          uri = @base_url.merge(action)
          JSON.parse(RestClient.put(uri.to_s, params.to_json, default_params))
        }
      rescue Exception => e
        Rails.logger.warn e.message
        Object.new
      end
    end

    def self.delete(action)
      begin
        status = Timeout::timeout(5) {
          uri = @base_url.merge(action)
          JSON.parse(RestClient.delete(uri.to_s, default_params))
        }
      rescue Exception => e
        Rails.logger.warn e.message
      end
    end

  private
    def self.default_params
      @options ||= {content_type: :json, accept: :json, verify: OpenSSL::SSL::VERIFY_NONE}
    end
  end
end
