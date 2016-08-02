# frozen_string_literal: true
module TypeformData
  class Typeform

    class Question
      include TypeformData::ValueClass
      include TypeformData::Typeform::ById
      readable_attributes :id, :question, :field_id, :typeform_id

      # Question#question makes for a bad API. Ideally, use Question#text instead.
      alias text question

      def hidden_field?
        id.split('_').first == 'hidden'
      end

      # The Data API includes 'statements' as part of a Typeform's "questions", despite the fact
      # that these statements don't have associated answers.
      def statement?
        id.split('_').first == 'statement'
      end
    end

  end
end
