# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'typeform_data_client/version'

Gem::Specification.new do |spec|
  spec.name          = 'typeform_data_client'
  spec.version       = TypeformDataClient::VERSION
  spec.authors       = ['Max Wallace']
  spec.email         = ['maxfield.wallace@gmail.com']

  spec.summary       = 'An opinionated client for the Typeform.com Data API'
  spec.description   = "typeform_data_client is a minimal, opinionated client for the Typeform.com Data API (see https://www.typeform.com/help/data-api/). The goal of this project is to create a maintainable, extensible client that provides a more natural object-oriented interface to Typeform.com's Data API."
  spec.homepage      = 'https://github.com/maxkwallace/typeform_data_client'
  spec.license       = 'MIT'

  # Prevent pushing this gem to RubyGems.org. To allow pushes either set the 'allowed_push_host'
  # to allow pushing to a single host or delete this section to allow pushing to any host.
  if spec.respond_to?(:metadata)
    spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"
  else
    raise 'RubyGems 2.0 or newer is required to protect against public gem pushes.'
  end

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
end
