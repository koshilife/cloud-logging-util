# frozen_string_literal: true

require "test_helper"

module CloudLoggingUtil
  class SeverityTest < BaseTest
    def setup
      @subject = Severity
      @levels = ::Logger::SEV_LABEL
    end

    #
    # test for Severity.cast
    #

    def test_that_it_converts_debug_level
      assert_equal(@subject::DEBUG, @subject.cast(@levels[::Logger::DEBUG]))
    end

    def test_that_it_converts_info_level
      assert_equal(@subject::INFO, @subject.cast(@levels[::Logger::INFO]))
    end

    def test_that_it_converts_warn_level
      assert_equal(@subject::WARNING, @subject.cast(@levels[::Logger::WARN]))
    end

    def test_that_it_converts_error_level
      assert_equal(@subject::ERROR, @subject.cast(@levels[::Logger::ERROR]))
    end

    def test_that_it_converts_fatal_level
      assert_equal(@subject::CRITICAL, @subject.cast(@levels[::Logger::FATAL]))
    end

    def test_that_it_converts_any_level
      assert_equal(@subject::DEFAULT, @subject.cast(@levels[::Logger::UNKNOWN]))
      assert_equal(@subject::DEFAULT, @subject.cast("ANY"))
    end

    #
    # test for Severity.cast_from_http_status
    #

    def test_that_it_converts_empty_http_status
      assert_equal(@subject::ERROR, @subject.cast_from_http_status(nil))
    end

    def test_that_it_converts_http_status399
      assert_equal(@subject::INFO, @subject.cast_from_http_status(399))
    end

    def test_that_it_converts_http_status400
      assert_equal(@subject::WARNING, @subject.cast_from_http_status(400))
    end

    def test_that_it_converts_http_status500
      assert_equal(@subject::ERROR, @subject.cast_from_http_status(500))
    end
  end
end
