# coding: utf-8
# frozen_string_literal: true
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'typeform_data/version'

Gem::Specification.new do |spec|

  spec.name          = 'typeform_data'
  spec.version       = TypeformData::VERSION
  spec.authors       = ['Max Wallace', 'Eli Rose']
  spec.email         = ['engineering@shearwaterintl.com']

  spec.summary       = 'An opinionated, OO client for the Typeform.com Data API'
  spec.description   = 'typeform_data is a minimal, opinionated, OO client for the Typeform.com '\
                         'Data API with no runtime dependencies.'

  spec.homepage      = 'https://github.com/shearwaterintl/typeform_data'
  spec.license       = 'MIT'

  spec.files = `git ls-files -z`.split("\x0").reject { |f|
    f.match(%r{^(test|spec|features)/})
  }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.12'
  spec.add_development_dependency 'rake', '~> 10.0'
  spec.add_development_dependency 'minitest', '~> 5.0'
  spec.add_development_dependency 'flexmock', '~> 2.0'

  spec.add_development_dependency 'pry', '~> 0.10'
  spec.add_development_dependency 'pry-byebug', '~> 3.3'
  spec.add_development_dependency 'pry-doc', '~> 0.8'
  spec.add_development_dependency 'byebug', '~> 8.2'
  spec.add_development_dependency 'rubocop', '~> 0.47'

end
