# frozen_string_literal: true
require 'typeform_data/utils'

module TypeformData
  module Requestor

    def self.get(config, endpoint, params = nil)
      request(config, Net::HTTP::Get, request_path(config, endpoint), params)
    end

    private_class_method def self.request_path(config, endpoint)
      "/v#{config.api_version}/#{endpoint}"
    end

    # rubocop:disable Metrics/MethodLength
    # @return TypeformData::ApiResponse
    private_class_method def self.request(config, method_class, path, input_params = {})
      params = input_params.dup
      params[:key] = config.api_key

      Utils.retry_with_exponential_backoff([TypeformData::UnexpectedError]) do

        response = Net::HTTP.new(config.host, config.port).tap { |http|
          http.use_ssl = true

          # Uncomment this line for debugging:
          # http.set_debug_output($stdout)
        }.request(
          method_class.new(
            path + '?' + URI.encode_www_form(params),
            'Content-Type' => 'application/json'
          )
        )

        case response
        when Net::HTTPNotFound
          raise TypeformData::InvalidEndpointOrMissingResource, path
        when Net::HTTPForbidden
          raise TypeformData::InvalidApiKey, "Invalid api key: #{config.api_key}"
        when Net::HTTPBadRequest
          raise TypeformData::BadRequest, 'There was an error processing your request: '\
            "#{response.body}, with params: #{params}"
        when Net::HTTPSuccess
          return TypeformData::ApiResponse.new(response)
        else
          raise TypeformData::UnexpectedError, "A #{response.code} error has occurred: "\
            "'#{response.message}'"
        end

      end

    rescue Errno::ECONNREFUSED
      raise TypeformData::ConnectionRefused, 'The connection was refused'
    end
    # rubocop:enable Metrics/MethodLength

  end
end
