# frozen_string_literal: true
module TypeformData
  class Typeform

    module ById
      def typeform
        raise UnexpectedError, 'Expected a defined typeform_id' unless typeform_id
        client.typeform(typeform_id)
      end
    end

  end
end
