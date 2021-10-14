# frozen_string_literal: true

module CloudLoggingUtil
  # Cloud Logging LogEntry
  # refs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry
  class LogEntry
    def initialize(severity, time, progname, message, trace_id: nil, additional_hash: nil)
      @severity = severity
      @time = time
      @progname = progname
      @message = message
      @trace_id = trace_id
      @additional_hash = additional_hash
    end

    def to_hash
      entry = {}
      entry.merge!(severity_h)
      entry.merge!(time_h)
      entry.merge!(progname_h)
      entry.merge!(message_h)
      entry.merge!(trace_h)
      @additional_hash.respond_to?(:merge) ? entry.merge(@additional_hash) : entry
    end

    private

    def severity_h
      return {} if @severity.nil?

      { severity: @severity }
    end

    def time_h
      return {} if @time.nil?
      return {} unless @time.respond_to?(:utc) && @time.respond_to?(:strftime)

      { timestamp: @time.utc.strftime("%FT%T.%NZ") }
    end

    def progname_h
      return {} if @progname.nil?

      { progname: @progname }
    end

    def message_h
      return {} if @message.nil?
      return @message.to_hash if @message.respond_to?(:to_hash)
      return { message: @message } if @message.is_a?(String)

      { message: @message.inspect }
    end

    def trace_h
      return {} if @trace_id.nil?

      {
        "logging.googleapis.com/trace": @trace_id
      }
    end
  end
end
