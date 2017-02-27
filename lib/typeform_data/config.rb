# frozen_string_literal: true
require 'logger'

module TypeformData
  class Config
    attr_reader :api_key
    attr_reader :logger

    def initialize(api_key:, logger: nil)
      unless api_key.is_a?(String) && api_key.length.positive?
        raise TypeformData::ArgumentError, 'An API key (as a nonempty String) is required'
      end
      @api_key = api_key
      @logger = logger || Logger.new($stdout)
    end

    # These values were determined via URI.parse('https://api.typeform.com').

    def host
      'api.typeform.com'
    end

    def port
      443
    end

    def api_version
      1
    end

    def ==(other)
      other.api_key == api_key
    end

  end
end
