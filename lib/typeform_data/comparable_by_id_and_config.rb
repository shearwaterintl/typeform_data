# frozen_string_literal: true
module TypeformData
  module ComparableByIdAndConfig
    include Comparable

    # Override this method to specify a different key.
    def sort_key
      id
    end

    def ==(other)
      unless other.respond_to?(:sort_key, true) && other.respond_to?(:config, true)
        raise TypeformData::ArgumentError, "#{other.inspect} does not specify a sort key and config"
      end
      other.sort_key == sort_key && other.config == config
    end

    def <=>(other)
      unless other.respond_to?(:sort_key)
        raise TypeformData::ArgumentError, "#{other.inspect} does not specify a sort key"
      end
      other.sort_key <=> sort_key
    end

  end
end
