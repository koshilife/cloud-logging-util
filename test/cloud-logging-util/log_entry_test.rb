# frozen_string_literal: true

require "test_helper"

module CloudLoggingUtil
  class LogEntryTest < BaseTest
    def setup
      @subject = LogEntry
      @now = Time.now
    end

    def test_it_that_generates_with_empty_arguments
      obj = @subject.new(nil, nil, nil, nil)
      assert_equal({}, obj.to_hash)
    end

    def test_it_that_generates_with_full_arguments
      obj = @subject.new(
        "foobar_severity",
        @now,
        "foobar_progname",
        "foobar_message",
        trace_id: "foobar_trace_id",
        additional_hash: { foo: 123, bar: 456 }
      )
      expected = {
        severity: "foobar_severity",
        timestamp: @now.utc.strftime("%FT%T.%NZ"),
        progname: "foobar_progname",
        message: "foobar_message",
        "logging.googleapis.com/trace": "foobar_trace_id",
        foo: 123,
        bar: 456
      }
      assert_equal(expected, obj.to_hash)
    end

    def test_it_that_generates_with_hash_message_argument
      message = { message1: "foobar_message1", message2: "foobar_message2" }
      obj = @subject.new(nil, nil, nil, message)
      assert_equal(message, obj.to_hash)
    end

    def test_it_that_generates_with_array_message_argument
      message = [1, 2, 3]
      obj = @subject.new(nil, nil, nil, message)
      assert_equal({ message: message.inspect }, obj.to_hash)
    end
  end
end
