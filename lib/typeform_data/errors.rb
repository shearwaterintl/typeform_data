# frozen_string_literal: true
module TypeformData
  class Error < StandardError; end
  class InvalidApiKey < Error; end
  class ConnectionRefused < Error; end
  class BadRequest < Error; end
  class ArgumentError < Error; end
  class UnexpectedError < Error; end

  # When using the 'token' field in requests, the API may return a 404 even if the endpoint path
  # is correct.
  class InvalidEndpointOrMissingResource < Error; end
end
