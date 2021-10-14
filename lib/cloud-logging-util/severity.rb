# frozen_string_literal: true

module CloudLoggingUtil
  # https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#logseverity
  module Severity
    DEFAULT = "DEFAULT"
    DEBUG = "DEBUG"
    INFO = "INFO"
    NOTICE = "NOTICE"
    WARNING = "WARNING"
    ERROR = "ERROR"
    CRITICAL = "CRITICAL"
    ALERT = "ALERT"
    EMERGENCY = "EMERGENCY"

    def self.cast(severity)
      case severity.to_s.downcase
      when "debug"
        DEBUG
      when "info"
        INFO
      when "warn"
        WARNING
      when "error"
        ERROR
      when "fatal"
        CRITICAL
      else
        DEFAULT
      end
    end

    def self.cast_from_http_status(status)
      return ERROR if status.nil?

      status_int = status.to_s[0..2].to_i
      if status_int < 400
        INFO
      elsif status_int < 500
        WARNING
      else
        ERROR
      end
    end
  end
end
