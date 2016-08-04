# frozen_string_literal: true
module TypeformData
  class Typeform

    class Field
      include TypeformData::ValueClass
      include TypeformData::Typeform::ById
      include TypeformData::ComparableByIdAndConfig
      readable_attributes :id, :type, :text, :typeform_id, :question_ids

      # The Data API includes 'statements' as part of a Typeform's "questions", despite the fact
      # that these statements don't have associated answers.
      def statement?
        type == 'statement'
      end

      def self.from_questions(config, input_questions)
        input_questions.reject(
          &:hidden_field?
        ).reject(
          &:statement?
        ).group_by(&:field_id).map do |field_id, questions|
          unless 1 == questions.map(&:text).uniq.length && 1 == questions.map(&:type).uniq.length
            # TODO: turn these errors into warnings.
            raise UnexpectedError, 'Expected questions with the same field_id to have the same '\
              'type and text'
          end

          new(
            config,
            id: field_id,
            type: questions.first.type,
            text: questions.first.text,
            question_ids: questions.map(&:id),
            typeform_id: questions.first.typeform_id,
          )
        end
      end

    end

  end
end
