# frozen_string_literal: true
module TypeformData
  class Requestor

    class Config
      attr_reader :api_key

      def initialize(api_key:)
        @api_key = api_key
      end

      # These values were determined via URI.parse('https://api.typeform.com')

      def host
        'api.typeform.com'
      end

      def port
        443
      end

      def api_version
        1
      end

    end

  end
end
