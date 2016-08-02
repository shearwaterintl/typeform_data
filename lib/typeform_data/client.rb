# frozen_string_literal: true
require 'typeform_data/version'

module TypeformData
  class Client

    # For the sake of usability, we're breaking convention here and accepting an API key as the
    # first parameter instead of an instance of TypeformData::Config.
    def initialize(api_key:)
      @config = TypeformData::Config.new(api_key: api_key)
    end

    def self.new_from_config(config)
      raise ArgumentError, 'Missing config' unless config
      new(api_key: config.api_key)
    end

    # Your API key will automatically be added to the request URL as a query param, as required by
    # the API.
    #
    # @param String
    # @param Hash
    # @return TypeformData::ApiResponse
    def get(endpoint, params = {})
      TypeformData::Requestor.get(@config, endpoint, params)
    end

    def all_typeforms
      get('forms').parsed_json.map do |form_hash|
        ::TypeformData::Typeform.new(@config, form_hash)
      end
    end

    def typeform(id)
      ::TypeformData::Typeform.new(@config, id: id)
    end

  end
end
