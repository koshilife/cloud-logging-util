# frozen_string_literal: true

require "time"
require "json"

require_relative "log_entry"
require_relative "severity"

module CloudLoggingUtil
  # Access Logging Rack Middleware for Cloud Logging
  class AccessLogging
    DEFAULT_PARAMS_PROC = proc do |env, status, headers, _body, began_at|
      now = Time.now
      latency = now.instance_eval { to_i + (usec / 1_000_000.0) } - began_at
      severity = Severity.cast_from_http_status(status)
      http_h = http_request_hash(env, status, headers, latency)
      LogEntry.new(severity, now, nil, nil, trace_id: trace_id(env), additional_hash: http_h).to_hash
    end

    def initialize(app, **kwargs)
      @app = app
      @io = kwargs[:io] || $stdout
      @params_proc = kwargs[:params_proc] || DEFAULT_PARAMS_PROC
    end

    def call(env)
      began_at = Time.now.instance_eval { to_i + (usec / 1_000_000.0) }
      status, headers, body = @app.call(env)
    ensure
      params = @params_proc.call(env, status, headers, body, began_at)
      @io.write("#{params.to_json}\n") if @io.respond_to?(:write)
    end

    def self.trace_id(env)
      env["cloud_logging_util.trace_id"] || env["action_dispatch.request_id"]
    end

    # refs: https://cloud.google.com/logging/docs/reference/v2/rest/v2/LogEntry#httprequest
    def self.http_request_hash(env, status, headers, latency)
      {
        httpRequest: {
          requestMethod: request_method(env),
          requestUrl: request_url(env),
          requestSize: request_size(env),
          status: status,
          responseSize: response_size(env, headers),
          userAgent: user_agent(env),
          remoteIp: remote_ip(env),
          serverIp: server_ip(env),
          referer: referer(env),
          latency: "%0.6fs" % latency,
          cacheLookup: cache_lookup(env),
          cacheHit: cache_hit(env),
          cacheValidatedWithOriginServer: cache_validated_with_origin_server(env),
          cacheFillBytes: cache_fill_bytes(env),
          protocol: protocol(env)
        }
      }
    end

    def self.request_method(env)
      if env["cloud_logging_util.request_method"].nil?
        env["REQUEST_METHOD"]
      else
        env["cloud_logging_util.request_method"]
      end
    end

    def self.request_url(env)
      if env["cloud_logging_util.request_url"].nil?
        url = "#{env["rack.url_scheme"]}://#{env["HTTP_HOST"]}#{env["PATH_INFO"]}"
        url += "?#{env["QUERY_STRING"]}" if env["QUERY_STRING"]&.length.to_i.positive?
        url
      else
        env["cloud_logging_util.request_url"].to_s
      end
    end

    def self.request_size(env)
      if env["cloud_logging_util.request_size"].nil?
        env["CONTENT_LENGTH"] ? env["CONTENT_LENGTH"].to_s : nil
      else
        env["cloud_logging_util.request_size"].to_s
      end
    end

    def self.response_size(env, headers)
      if env["cloud_logging_util.response_size"].nil?
        headers && headers["Content-Length"] ? headers["Content-Length"].to_s : nil
      else
        env["cloud_logging_util.response_size"].to_s
      end
    end

    def self.user_agent(env)
      env["cloud_logging_util.user_agent"] || env["HTTP_USER_AGENT"]
    end

    def self.remote_ip(env)
      env["cloud_logging_util.remote_ip"] || env["X-Forwarded-For"]
    end

    def self.server_ip(env)
      env["cloud_logging_util.server_ip"] || env["REMOTE_ADDR"]
    end

    def self.referer(env)
      env["cloud_logging_util.referer"] || env["HTTP_REFERER"]
    end

    def self.cache_lookup(env)
      if env["cloud_logging_util.cache_lookup"].nil?
        false
      else
        env["cloud_logging_util.cache_lookup"]
      end
    end

    def self.cache_hit(env)
      if env["cloud_logging_util.cache_hit"].nil?
        false
      else
        env["cloud_logging_util.cache_hit"]
      end
    end

    def self.cache_validated_with_origin_server(env)
      if env["cloud_logging_util.cache_validated_with_origin_server"].nil?
        false
      else
        env["cloud_logging_util.cache_validated_with_origin_server"]
      end
    end

    def self.cache_fill_bytes(env)
      if env["cloud_logging_util.cache_fill_bytes"].nil?
        nil
      else
        env["cloud_logging_util.cache_fill_bytes"].to_s
      end
    end

    def self.protocol(env)
      if env["cloud_logging_util.protocol"].nil?
        env["HTTP_VERSION"]
      else
        env["cloud_logging_util.protocol"]
      end
    end
  end
end
