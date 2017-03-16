# frozen_string_literal: true
module TypeformData
  class Typeform

    class Answer
      include TypeformData::ValueClass
      include TypeformData::Typeform::ById
      include TypeformData::ComparableByIdAndConfig

      def sort_key
        field_id
      end

      # field_text may be removed in the future: we may want to normalize our data model. For
      # now, it's quite convenient to have.
      #
      # The type of 'value' is [String, Fixnum, Array<String>, Array<Fixnum>], since we are
      # combining 'answers' from the API's JSON responses if those answers share the same field.
      readable_attributes :field_id, :value, :field_text, :response_token, :typeform_id

      def field_type
        id.split('_').first
      end

      # TODO: this is not working-- Typeform is giving us back a 404. Perhaps it's an encoding
      # issue with the token?
      # def response
      #   typeform.responses(token: response_token)
      # end

      # Use this method to create Answers when initializing a Response.
      #
      # @param config [TypeformData::Config]
      # @param attrs [Hash] Looks like:
      #   {
      #    "completed"=>"1",
      #    "token"=>"581eec6b27c23dc70e047e4354944bfb",
      #    "metadata"=>{ ... },
      #    "hidden"=>{ ... },
      #    "answers"=>
      #     {
      #      "answer_id"=>"answer_value",
      #       ...
      #     },
      #    :typeform_id=>"OTFzVb"
      #   }
      #
      # @param fields [Array<TypeformData::Typeform::Field>]
      # @return [Array<Answer>]
      def self.from_response_attrs(config, attrs, fields)
        (attrs[:answers] || attrs['answers']).group_by { |id, _value|
          matching_field_for_answer(fields, id)
        }.map { |field, ids_and_values|
          # ids_and_values looks like [[id, value], [id, value], ...]
          values = ids_and_values.map(&:last)

          Answer.new(
            config,
            field_id: field.id,
            value: values.one? ? values.first : values,
            field_text: field.text,
            response_token: attrs[:token] || attrs['token'],
            typeform_id: attrs[:typeform_id] || attrs['typeform_id'],
          )
        }
      end

      # In the JSON, answer 'ID's are of the form:
      #
      # - "textfield_12316024"
      # - "listimage_12316029_choice_12322262"
      #
      # This list may not be exhaustive-- there may be other ID formats not covererd above-- since
      # this part of the API isn't mentioned in the documentation.
      #
      private_class_method def self.matching_field_for_answer(fields, answer_id)
        found = fields.find { |field| field.question_ids.include?(answer_id) }

        unless found
          raise UnexpectedError, "Expected to find a matching field for Answer ID #{answer_id}"
        end

        found
      end

    end

  end
end
