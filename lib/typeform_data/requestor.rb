# frozen_string_literal: true
require 'typeform_data/utils'

module TypeformData
  module Requestor

    RETRY_EXCEPTIONS = [Net::HTTPServiceUnavailable, Errno::ECONNREFUSED].freeze

    def self.get(config, endpoint, params = nil)
      request(config, Net::HTTP::Get, request_path(config, endpoint), params)
    end

    private_class_method def self.request_path(config, endpoint)
      "/v#{config.api_version}/#{endpoint}"
    end

    # @return TypeformData::ApiResponse
    private_class_method def self.request(config, method_class, path, input_params = {})
      params = input_params.dup
      params[:key] = config.api_key

      begin
        Utils.retry_with_exponential_backoff(RETRY_EXCEPTIONS, max_retries: 3) do
          request_and_validate_response(config, method_class, path, params)
        end
      rescue *DOMAIN_EXCEPTIONS
        raise

      # Why are we rescuing StandardError? See http://stackoverflow.com/a/11802674/1067145
      rescue StandardError => error
        raise UnexpectedHttpError, 'Unexpected HTTP error: ' +
                                   TypeformData::Errors.stringify_error(error)
      end
    end

    DOMAIN_EXCEPTIONS = [
      TypeformData::InvalidEndpointOrMissingResource,
      TypeformData::InvalidApiKey,
      TypeformData::BadRequest,
      TypeformData::UnexpectedHttpResponse
    ].freeze

    # @return TypeformData::ApiResponse
    private_class_method def self.request_and_validate_response(config, method_class, path, params)
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
        raise TypeformData::BadRequest, 'Response was a Net::HTTPBadRequest with body: '\
          "#{response.body}. Your request with params: #{params} could not be processed."
      when Net::HTTPSuccess
        return TypeformData::ApiResponse.new(response)
      else
        raise TypeformData::UnexpectedHttpResponse, 'Unexpected HTTP response with code: '\
          "#{response.code} and message: #{response.message}"
      end
    end

  end
end
