# frozen_string_literal: true

# As the code says, we're using a simple decorator/delegator here to signal intent to possibly
# modify the TypeformData::Response API.
module TypeformData
  class Response < SimpleDelegator

    def json
      @_parsed_json ||= JSON.parse(body)
    end

  end
end
