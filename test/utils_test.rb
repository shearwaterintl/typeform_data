# frozen_string_literal: true
require 'test_helper'
require 'typeform_data/utils'

class FakeFlakyClient
  def initialize(count)
    @count = count
  end

  def get(data)
    @count -= 1
    raise RuntimeError if @count > 0

    data
  end
end

class UtilsTest < Minitest::Test

  def test_retry_with_exponential_backoff_tries_enough
    client = FakeFlakyClient.new(4)
    Utils.stub(:sleep, 0) do
      assert_equal(
        'foo',
        Utils.retry_with_exponential_backoff([RuntimeError]) { client.get('foo') }
      )
    end
  end

  def test_retry_with_exponential_backoff_eventually_gives_up
    client = FakeFlakyClient.new(10)
    Utils.stub(:sleep, 0) do
      assert_raises RuntimeError do
        Utils.retry_with_exponential_backoff([RuntimeError]) { client.get('foo') }
      end
    end
  end

end
