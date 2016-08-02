# frozen_string_literal: true
module TypeformData
  class Typeform

    class Stats
      include TypeformData::ValueClass
      readable_attributes :showing, :total, :completed
    end

  end
end
