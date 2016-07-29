# frozen_string_literal: true

# As the code says, we're using a simple decorator/delegator here to signal intent to possibly
# modify the TypeformData::ApiResponse API.
module TypeformData
  class ApiResponse < SimpleDelegator

    def json
      body
    end

    def parsed_json
      @_parsed_json ||= JSON.parse(body)
    end

  end
end
