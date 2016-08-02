# frozen_string_literal: true
module TypeformData
  class Typeform

    class Response
      include TypeformData::ValueClass
      include TypeformData::Typeform::ById
      readable_attributes :token, :metadata, :hidden, :typeform_id, :answers, :completed

      # It's correct to name this attribute "completed?" and not "complete?" since it's always in
      # the past tense-- once a potential respondent leaves a Typeform unsubmitted, they can never
      # go back and complete it.
      def completed?
        @completed == 1
      end

      alias hidden_fields hidden

      def date_submitted
        DateTime.strptime(metadata['date_submit'], '%Y-%m-%d %H:%M:%S')
      end

      def initialize(config, attrs, fields)
        mapped_attrs = attrs.dup

        mapped_attrs[:answers] = (attrs[:answers] || attrs['answers']).map { |id, value|
          matching_field = fields.find { |field| field.id.to_s == id.split('_')[1] }
          raise UnexpectedError, 'Expected to find a matching field' unless matching_field

          Answer.new(
            config,
            id: id,
            value: value,
            field_text: matching_field.text,
            response_token: attrs[:token] || attrs['token'],
            typeform_id: attrs[:typeform_id] || attrs['typeform_id'],
          )
        }.group_by(:field_id).map { |field_id, answers|
          unless field_id && field_id.length.positive?
            raise UnexpectedError, 'Falsy field ID for answer(s)'
          end
          return answers.first if answers.length == 1

          Answer.new(
            config,
            id:
            # Add other coalescing here...
          )
        }

        super(config, mapped_attrs)
      end

      def reconfig(config)
        @config = config
        answers.each { |answer| answer.config = config }
      end

      def ==(other)
        other.token == token && other.config == config
      end

    end

  end
end
