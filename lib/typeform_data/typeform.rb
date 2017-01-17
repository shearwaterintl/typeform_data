# frozen_string_literal: true
require 'typeform_data/version'

module TypeformData

  class Typeform
    include TypeformData::ValueClass
    include TypeformData::ComparableByIdAndConfig
    readable_attributes :id, :name

    # See https://www.typeform.com/help/data-api/ under "Filtering Options" for the full list of
    # options.
    #
    # The "Ordering Options" are not yet implemented.
    #
    # In general, this method will make multiple HTTP requests to the API in order to fetch all
    # matching responses.
    #
    # Stats and questions are cached across requests. Responses aren't cached, but we plan to add
    # some form of response caching in the future.
    #
    # @param Hash<[String, Symbol], [String, Symbol]> params
    # @raise TypeformData::ArgumentError
    def responses(params = {})
      response = responses_request(collapse_and_validate_responses_params(params))
      set_stats(response['stats']['responses'])

      # It's important that we set the questions first, since the Answer constructor (called
      # inside the Response constructor) looks up and denormalizes the question text.
      set_questions(response['questions'])

      response['responses'].map { |api_hash|
        Response.new(config, api_hash.dup.tap { |hash| hash[:typeform_id] = id }, fields)
      }
    end

    # Typeform's 'question' concept (as expressed in the API) has the following disadvantages:
    #   - Each choice in a multi-select is treated as its own 'question'
    #   - Hidden Fields are included as 'questions'
    #   - Statements are included as 'questions'
    #
    # In practice, I recommend using TypeformData::Typeform#field instead, as it addresses these
    # issues. Typeform#quesions is here so you have access to the underlying data if you need it.
    #
    # @return [TypeformData::Typeform::Question]
    def questions
      @_questions ||= fetch_questions
    end

    def fields
      @_fields ||= Field.from_questions(config, questions)
    end

    def hidden_fields
      questions.select(&:hidden_field?)
    end

    def statements
      questions.select(&:statement?)
    end

    def stats
      @_stats ||= fetch_stats
    end

    # This method will make an AJAX request if this Typeform's name hasn't already been set during
    # initialization.
    # @return [String]
    def name
      @name ||= client.all_typeforms.find { |typeform| typeform.id == id }.name
    end

    private

    def fetch_questions
      questions = responses_request(limit: 1)['questions'] || []
      questions.map { |hash| Question.new(config, hash.merge!(typeform_id: id)) }
    end

    def fetch_stats
      hash = responses_request(limit: 1)['stats']['responses']
      Stats.new(config, hash)
    end

    MAX_PAGE_SIZE = 1000 # This is documented at https://www.typeform.com/help/data-api/.

    ResponsesRequest = Struct.new(:params, :response) do
      # The inverse of 'do we need at least one more request to get all the data we want?'
      # @return Boolean
      def last_request?
        params['limit'] || responses_count < MAX_PAGE_SIZE
      end

      def responses_count
        response.parsed_json['responses'].length
      end
    end

    # It looks like sometimes the Typeform API will report stats that are out-of-date relative to
    # the responses it actually returns.
    def responses_request(input_params = {})
      params = input_params.dup
      requests = [ResponsesRequest.new(params, client.get('form/' + id, params))]

      loop do
        break if requests.last.last_request?
        next_params = requests.last.params.dup
        next_params['offset'] += requests.last.responses_count
        requests << ResponsesRequest.new(next_params, client.get('form/' + id, next_params))
      end

      requests.map(&:response).map(&:parsed_json).reduce do |combined, next_set|
        next_set.dup.tap { |response|
          response['responses'] = combined['responses'] + next_set['responses']
        }
      end
    end

    # rubocop:disable Style/AccessorMethodName
    def set_questions(questions_hashes = [])
      @_questions = questions_hashes.map { |hash|
        Question.new(config, hash.merge(typeform_id: id))
      }
    end

    # @param [Hash] stats_hash of the form {"responses"=>{"showing"=>2, "total"=>2, "completed"=>0}}
    def set_stats(hash)
      @_stats = Stats.new(config, hash)
    end
    # rubocop:enable Style/AccessorMethodName

    PERMITTED_KEYS = {
      'completed' => Object,
      'since'     => Object,
      'until'     => Object,
      'offset'    => Integer,
      'limit'     => Integer,
      'token'     => String,
    }.freeze

    def collapse_and_validate_responses_params(input_params)
      params = input_params.dup

      params.keys.select { |key| key.is_a?(Symbol) }.each do |sym|
        raise ::TypeformData::ArgumentError, 'Duplicate keys' if params.key?(sym.to_s)
        params[sym.to_s] = params[sym]
        params.delete(sym)
      end

      params.keys.each do |key|
        next if PERMITTED_KEYS.key?(key) && params[key].is_a?(PERMITTED_KEYS[key])
        raise ::TypeformData::ArgumentError, "Invalid/unsupported param: #{key}"
      end

      if params['limit'] && params['limit'] > MAX_PAGE_SIZE
        raise ::TypeformData::ArgumentError, "The maximum limit is #{MAX_PAGE_SIZE}. You "\
          "provided: #{params['limit']}"
      end

      if params['token']
        if params.keys.length > 1
          raise ::TypeformData::ArgumentError, "'token' may not be combined with other filters"
        end
      else
        params['offset'] ||= 0
      end

      params
    end

  end
end
