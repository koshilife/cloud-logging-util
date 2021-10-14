# frozen_string_literal: true

require "test_helper"

require "securerandom"
require "stringio"

module CloudLoggingUtil
  class FormatterTest < BaseTest
    def setup
      @dummy_io = StringIO.new
      @logger = Logger.new(@dummy_io)
      @logger.progname = "foobar_progname"
      @logger.formatter = Formatter.new
      @trace_id = SecureRandom.uuid
      CloudLoggingUtil.setup_trace_id(@trace_id)
    end

    def teardown
      CloudLoggingUtil.setup_trace_id(nil)
    end

    def test_it_that_logs_to_io
      @logger.info("foobar1")
      @logger.warn("foobar2") { { foo: 1, bar: 2 } }
      logs = @dummy_io.string.split("\n").map { |line| JSON.parse(line) }

      log = logs[0]
      assert(log.delete("timestamp"))
      expected = {
        "severity" => Severity::INFO,
        "progname" => "foobar_progname",
        "message" => "foobar1",
        "logging.googleapis.com/trace" => @trace_id
      }
      assert_equal(expected, log)

      log = logs[1]
      assert(log.delete("timestamp"))
      expected = {
        "severity" => Severity::WARNING,
        "progname" => "foobar2",
        "foo" => 1,
        "bar" => 2,
        "logging.googleapis.com/trace" => @trace_id
      }
      assert_equal(expected, log)
    end
  end
end
