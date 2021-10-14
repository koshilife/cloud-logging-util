# CloudLoggingUtil

[![Test](https://github.com/koshilife/cloud-logging-util/workflows/Test/badge.svg)](https://github.com/koshilife/cloud-logging-util/actions?query=workflow%3ATest)
[![codecov](https://codecov.io/gh/koshilife/cloud-logging-util/branch/master/graph/badge.svg)](https://codecov.io/gh/koshilife/cloud-logging-util)
[![Gem Version](https://badge.fury.io/rb/cloud-logging-util.svg)](http://badge.fury.io/rb/cloud-logging-util)
[![license](https://img.shields.io/github/license/koshilife/cloud-logging-util)](https://github.com/koshilife/cloud-logging-util/blob/master/LICENSE.txt)

CloudLoggingUtil is a small library to output structured logs in Cloud Logging.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'cloud-logging-util'
```

And then execute:

    $ bundle install

Or install it yourself as:

    $ gem install cloud-logging-util

## Usage

Insert CloudLoggingUtil::AccessLogging on the head of rack middlewares.

### Rails

```rb
# config/application.rb
class Application < Rails::Application
  # setting for Access Logging ($stdout)
  config.middleware.insert_before(0, CloudLoggingUtil::AccessLogging)

  # setting for Application Logger ($stderr)
  config.logger = ActiveSupport::Logger.new($stderr)
  config.logger.formatter = CloudLoggingUtil::Formatter.new
  config.colorize_logging = false
end
```

Middleware check.

```sh
bundle exec rake middleware
```

setup.

```rb
class YourController < ActionController::Base
  prepend_before_action do
    # set trace_id to request_id
    CloudLoggingUtil.setup_trace_id(request.request_id)
  end
end
```

More in-depth method documentation can be found at [RubyDoc.info](https://www.rubydoc.info/gems/cloud-logging-util/).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/koshilife/cloud-logging-util. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [code of conduct](https://github.com/koshilife/cloud-logging-util/blob/master/CODE_OF_CONDUCT.md).

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Cloud::Logging::Logger project's codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/koshilife/cloud-logging-util/blob/master/CODE_OF_CONDUCT.md).
