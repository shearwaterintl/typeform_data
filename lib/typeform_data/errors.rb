# frozen_string_literal: true
module TypeformDataClient
  class Error < StandardError; end
  class InvalidEndpoint < Error; end
  class InvalidApiKey < Error; end
  class ConnectionRefused < Error; end
  class BadRequest < Error; end
  class UnexpectedError < Error; end
end
