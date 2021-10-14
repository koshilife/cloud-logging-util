# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "simplecov"
SimpleCov.start
if ENV["CI"] == "true"
  require "codecov"
  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

require "minitest/autorun"
require "rack/test"
require "cloud-logging-util"

module CloudLoggingUtil
  class BaseTest < Minitest::Test
  end

  class RackTest < BaseTest
    include Rack::Test::Methods

    attr_reader :app

    def setup
      @mock_io = StringIO.new
      @app = AccessLogging.new(generate_app, io: @mock_io)
    end

    def generate_app
      raise NotImplementedError
    end
  end
end
