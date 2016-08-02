# frozen_string_literal: true
module TypeformData
  class Typeform

    class Field
      include TypeformData::ValueClass
      include TypeformData::Typeform::ById
      readable_attributes :id, :text, :typeform_id, :question_ids

      # The Data API includes 'statements' as part of a Typeform's "questions", despite the fact
      # that these statements don't have associated answers.
      def statement?
        id.split('_').first == 'statement'
      end

      def self.from_questions(config, input_questions)
        input_questions.group_by(&:field_id).map do |field_id, questions|
          unless questions.map(&:text).uniq.length == 1
            raise UnexpectedError, 'Expected question text to be the same based on field_id'
          end

          new(config, id: field_id, text: questions.first.text, question_ids: questions.map(&:id),
                      typeform_id: questions.first.typeform_id)
        end
      end

    end

  end
end
