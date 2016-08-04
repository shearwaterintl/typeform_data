# frozen_string_literal: true
module TypeformData
  module ComparableByIdAndConfig
    include Comparable

    # Override this method to specify a different key.
    def sort_key
      id
    end

    def ==(other)
      other.sort_key == sort_key && other.config == config
    end

    def <=>(other)
      other.sort_key <=> sort_key
    end

  end
end
