# frozen_string_literal: true

module TypeformData
  class Requestor

    def initialize(api_key:)
      @config = ::TypeformData::Requestor::Config.new(api_key: api_key)
    end

    def get(endpoint, params = nil)
      request(Net::HTTP::Get, request_path(endpoint), params)
    end

    private

    def request_path(endpoint)
      "/v#{@config.api_version}/#{endpoint}"
    end

    # rubocop:disable Metrics/MethodLength
    def request(method_class, path, input_params = {})
      params = input_params.dup
      params[:key] = @config.api_key

      response = Net::HTTP.new(@config.host, @config.port).tap { |http|
        http.use_ssl = true
        http.set_debug_output($stdout)
      }.request(
        method_class.new(
          path + '?' + URI.encode_www_form(params),
          'Content-Type' => 'application/json'
        )
      )

      case response
      when Net::HTTPNotFound then
        raise TypeformDataClient::InvalidEndpoint, path
      when Net::HTTPForbidden then
        raise TypeformDataClient::InvalidApiKey, "Invalid api key: #{@config.api_key}"
      when Net::HTTPBadRequest then
        raise TypeformDataClient::BadRequest, 'There was an error processing your request: '\
          "#{response.body}, with params: #{params}"
      when Net::HTTPSuccess
        return TypeformData::Response.new(response)
      else
        raise TypeformDataClient::UnexpectedError, "A #{response.code} error has occurred: "\
          "'#{response.message}'"
      end

    rescue Errno::ECONNREFUSED
      raise TypeformDataClient::ConnectionRefused, 'The connection was refused'
    end
    # rubocop:enable Metrics/MethodLength

  end
end
