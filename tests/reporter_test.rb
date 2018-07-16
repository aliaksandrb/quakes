require_relative './test_helper'
require 'quakes/reporter'

module Quakes
  class TestReporter < Minitest::Test
    def test_fails_if_command_is_missed
      assert_raises(MissedCommandError) { Reporter.new({ argv: 5 }) }
    end

    def test_fails_if_command_is_unknown
      assert_raises(UnknownCommandError) { Reporter.new({ argv: 5, command: :test }) }
    end
  end
end
