# frozen_string_literal: true
module TypeformData
  module Utils

    # Repeats the block until it succeeds or a limit is reached, waiting twice as long as it
    # previously did after each failure.
    # @param config [TypeformData::Config]
    # @param rescued_exceptions [Class] Subclasses of Exception.
    # @param max_retries [Integer]
    # @param initial_wait [Integer] In seconds.
    def self.retry_with_exponential_backoff(config, retry_exceptions, max_retries: 5,
      initial_wait: 1)

      seconds_to_wait = initial_wait

      (1..max_retries).times do |iteration|
        begin
          break yield
        rescue *retry_exceptions
          config.logger.warn <<~M
            Retry. Waiting #{seconds_to_wait}s, on retry #{iteration} of \#{max_retries}.
          M

          sleep seconds_to_wait
          seconds_to_wait *= 2

          raise if iteration == max_retries
        end
      end
    end

  end
end
