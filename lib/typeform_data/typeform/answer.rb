# frozen_string_literal: true
module TypeformData
  class Typeform

    class Answer
      include TypeformData::ValueClass
      include TypeformData::Typeform::ById

      # field_text may be removed in the future: we may want to normalize our data model. For
      # now, it's quite convenient to have.
      readable_attributes :id, :value, :field_text, :response_token, :typeform_id

      # IDs are of the form:
      #
      # - "textfield_12316024"
      # - "listimage_12316029_choice_12322262"
      #
      # This list may not be exhaustive-- there may be other ID formats not covererd above-- since
      # this part of the API isn't mentioned in the documentation.
      def field_id
        id.split('_')[1]
      end

      def question_type
        id.split('_').first
      end

      # TODO: this is not working-- Typeform is giving us back a 404. Perhaps it's an encoding
      # issue with the token?
      # def response
      #   typeform.responses(token: response_token)
      # end

      # Use this method to create Answers when initializing a Response.
      # @return [Array<Answer>]
      def self.from_response_attrs(config, attrs, fields)
        (attrs[:answers] || attrs['answers']).group_by { |id, _value|
          field_id = id.split('_')[1]

          unless field_id && field_id.length.positive?
            raise UnexpectedError, 'Falsy field ID for answer(s)'
          end

          fields.find { |field| field.id.to_s == field_id }.tap { |matched|
            raise UnexpectedError, 'Expected to find a matching field' unless matched
          }
        }.map { |field, ids_and_values|
          values = ids_and_values.map(&:last)

          Answer.new(
            config,
            id: field.id,
            value: values.one? ? values.first : values
            field_text: field.text,
            response_token: attrs[:token] || attrs['token'],
            typeform_id: attrs[:typeform_id] || attrs['typeform_id'],
          )
        }
      end

    end

  end
end
