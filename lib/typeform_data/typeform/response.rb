# frozen_string_literal: true
module TypeformData
  class Typeform

    class Response
      attr_reader :token
      attr_reader :metadata
      attr_reader :hidden
      attr_reader :typeform_id
      attr_reader :answers

      # It's correct to name this attribute "completed?" and not "complete?" since it's always in
      # the past tense-- once a potential respondent leaves a Typeform unsubmitted, they can never
      # go back and complete it.
      def completed?
        @completed == 1
      end

      alias hidden_fields hidden

      # TODO: make sure this works:
      def date_submitted
        DateTime.strptime(metadata['date_submit'], '%Y-%m-%d %H:%M:%S')
      end

      # rubocop: disable Metrics/ParameterLists
      def initialize(typeform, token:, metadata:, hidden:, completed:, answers:)
        @typeform_id = typeform.id
        @token = token
        @metadata = metadata
        @hidden = hidden
        @completed = completed
        @answers = answers.map { |id, value|
          matching_field = typeform.fields.find { |field| field.id.to_s == id.split('_')[1] }
          raise UnexpectedError, 'Expected to find a matching field' unless matching_field

          ::TypeformData::Typeform::Answer.new(
            typeform,
            id: id,
            value: value,
            field_text: matching_field.text
          )
        }
      end
      # rubocop: enable Metrics/ParameterLists

      def self.from_hash(typeform, hash)
        new(
          typeform,
          token: hash['token'],
          metadata: hash['metadata'],
          hidden: hash['hidden'],
          completed: hash['completed'],
          answers: hash['answers'],
        )
      end

    end

  end
end
