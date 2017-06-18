# frozen_string_literal: true
require 'set'

module TypeformData
  module ValueClass

    def initialize(config, attrs)
      unless config && config.is_a?(TypeformData::Config)
        raise TypeformData::ArgumentError, 'Expected a TypeformData::Config instance as the first '\
          'argument'
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

    # ActiveSupport defines Object#as_json in
    # activesupport/lib/active_support/core_ext/object/json.rb which exists to separate
    # stringification from serialization logic. as_json is not core Ruby, but we implement it here
    # for compatibility with to_json when ActiveSupport is loaded.
    #
    # In addition to protection against serializing the API key, this method is needed for #to_json
    # to work at all, since the :config object contains IO objects and ActiveSupport's #as_json
    # method fails when trying to serialize IO objects. See
    # https://github.com/rails/rails/issues/26132.
    #
    # Testing this method:
    #
    #   For now, we're not including ActiveSupport as a development dependency because of the risk
    # of accidentally writing code that relies on an ActiveSupport core extension that might not
    # be present where this gem is being used.
    #
    # To test this method in the console, add
    #
    #   spec.add_development_dependency 'activesupport'
    #
    # to typeform_data.gemspec and then run something like
    #
    #  require 'active_support'; require 'active_support/json'; \
    #   c = TypeformData::Client.new(api_key: ...); \
    #   at = c.all_typeforms; tf = at.reverse.find { |t| t.stats.completed > 0 }; \
    #   tf.responses(completed: true, limit: 1).first.to_json
    #
    # using bin/console.
    #
    # One last thing: if you pass options #to_json or #as_json, Rails will use the same options for
    # all calls in the object graph, so the following behavior is expected (if counterintuitive):
    #
    #    #   response.as_json(only: 'answers')
    #   => {"answers"=>[{}, {}, {}, {}]}
    #
    # @param [Hash]
    def as_json(options = {})
      # Note: :config doesn't work here-- using the string form is mandatory.
      return super({ except: 'config' }) if options.empty?

      super(options.merge(except: ['config'] + Array(options[:except])))
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

    # Compound classes (e.g. a Response which has many Answers) should use this method to re-set
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
