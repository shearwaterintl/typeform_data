# frozen_string_literal: true
require 'set'

module TypeformData
  module ValueClass

    def initialize(config, attrs)
      unless config && config.is_a?(TypeformData::Config)
        raise ArgumentError, 'Expected a TypeformData::Config instance as the first argument'
      end
      @config = config

      keys = attribute_keys

      attrs.each do |key, value|
        # Previously, we would throw an error if an unexpected attribute was present. Unfortunately,
        # this causes exceptions in production if Typeform adds new fields to their API responses.
        # We could filter the fields to the expected keys, but that defeats the purpose of having
        # the validation.
        next unless keys.include?(key) || keys.include?(key.to_sym)
        instance_variable_set("@#{key}", value)
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # @param [Array<Symbol>]
      def readable_attributes(*keys)
        @keys = Set.new(keys)

        keys.each do |key|
          attr_reader(key)
        end
      end

    end

    def marshal_dump
      # For the sake of security, we don't want to serialize our API key.
      attribute_keys.to_a.map do |key|
        [key, instance_variable_get("@#{key}")]
      end
    end

    def marshal_load(hash)
      hash.each do |key, value|
        instance_variable_set("@#{key}", value)
      end
    end

    # Compond classes (e.g. a Response which has many Answers) should use this method to re-set
    # 'config' on each child object. ValueClass#reconfig is called in TypeformData#load.
    def reconfig(config)
      self.config = config
    end

    protected

    attr_accessor :config

    def client
      TypeformData::Client.new_from_config(@config)
    end

    private

    def attribute_keys
      self.class.instance_eval { @keys } || []
    end

  end
end
