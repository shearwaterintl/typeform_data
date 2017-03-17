# frozen_string_literal: true
$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'typeform_data'

require 'minitest/autorun'
require 'flexmock/minitest'

require 'pry'

class TypeformDataTest < Minitest::Test

  def typeform_mock_and_client_for(typeform_id, json)
    client = TypeformData::Client.new(api_key: 'test-api-key')
    typeform = client.typeform(typeform_id)

    mock = flexmock(
      'TypeformData::Client',
      get: flexmock('Net::HTTP response', parsed_json: json)
    )

    [typeform, mock, client]
  end

end

# Extend from this class when you want to run assertions against this library's handling of a
# specific, mocked JSON response from Typeform containing responses to a particular Typeform.
# See json_one_test.rb for an example.
#
# Subclasses should declare:
#
#   def test_object_graph
#     assert_object_graph
#     assert_that_our_api_key_is_not_serialized
#   end
#
# To run assertions defined here. Given time constraints, I can't figure out right now how to set
# up a test that doesn't run in this class, but runs in every subclass. Would love some help on
# this!
class ObjectGraphTest < TypeformDataTest

  # Implement this method to return the JSON response you want to test against. The JSON should
  # match what you can, in practice, get from the /form endpoint of the actual API.
  # def json
  # end

  def assert_that_our_api_key_is_not_serialized
    typeform, mock, client = typeform_mock_and_client_for('test-id', json)

    typeform.stub :client, mock do
      # This call will initialize questions and stats on the Typeform, as a side-effect.
      responses = typeform.responses

      # We aren't using TypeformData here, since we'd like to make sure that Marshal.dump still
      # doesn't expose credentials, in case it's used instead of TypeformData::Client#dump.
      dumped = Marshal.dump(responses)

      loaded_with_marshal = Marshal.load(dumped)
      assert_nil loaded_with_marshal.first.send(:config)

      loaded = client.load(dumped)
      refute_nil loaded.first.send(:config)
    end
  end

  def mocks
    typeform, mock = typeform_mock_and_client_for('test-id', json)

    typeform.stub :client, mock do
      return [typeform, typeform.responses]
    end
  end

  def typeform
    typeform_mock_and_client_for('test-id', json)[0]
  end

  def json_field_ids
    non_hidden_non_statement_questions_json = json['questions'].select do |hash|
      !hash['id'].start_with?('hidden') && !hash['id'].start_with?('statement')
    end

    non_hidden_non_statement_questions_json.map { |hash| hash['field_id'] }.uniq.sort
  end

  # rubocop:disable Metrics/AbcSize
  def assert_object_graph
    typeform, mock = typeform_mock_and_client_for('test-id', json)

    typeform.stub :client, mock do
      # This call with initialized questions and stats on the Typeform, as a side-effect.
      responses = typeform.responses
      assert_equal json_field_ids, typeform.fields.map(&:id).sort

      question_ids = json['questions'].map { |hash| hash['id'] }.sort
      assert_equal question_ids, typeform.questions.map(&:id).sort

      question_texts = json['questions'].map { |hash| hash['question'] }.sort
      assert_equal question_texts, typeform.questions.map(&:text).sort

      assert_equal typeform.stats.showing, json['stats']['responses']['showing']
      assert_equal typeform.stats.total, json['stats']['responses']['total']
      assert_equal typeform.stats.completed, json['stats']['responses']['completed']

      # Make sure we can sort each type without errors:
      responses.sort
      responses.sample.answers.sort
      typeform.questions.sort
      typeform.fields.sort
    end
  end
  # rubocop:enable Metrics/AbcSize

end
