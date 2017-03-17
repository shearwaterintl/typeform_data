# frozen_string_literal: true
require 'test_helper'

TEST_JSON_ONE = JSON.parse(<<-TEST_JSON_STRING_ONE
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
TEST_JSON_STRING_ONE
)

class JsonOneTest < ObjectGraphTest

  def json
    TEST_JSON_ONE
  end

  def test_object_graph
    assert_object_graph
    assert_that_our_api_key_is_not_serialized
  end

  def test_responses
    typeform, responses = mocks

    responses.each do |response|
      assert_equal response.answers.length, json_field_ids.length
      assert_equal response.answers.map(&:field_text).uniq.sort, typeform.fields.map(&:text).sort
    end
  end

end
