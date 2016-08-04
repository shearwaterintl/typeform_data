# frozen_string_literal: true
module TypeformData
  class Typeform

    class Question
      include TypeformData::ValueClass
      include TypeformData::Typeform::ById
      include TypeformData::ComparableByIdAndConfig

      # A question ID is of the form:
      #   - opinionscale_20576123
      #   - listimage_46576029_choice_26422755
      #
      # It looks like the second part of the ID is the field ID, but the Data API includes
      # 'field_id' as a separate property in the response JSON, so I'm not sure if we can treat
      # them as the same.
      #
      readable_attributes :id, :question, :field_id, :typeform_id

      # Question#question makes for a bad API. Ideally, use Question#text instead.
      alias text question

      def type
        id.split('_').first
      end

      def hidden_field?
        type == 'hidden'
      end

      # The Data API includes 'statements' as part of a Typeform's "questions", despite the fact
      # that these statements don't have associated answers.
      def statement?
        type == 'statement'
      end
    end

  end
end
