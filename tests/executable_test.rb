require_relative './test_helper'
require 'quakes'

module Quakes
  class TestExecutable < Minitest::Test
    def shell_run(*args)
      out, err = capture_subprocess_io do
        system(File.join(__dir__, '../bin/quakes'), *args)
      end
      [$?, out, err]
    end

    def test_fails_if_no_options
      status, _, _ = shell_run()
      assert_equal 1, status.exitstatus
    end

    def test_fails_if_no_required_argmuents
      status, _, _ = shell_run('--asc')
      assert_equal 1, status.exitstatus
    end

    def test_displays_version
      status, out, _ = shell_run('--version')
      assert_equal 0, status.exitstatus
      assert_equal Quakes::VERSION, out.chomp
    end

    def test_displays_help
      status, out, _ = shell_run('--help')
      assert_equal 0, status.exitstatus
      assert_match(/Usage:/, out)
    end

    def test_options_should_come_in_pairs
      status, _, _ = shell_run('--f --top5')
      assert_equal 1, status.exitstatus

      status, _, _ = shell_run('--net --california')
      assert_equal 1, status.exitstatus
    end

    def test_two_commands_are_not_allowed
      status, _, _ = shell_run('--top5 --ca')
      assert_equal 1, status.exitstatus

      status, _, _ = shell_run('--california --top10')
      assert_equal 1, status.exitstatus
    end

    def test_two_sources_are_not_allowed
      status, _, _ = shell_run('--f file --net https://example.com')
      assert_equal 1, status.exitstatus

      status, _, _ = shell_run('--net https://example.com --f file' )
      assert_equal 1, status.exitstatus
    end
  end
end
