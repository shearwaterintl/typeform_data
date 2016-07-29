# frozen_string_literal: true
require 'typeform_data/version'

module TypeformData
  class Client

    def initialize(api_key:)
      @_requestor = ::TypeformData::Requestor.new(api_key: api_key)
    end

    def all_typeforms
      get('forms').parsed_json.map do |form_hash|
        ::TypeformData::Typeform.new(self, form_hash)
      end
    end

    def typeform(id)
      ::TypeformData::Typeform.new(self, id)
    end

    # Your API key will automatically be added to the request URL as a query param, as required by
    # the API.
    #
    # @param String
    # @param Hash
    # @return TypeformData::ApiResponse
    def get(endpoint, params = {})
      @_requestor.get(endpoint, params)
    end

  end
end
