# frozen_string_literal: true
module TypeformData
  class Typeform

    class Stats
      attr_reader :showing
      attr_reader :total
      attr_reader :completed

      def initialize(showing:, total:, completed:)
        @showing = showing
        @total = total
        @completed = completed
      end

      def self.from_stats_hash(stats_hash)
        new(
          showing: stats_hash['showing'],
          total: stats_hash['total'],
          completed: stats_hash['completed'],
        )
      end
    end

  end
end
