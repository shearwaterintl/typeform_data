# frozen_string_literal: true
require 'test_helper'

TEST_JSON = JSON.parse(<<-TEST_JSON_STRING
{
  "http_status": 200,
  "stats": {
    "responses": {
      "showing": 4,
      "total": 4,
      "completed": 4
    }
  },
  "questions": [
    {
      "id": "list_s9XJ_choice_V0ry",
      "question": "Required: What type of group is your organization?",
      "field_id": 45281507
    },
    {
      "id": "list_s9XJ_choice_asCn",
      "question": "Required: What type of group is your organization?",
      "field_id": 45281507
    },
    {
      "id": "list_s9XJ_choice_aS3W",
      "question": "Required: What type of group is your organization?",
      "field_id": 45281507
    },
    {
      "id": "list_s9XJ_other",
      "question": "Required: What type of group is your organization?",
      "field_id": 45281507
    },
    {
      "id": "list_45281545_choice_57415657",
      "question": "Non-Required: What type of group is your organization?",
      "field_id": 45281545
    },
    {
      "id": "list_45281545_choice_57415658",
      "question": "Non-Required: What type of group is your organization?",
      "field_id": 45281545
    },
    {
      "id": "list_45281545_choice_57415659",
      "question": "Non-Required: What type of group is your organization?",
      "field_id": 45281545
    },
    {
      "id": "list_45281545_other",
      "question": "Non-Required: What type of group is your organization?",
      "field_id": 45281545
    }
  ],
  "responses": [
    {
      "completed": "1",
      "token": "22b6616eac4f3a26a7d4490d879c3cf0",
      "metadata": {
        "browser": "default",
        "platform": "other",
        "date_land": "2017-03-08 20:38:36",
        "date_submit": "2017-03-08 20:39:33",
        "user_agent": "Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/56.0.2924.87 Safari\/537.36",
        "referer": "https:\/\/devteam4.typeform.com\/to\/HEv9qr",
        "network_id": "94c4386d47"
      },
      "hidden": [

      ],
      "answers": {
        "list_s9XJ_choice_V0ry": "RSO",
        "list_s9XJ_choice_asCn": "Student Government"
      }
    },
    {
      "completed": "1",
      "token": "a89344df85f5412275ca23035da95dad",
      "metadata": {
        "browser": "default",
        "platform": "other",
        "date_land": "2017-03-08 20:40:09",
        "date_submit": "2017-03-08 20:40:22",
        "user_agent": "Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/56.0.2924.87 Safari\/537.36",
        "referer": "https:\/\/devteam4.typeform.com\/to\/HEv9qr",
        "network_id": "94c4386d47"
      },
      "hidden": [

      ],
      "answers": {
        "list_s9XJ_choice_V0ry": "RSO",
        "list_s9XJ_choice_aS3W": "University Department or Program",
        "list_s9XJ_other": "Other Test"
      }
    },
    {
      "completed": "1",
      "token": "b508fe9762ab6f93efad190e1e890870",
      "metadata": {
        "browser": "default",
        "platform": "other",
        "date_land": "2017-03-08 20:41:07",
        "date_submit": "2017-03-08 20:41:16",
        "user_agent": "Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/56.0.2924.87 Safari\/537.36",
        "referer": "https:\/\/devteam4.typeform.com\/to\/HEv9qr",
        "network_id": "94c4386d47"
      },
      "hidden": [

      ],
      "answers": {
        "list_s9XJ_other": "Other Test"
      }
    },
    {
      "completed": "1",
      "token": "aac0808e3c9c20edef5efc880ef86db0",
      "metadata": {
        "browser": "default",
        "platform": "other",
        "date_land": "2017-03-08 20:42:02",
        "date_submit": "2017-03-08 20:42:50",
        "user_agent": "Mozilla\/5.0 (Macintosh; Intel Mac OS X 10_11_6) AppleWebKit\/537.36 (KHTML, like Gecko) Chrome\/56.0.2924.87 Safari\/537.36",
        "referer": "https:\/\/devteam4.typeform.com\/to\/HEv9qr",
        "network_id": "94c4386d47"
      },
      "hidden": [

      ],
      "answers": {
        "list_s9XJ_choice_V0ry": "RSO",
        "list_s9XJ_choice_asCn": "Student Government",
        "list_s9XJ_other": "I chose A and B, but also want other",
        "list_45281545_other": "This one definitely has an other"
      }
    }
  ]
}
TEST_JSON_STRING
)

class TypeformDataTest < Minitest::Test

  def test_that_it_has_a_version_number
    refute_nil ::TypeformData::VERSION
  end

  # rubocop:disable Metrics/AbcSize
  def test_the_object_graph
    typeform, mock = typeform_mock_and_client

    typeform.stub :client, mock do
      # This call with initialized questions and stats on the Typeform, as a side-effect.
      responses = typeform.responses

      non_hidden_non_statement_questions_json = TEST_JSON['questions'].select do |hash|
        !hash['id'].start_with?('hidden') && !hash['id'].start_with?('statement')
      end

      field_ids = non_hidden_non_statement_questions_json.map { |hash| hash['field_id'] }.uniq.sort
      assert_equal field_ids, typeform.fields.map(&:id).sort

      question_ids = TEST_JSON['questions'].map { |hash| hash['id'] }.sort
      assert_equal question_ids, typeform.questions.map(&:id).sort

      question_texts = TEST_JSON['questions'].map { |hash| hash['question'] }.sort
      assert_equal question_texts, typeform.questions.map(&:text).sort

      assert_equal typeform.stats.showing, TEST_JSON['stats']['responses']['showing']
      assert_equal typeform.stats.total, TEST_JSON['stats']['responses']['total']
      assert_equal typeform.stats.completed, TEST_JSON['stats']['responses']['completed']

      responses.each do |response|
        # assert_equal response.answers.length, field_ids.length
        assert_equal response.answers.map(&:field_text).uniq.sort, typeform.fields.map(&:text).sort
      end

      # Make sure we can sort each type without errors:
      responses.sort
      responses.sample.answers.sort
      typeform.questions.sort
      typeform.fields.sort
    end
  end
  # rubocop:enable Metrics/AbcSize

  def test_that_our_api_key_is_not_serialized
    typeform, mock, client = typeform_mock_and_client

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

  def typeform_mock_and_client
    client = TypeformData::Client.new(api_key: 'test-api-key')
    typeform = client.typeform('test-typeform-id')

    mock = flexmock(
      'TypeformData::Client',
      get: flexmock('Net::HTTP response', parsed_json: TEST_JSON)
    )

    [typeform, mock, client]
  end

end
