# TypeformData

A Ruby gem and client for Typeform's [Data API](https://www.typeform.com/help/data-api/). Our documentation is available [here](http://www.rubydoc.info/gems/typeform_data/TypeformData/Typeform).

## Usage:

```
client = TypeformData::Client.new(api_key: 'YOUR_API_KEY')
typeforms = client.all_typeforms

typeform = typeforms.first
=> #<TypeformData::Typeform
 @config=#<TypeformData::Config @api_key="YOUR_API_KEY">,
 @id="TYPEFORM_ID",
 @name="TYPEFORM_NAME">
```

### Fetching responses

```
all_complete_responses = typeform.responses(completed: true)
```

Unless you specify a limit, `TypeformData::Typeform#responses` will not paginate, and will make multiple AJAX requests as needed (the Data API only returns up to 1000 responses at a time) to fetch all the matching responses.

You can also specify any of the ["Filtering Options"](https://www.typeform.com/help/data-api/) to pass along to the API call:

```
some_complete_responses = typeform.responses(limit: 500, offset: 2000, completed: true)
two_days_of_responses = typeform.responses(from: 1470143917, since: 1470316722)

```

### Questions & answers

The response data you get back is represented using classes with defined relationships. All `TypeformData::*` objects should be treated as immutable.

```
typeform.responses.first.answers.first.typeform == typeform
=> true

typeform.fields.map(&:text)
=> ["What is your name?", "What are your favorite colors?", ...]

typeform.responses.first.answers.map { |answer| [answer.field_text, answer.value] }
=> [["What is your name?", "Foo Bar"], ["What are your favorite colors?", ["blue", "orange"]]]

```

### Serialization & deserialization

Your API key will not be serialized. `TypeformData::Client#dump` is just a pass-through to `Marshal#dump`, but `Client#load` will re-set your API key on each of the deserialized objects-- this ensures the object graph stays intact through the serialization process.

```
serialized = client.dump(responses)
deserialized = client.load(serialized)

> deserialized == responses
=> true

> deserialized.first.typeform == responses.first.typeform
=> true
```

### Error-handling

Unless you've encountered a bug, all exceptions raised by this gem should extend from `TypeformData::Error`. For the full exception hierarchy, see `lib/typeform_data/errors`.

If a HTTP request to Typeform fails with an error that we expect to be transient (e.g. a 503) we retry the HTTP request up to 3 times, after waiting 1, 2 and 4 seconds. If you'd prefer a fail-fast approach, send us a PR!

Currently, all 404 errors are retried. This is because Typeform occasionally returns a 404 while it's waiting to achieve consistency. For more, see `lib/typeform_data/requestor.rb`.

### Logging

This gem logs error and warning messages to $stdout by default. If you want to log to elsewhere, or in a different format, you can pass in your own logger object (anything that implements the same interface as the [default Ruby logger](https://ruby-doc.org/stdlib-2.1.0/libdoc/logger/rdoc/Logger.html)) like this:

```
TypeformData::Client.new(api_key: 'YOUR API KEY', logger: logger)
```

## Notes on the API

So far, we've found Typeform's current Data API to be confusing. In particular, there are a couple design decisions that have been a source of friction for us:

- Statements (which are sections of text in a Typeform, and can't be answered) and Hidden Fields (data passed into a form, and not provided by the user) are both included under the `'questions'` key in the API's response JSON. From the perspective of a user, we don't think of these as "questions".
- Each option in a "Picture choice" (and, IIRC "Multiple choice" as well, if multiple choices are allowed) is returned as its own "question" in the response JSON for questions and answers. We feel that it makes more sense to model these as multiple answers to one question, i.e. an Array-valued answer.

The main goal of this API wrapper is to encapsulate these implementation details and provide a more intuitive API for our application code. This means that our data model must deviate in specific places from the implicit data model expressed in the Data API's JSON responses. We're sacrificing consistency for a more intuitive client API.

## Notes

  - At the moment, this gem has no runtime dependencies.
  - We've only tested this gem against Ruby 2.3. I'm not sure whether it works with older versions.
  - Under the hood, the object relationships are implemented by storing a reference to a config object containing your API key. This is what allows you to say `answer.typeform.responses` and ultimately make an API call originating from a `TypeformData::Typeform::Answer` without having to pass in a reference to a client or your API key (again). To avoid leaking your API key, make sure to clear out the `@config` reference if you add new serialization functionality! (We've already handled this for `Marshal#dump`.)

### Installation

Add this line to your application's Gemfile:

```ruby
gem 'typeform_data'
```

And then execute:

    $ bundle

### Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment. To get started, you'll probably want to run something like:

```
TypeformData::Client.new(api_key: your_api_key).all_typeforms
```

### Releasing a new version

Update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

### Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/typeform_data. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

### License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
