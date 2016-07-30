# frozen_string_literal: true
module TypeformData
  class Typeform

    class Question
      attr_reader :id
      attr_reader :question
      attr_reader :field_id
      attr_reader :typeform_id

      # Question#question makes for a bad API. Ideally, use Question#text instead.
      alias_method :text, :question

      def hidden_field?
        id.split('_').first == 'hidden'
      end

      # The Data API includes 'statements' as part of a Typeform's "questions", despite the fact
      # that these statements don't have associated answers.
      def statement?
        id.split('_').first == 'statement'
      end

      def initialize(typeform, id:, question:, field_id:)
        @typeform_id = typeform.id
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
