# frozen_string_literal: true
require 'typeform_data/version'

module TypeformData
  class Client

    def initialize(api_key:)
      @_requestor = ::TypeformData::Requestor.new(api_key: api_key)
    end

    def all_typeforms
      get('forms')
    end

    private

    # @return TypeformData::Response
    def get(endpoint, params = {})
      @_requestor.get(endpoint, params)
    end

  end
end
