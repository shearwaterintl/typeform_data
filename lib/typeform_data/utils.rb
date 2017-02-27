# frozen_string_literal: true
module Utils

  # Repeats the block until it succeeds or a limit is reached, waiting twice as long as it
  # previously did after each failure.
  # @param [Class] Subclasses of Exception.
  # @param [Integer]
  # @param [Integer] In seconds.
  def self.retry_with_exponential_backoff(rescued_exceptions, max_retries: 5, initial_wait: 1)
    seconds_to_wait = initial_wait

    max_retries.times do |iteration|
      begin
        break yield
      rescue *rescued_exceptions
        sleep seconds_to_wait
        seconds_to_wait *= 2

        raise if iteration == max_retries - 1
      end
    end
  end

end
