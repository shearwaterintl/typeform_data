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
      raise TypeformData::ArgumentError, 'Missing config' unless config
      new(api_key: config.api_key)
    end

    # Your API key will automatically be added to the request URL as a query param, as required by
    # the API.
    #
    # @param [String]
    # @param [Hash]
    # @return [TypeformData::ApiResponse]
    def get(endpoint, params = {})
      TypeformData::Requestor.get(@config, endpoint, params)
    end

    def all_typeforms
      get('forms').parsed_json.map do |form_hash|
        TypeformData::Typeform.new(@config, form_hash)
      end
    end

    def typeform(id)
      TypeformData::Typeform.new(@config, id: id)
    end

    def dump(object)
      Marshal.dump(object)
    end

    # @param serialized [String] The output of Marshal.dump(vci) where vci is either (1) an
    #   instance of TypeformData::ValueClass or (2) an array of instances of
    #   TypeformData::ValueClass.
    # @param default [Object] What to return if 'serialized' is blank or not a String.
    def load(serialized, default = nil)
      return default unless serialized.is_a?(String) && !serialized.empty?

      Marshal.load(serialized).tap { |marshaled|
        case marshaled
        when Array
          marshaled.each { |object| object.reconfig(@config) }
        else
          marshaled.reconfig(@config)
        end
      }
    end

  end
end
