# frozen_string_literal: true
module TypeformData

  class Error < StandardError; end

  class ArgumentError < Error; end

  class InvalidApiKey < Error; end

  class UnexpectedError < Error; end

  class UnexpectedHttpError < UnexpectedError; end
  class UnexpectedHttpResponse < UnexpectedHttpError; end
  class BadRequest < UnexpectedHttpResponse; end
  class TransientResponseError < UnexpectedHttpResponse; end

  # When using the 'token' field in requests, the API may return a 404 even if the endpoint path
  # is correct.
  class InvalidEndpointOrMissingResource < Error; end

  module Errors
    def self.stringify_error(error)
      "#{error.backtrace.first}: #{error.message} (#{error.class})\n" +
        error.backtrace.drop(1).map { |line| "\t#{line}\n" }.join
    end
  end

end
