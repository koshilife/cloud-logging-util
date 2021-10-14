# frozen_string_literal: true

require "logger"
require_relative "log_entry"
require_relative "severity"

module CloudLoggingUtil
  TRACE_ID_KEY = :cloud_logging_util_trace_id_key
  private_constant :TRACE_ID_KEY

  def setup_trace_id(trace_id)
    Thread.current[TRACE_ID_KEY] = trace_id
  end
  module_function :setup_trace_id

  # formatter for Cloud Logging
  class Formatter < ::Logger::Formatter
    def call(severity, time, progname, message)
      entry = LogEntry.new(Severity.cast(severity), time, progname, message, trace_id: trace_id)
      "#{entry.to_hash.to_json}\n"
    end

    private

    def trace_id
      Thread.current[TRACE_ID_KEY]
    end
  end
end
