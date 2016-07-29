# frozen_string_literal: true
module TypeformData
  class Typeform

    class Response
      attr_reader :typeform
      attr_reader :token
      attr_reader :metadata
      attr_reader :hidden

      def completed?
        @completed == 1
      end

      alias hidden_fields hidden

      def initialize(typeform, token:, metadata:, hidden:, completed:)
        @typeform = typeform
        @token = token
        @metadata = metadata
        @hidden = hidden
        @completed = completed
      end

      def self.from_hash(typeform, hash)
        new(
          typeform,
          token: hash['token'],
          metadata: hash['metadata'],
          hidden: hash['hidden'],
          completed: hash['completed']
        )
      end
    end

  end
end
