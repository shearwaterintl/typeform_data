# frozen_string_literal: true
module TypeformData

  def self.dump(object)
    Marshal.dump(object)
  end

  # Currently only handles single objects and arrays.
  # @param [TypeformData::ValueClass]
  # @param [TypeformData::Config]
  def self.load(value_class_instance, config)
    Marshal.load(value_class_instance).tap { |marshaled|
      case marshaled
      when Array
        marshaled.each { |object| object.reconfig(config) }
      else
        marshaled.reconfig(config)
      end
    }
  end

end

require 'net/http'
require 'net/https'
require 'uri'
require 'json'

require 'typeform_data/version'
require 'typeform_data/client'
require 'typeform_data/errors'
require 'typeform_data/config'
require 'typeform_data/value_class'
require 'typeform_data/comparable_by_id_and_config'

require 'typeform_data/requestor'
require 'typeform_data/api_response'

require 'typeform_data/typeform'
require 'typeform_data/typeform/by_id'
require 'typeform_data/typeform/stats'
require 'typeform_data/typeform/response'
require 'typeform_data/typeform/question'
require 'typeform_data/typeform/answer'
require 'typeform_data/typeform/field'
