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
        mapped_attrs[:answers] = Answer.from_response_attrs(config, attrs, fields)
        mapped_attrs.delete('answers')
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
