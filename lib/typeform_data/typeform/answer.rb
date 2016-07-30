# frozen_string_literal: true
module TypeformData
  class Typeform

    class Answer
      attr_reader :id
      attr_reader :value
      attr_reader :typeform_id

      # IDs are of the form:
      #
      # - "textfield_12316024"
      # - "listimage_12316029_choice_12322262"
      #
      # This list may not be exhaustive-- there may be other ID formats not covererd above-- since
      # this part of the API isn't mentioned in the documentation.
      def question_field_id
        id.split('_')[1]
      end

      def question_type
        id.split('_').first
      end

      # This attribute may be removed in the future: we may want to normalize our data model. For
      # now, it's quite convenient to have.
      attr_reader :field_text

      def initialize(typeform, id:, value:, :field_text)
        @typeform_id = typeform.id
        @id = id
        @value = value
        @field_text = field_text
      end

      def self.from_hash(typeform, hash)
        new(
          typeform,
          id: hash['id'],
          value: hash['value'],
          field_text: hash['field_text'],
        )
      end
    end

  end
end
