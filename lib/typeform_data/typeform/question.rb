# frozen_string_literal: true
module TypeformData
  class Typeform

    class Question
      attr_reader :id
      attr_reader :question
      attr_reader :field_id

      def initialize(typeform, id:, question:, field_id:)
        @typeform = typeform
        @id = id
        @question = question
        @field_id = field_id
      end

      def self.from_hash(typeform, hash)
        new(
          typeform,
          id: hash['id'],
          question: hash['question'],
          field_id: hash['field_id'],
        )
      end
    end

  end
end
