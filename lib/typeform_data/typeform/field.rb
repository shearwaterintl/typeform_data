# frozen_string_literal: true
module TypeformData
  class Typeform

    class Field
      attr_reader :id
      attr_reader :text
      attr_reader :typeform_id
      attr_reader :question_ids

      # The Data API includes 'statements' as part of a Typeform's "questions", despite the fact
      # that these statements don't have associated answers.
      def statement?
        id.split('_').first == 'statement'
      end

      def initialize(typeform, id:, text:, question_ids:)
        @typeform_id = typeform.id
        @id = id
        @text = text
        @question_ids = question_ids
      end

      def self.from_questions(typeform, questions)
        questions.group_by(&:field_id).map do |field_id, questions|
          unless questions.map(&:text).uniq.length == 1
            raise UnexpectedError, 'Expected question text to be the same based on field_id'
          end

          new(
            typeform,
            id: field_id,
            text: questions.first.text,
            question_ids: questions.map(&:id),
          )
        end
      end

    end

  end
end
