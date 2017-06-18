# frozen_string_literal: true
require 'typeform_data/version'

module TypeformData
  class Client

    # For the sake of usability, we're breaking convention here and accepting an API key as the
    # first parameter instead of an instance of TypeformData::Config.
    # @param api_key [String]
    # @param logger [Object] Should implement the same API as
    # https://ruby-doc.org/stdlib-2.1.0/libdoc/logger/rdoc/Logger.html)
    def initialize(api_key:, logger: nil)
      @config = TypeformData::Config.new(api_key: api_key, logger: logger)
    end

    def self.new_from_config(config)
      raise TypeformData::ArgumentError, 'Missing config' unless config
      new(api_key: config.api_key, logger: config.logger)
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

    # The goals of this alias are:
    #   1. To bring the serialization process within TypeformData's API, so
    #        we can modify it in the future if needed.
    #   2. Maintain symmetry with #load, which needs to be part of the API.
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

    def marshal_dump
      raise 'Do not serialize TypeformData::Client-- it contains your API key'
    end

    def as_json(*_args)
      raise 'Do not serialize TypeformData::Client-- it contains your API key'
    end

  end
end
