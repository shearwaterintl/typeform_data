# frozen_string_literal: true
require 'typeform_data/utils'

module TypeformData
  module Requestor

    RETRY_EXCEPTIONS = [
      # We wouldn't ordinarily retry in this case, but Typeform appears to have transient issues
      # with their SSL.
      OpenSSL::SSL::SSLError,

      Errno::ECONNREFUSED,
      TypeformData::TransientResponseError,

      # Sometimes it takes a while before Typeform's state becomes consistent. In particular, this
      # can be an issue if you receive a webhook for a form response, then immediately request that
      # response from Typeform's servers.
      TypeformData::InvalidEndpointOrMissingResource
    ].freeze

    RETRY_RESPONSE_CLASSES = [
      Net::HTTPServiceUnavailable,
      Net::HTTPTooManyRequests,
      Net::HTTPBadGateway,
    ].freeze

    def self.get(config, endpoint, params = nil)
      request(config, Net::HTTP::Get, request_path(config, endpoint), params)
    end

    private_class_method def self.request_path(config, endpoint)
      "/v#{config.api_version}/#{endpoint}"
    end

    # @raise TypeformData::Error
    # @return TypeformData::ApiResponse
    private_class_method def self.request(config, method_class, path, input_params = {})
      params = input_params.dup
      params[:key] = config.api_key

      begin
        Utils.retry_with_exponential_backoff(RETRY_EXCEPTIONS, max_retries: 3) do
          request_and_validate_response(config, method_class, path, params)
        end
      rescue *RETRY_EXCEPTIONS => error
        raise UnexpectedHttpError, 'Unexpected HTTP error (retried 3 times): ' +
                                   TypeformData::Errors.stringify_error(error)
      end
    end

    # @return TypeformData::ApiResponse
    private_class_method def self.request_and_validate_response(config, method_class, path, params)
      response = request_response(config, method_class, path, params)

      case response
      when Net::HTTPSuccess
        return TypeformData::ApiResponse.new(response)

      when Net::HTTPNotFound
        raise TypeformData::InvalidEndpointOrMissingResource, path
      when Net::HTTPForbidden
        raise TypeformData::InvalidApiKey, "Invalid api key: #{config.api_key}"
      when Net::HTTPBadRequest
        raise TypeformData::BadRequest, 'Response was a Net::HTTPBadRequest with body: '\
          "#{response.body}. Your request with params: #{params} could not be processed."
      when *RETRY_RESPONSE_CLASSES
        raise TypeformData::TransientResponseError, "Response was a #{response.class} "\
          "(code #{response.code}) with message #{response.message}"
      else
        raise TypeformData::UnexpectedHttpResponse, 'Unexpected HTTP response with code: '\
          "#{response.code} and message: #{response.message}"
      end
    end

    private_class_method def self.request_response(config, method_class, path, params)
      Net::HTTP.new(config.host, config.port).tap { |http|
        http.use_ssl = true

        # Uncomment this line for debugging:
        # http.set_debug_output($stdout)
      }.request(
        method_class.new(
          path + '?' + URI.encode_www_form(params),
          'Content-Type' => 'application/json'
        )
      )
    rescue *RETRY_EXCEPTIONS
      raise # So retry_with_exponential_backoff can catch the exception and retry.

    # Why are we rescuing StandardError? See http://stackoverflow.com/a/11802674/1067145
    rescue StandardError => error
      raise UnexpectedHttpError, 'Unexpected HTTP error: ' +
                                 TypeformData::Errors.stringify_error(error)
    end

  end
end
