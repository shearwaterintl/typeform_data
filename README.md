# TypeformData

A Ruby client for Typeform's Data API (https://www.typeform.com/help/data-api/).

This is alpha software and doesn't currently cover all the use cases you'd probably expect. I've just finished implementing response fetching (including de-pagination, so you can fetch _all_ the responses in one method call), but the full data model isn't built out yet.

Unless you're eager to dive into the code, I'd suggest waiting until next week to check out this gem.

TODO:
  - Add more detail, and example method calls.
  - Add an explanation: why another gem? What makes this gem different?

### Notes on the API

  - ID vs. UID: they aren't used consistency across the docs and actual API responses.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'typeform_data'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install typeform_data

## Usage

TODO: Write usage instructions here

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/typeform_data. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.


## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
