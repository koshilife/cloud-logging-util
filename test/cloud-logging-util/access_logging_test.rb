# frozen_string_literal: true

require "test_helper"

require "securerandom"
require "stringio"
require "time"

module CloudLoggingUtil
  class AccessLoggingTest1 < RackTest
    class SimpleApp
      def call(_env)
        code   = 200
        body   = ["body123456789"]
        header = {
          "Content-Type" => "text/html; charset=UTF-8",
          "Content-Length" => "11"
        }
        [code, header, body]
      end
    end

    def generate_app
      SimpleApp.new
    end

    def test_that_it_log_request_info
      get "/foobar1?key1=value1&key2=value2"
      actual = JSON.parse(@mock_io.string)

      timestamp = actual.delete("timestamp")
      assert(Time.parse(timestamp))

      latency = actual["httpRequest"].delete("latency")
      assert_match(/0\.000\d\d\ds/, latency)

      expected = {
        "severity" => "INFO",
        "httpRequest" => {
          "requestMethod" => "GET",
          "requestUrl" => "http://example.org/foobar1?key1=value1&key2=value2",
          "requestSize" => "0",
          "status" => 200,
          "responseSize" => "11",
          "userAgent" => nil,
          "remoteIp" => nil,
          "serverIp" => "127.0.0.1",
          "referer" => nil,
          "cacheLookup" => false,
          "cacheHit" => false,
          "cacheValidatedWithOriginServer" => false,
          "cacheFillBytes" => nil,
          "protocol" => nil
        }
      }
      assert_equal(expected, actual)
    end
  end

  class AccessLoggingTest2 < RackTest
    include Rack::Test::Methods

    class ActionDispatchEnvApp
      def call(env)
        env["action_dispatch.request_id"] = "FOOBAR-REQUEST-ID"
        env["X-Forwarded-For"] = "FOOBAR-X-FORWARDED-FOR"
        env["CONTENT_LENGTH"] = 22
        env["HTTP_USER_AGENT"] = "FOOBAR-USER-AGENT"
        env["HTTP_REFERER"] = "http://foobar.com"
        env["HTTP_VERSION"] = "HTTP/2"

        code   = 400
        body   = ["body123456789"]
        header = {
          "Content-Type" => "text/html; charset=UTF-8",
          "Content-Length" => "222"
        }
        [code, header, body]
      end
    end

    def generate_app
      ActionDispatchEnvApp.new
    end

    def test_that_it_log_request_info
      get "/foobar2"
      actual = JSON.parse(@mock_io.string)

      timestamp = actual.delete("timestamp")
      assert(Time.parse(timestamp))

      latency = actual["httpRequest"].delete("latency")
      assert_match(/0\.000\d\d\ds/, latency)

      expected = {
        "severity" => "WARNING",
        "logging.googleapis.com/trace" => "FOOBAR-REQUEST-ID",
        "httpRequest" => {
          "requestMethod" => "GET",
          "requestUrl" => "http://example.org/foobar2",
          "requestSize" => "22",
          "status" => 400,
          "responseSize" => "222",
          "userAgent" => "FOOBAR-USER-AGENT",
          "remoteIp" => "FOOBAR-X-FORWARDED-FOR",
          "serverIp" => "127.0.0.1",
          "referer" => "http://foobar.com",
          "cacheLookup" => false,
          "cacheHit" => false,
          "cacheValidatedWithOriginServer" => false,
          "cacheFillBytes" => nil,
          "protocol" => "HTTP/2"
        }
      }
      assert_equal(expected, actual)
    end
  end

  class AccessLoggingTest3 < RackTest
    include Rack::Test::Methods

    class CustomEnvApp
      def call(env)
        env["cloud_logging_util.trace_id"] = "CUSTOM-TRACE-ID"
        env["cloud_logging_util.request_method"] = "CUSTOM-REQUEST-METHOD"
        env["cloud_logging_util.request_url"] = "CUSTOM-REQUEST-URL"
        env["cloud_logging_util.request_size"] = "CUSTOM-REQUEST-SIZE"
        env["cloud_logging_util.response_size"] = "CUSTOM-RESPONSE-SIZE"
        env["cloud_logging_util.user_agent"] = "CUSTOM-USER-AGENT"
        env["cloud_logging_util.remote_ip"] = "CUSTOM-REMOTE-IP"
        env["cloud_logging_util.server_ip"] = "CUSTOM-SERVER-IP"
        env["cloud_logging_util.referer"] = "CUSTOM-REFERER"
        env["cloud_logging_util.cache_lookup"] = true
        env["cloud_logging_util.cache_hit"] = true
        env["cloud_logging_util.cache_validated_with_origin_server"] = true
        env["cloud_logging_util.cache_fill_bytes"] = 100
        env["cloud_logging_util.protocol"] = "CUSTOM-PROTOCOL"
        code   = 500
        body   = ["body123456789"]
        header = {
          "Content-Type" => "text/html; charset=UTF-8",
          "Content-Length" => "333"
        }
        [code, header, body]
      end
    end

    def generate_app
      CustomEnvApp.new
    end

    def test_that_it_log_request_info
      get "/foobar3"
      actual = JSON.parse(@mock_io.string)

      timestamp = actual.delete("timestamp")
      assert(Time.parse(timestamp))

      latency = actual["httpRequest"].delete("latency")
      assert_match(/0\.000\d\d\ds/, latency)

      expected = {
        "severity" => "ERROR",
        "logging.googleapis.com/trace" => "CUSTOM-TRACE-ID",
        "httpRequest" => {
          "requestMethod" => "CUSTOM-REQUEST-METHOD",
          "requestUrl" => "CUSTOM-REQUEST-URL",
          "requestSize" => "CUSTOM-REQUEST-SIZE",
          "status" => 500,
          "responseSize" => "CUSTOM-RESPONSE-SIZE",
          "userAgent" => "CUSTOM-USER-AGENT",
          "remoteIp" => "CUSTOM-REMOTE-IP",
          "serverIp" => "CUSTOM-SERVER-IP",
          "referer" => "CUSTOM-REFERER",
          "cacheLookup" => true,
          "cacheHit" => true,
          "cacheValidatedWithOriginServer" => true,
          "cacheFillBytes" => "100",
          "protocol" => "CUSTOM-PROTOCOL"
        }
      }
      assert_equal(expected, actual)
    end
  end
end
