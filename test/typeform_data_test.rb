# frozen_string_literal: true
require 'test_helper'

TEST_JSON = JSON.parse(<<-TEST_JSON_STRING
{
  "http_status": 200,
  "stats": {
    "responses": {
      "showing": 3,
      "total": 3,
      "completed": 2
    }
  },
  "questions": [
    {
      "id": "yesno_20576020",
      "question": "Do you like ice cream?",
      "field_id": 20576020
    },
    {
      "id": "textfield_20576021",
      "question": "Could you share more?",
      "field_id": 20576021
    },
    {
      "id": "number_20576025",
      "question": "What's your favorite number?",
      "field_id": 20576025
    },
    {
      "id": "opinionscale_20576026",
      "question": "...and your opinion of this form?",
      "field_id": 20576026
    },
    {
      "id": "listimage_20576029_choice_26422262",
      "question": "Shared question",
      "field_id": 20576029
    },
    {
      "id": "listimage_20576029_choice_26422263",
      "question": "Shared question",
      "field_id": 20576029
    },
    {
      "id": "listimage_20576029_choice_26422264",
      "question": "Shared question",
      "field_id": 20576029
    },
    {
      "id": "hidden_email",
      "question": "email",
      "field_id": 105139
    }
  ],
  "responses": [
    {
      "completed": "1",
      "token": "581eec6b27c23dc70e047e435494sdff",
      "metadata": {
        "browser": "default",
        "platform": "other",
        "date_land": "2016-06-08 16:36:58",
        "date_submit": "2016-06-08 16:37:29",
        "user_agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
      },
      "hidden": {
        "email": "one@example.com"
      },
      "answers": {
        "yesno_20576020": "1",
        "textfield_20576021": "",
        "number_20576025": "45",
        "opinionscale_20576026": "6",
        "listimage_20576029_choice_26422262": "An answer",
        "listimage_20576029_choice_26422263": "",
        "listimage_20576029_choice_26422264": "Another answer"
      }
    },
    {
      "completed": "1",
      "token": "fb8a2e464d2b2cd24145sfu154538f7f",
      "metadata": {
        "browser": "default",
        "platform": "other",
        "date_land": "2016-06-08 16:36:58",
        "date_submit": "2016-06-08 16:37:29",
        "user_agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
      },
      "hidden": {
        "email": "two@example.com"
      },
      "answers": {
        "yesno_20576020": "0",
        "textfield_20576021": "A lot of text",
        "number_20576025": "35",
        "opinionscale_20576026": "6",
        "listimage_20576029_choice_26422262": "",
        "listimage_20576029_choice_26422263": "",
        "listimage_20576029_choice_26422264": "Another answer"
      }
    },
    {
      "completed": "0",
      "token": "67shr97affhbdc40dd850909fb17b304",
      "metadata": {
        "browser": "default",
        "platform": "other",
        "date_land": "2016-06-08 16:36:58",
        "date_submit": "2016-06-08 16:37:29",
        "user_agent": "Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/50.0.2661.102 Safari/537.36"
      },
      "hidden": {
        "email": "three@example.com"
      },
      "answers": {
        "yesno_20576020": "1",
        "textfield_20576021": "Other text",
        "number_20576025": "4598",
        "opinionscale_20576026": "2",
        "listimage_20576029_choice_26422262": "An answer",
        "listimage_20576029_choice_26422263": "",
        "listimage_20576029_choice_26422264": "Another answer"
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
    typeform, mock = typeform_and_mock

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
        assert_equal response.answers.length, field_ids.length
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
    typeform, mock = typeform_and_mock

    typeform.stub :client, mock do
      # This call with initialized questions and stats on the Typeform, as a side-effect.
      responses = typeform.responses
      config = responses.first.send(:config)

      # We aren't using TypeformData here, since we'd like to make sure that Marshal.dump still
      # doesn't expose credentials, in case it's used accidentally.
      dumped = Marshal.dump(responses)

      loaded_with_marshal = Marshal.load(dumped)
      assert_nil loaded_with_marshal.first.send(:config)

      loaded = TypeformData.load(dumped, config)
      refute_nil loaded.first.send(:config)
    end
  end

  def typeform_and_mock
    client = TypeformData::Client.new(api_key: 'test-api-key')
    typeform = client.typeform('test-typeform-id')

    mock = flexmock(
      'TypeformData::Client',
      get: flexmock('Net::HTTP response', parsed_json: TEST_JSON)
    )

    [typeform, mock]
  end

end
