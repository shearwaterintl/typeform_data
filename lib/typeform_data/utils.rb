module Utils

  # Repeats the block until it succeeds or a limit is reached, waiting twice as long as it
  # previously did after each failure.
  # @param rescued_exceptions [Class] Subclasses of Exception.
  # @param max_retries [Integer]
  # @param initial_wait [Integer] In seconds.
  def self.retry_with_exponential_backoff(rescued_exceptions, max_retries: 5, initial_wait: 1)
    seconds_to_wait = initial_wait

    max_retries.times do |iteration|
      begin
        break yield
      rescue *rescued_exceptions => error
        sleep seconds_to_wait
        seconds_to_wait *= 2

        raise if iteration == max_retries - 1
      end
    end
  end

end
