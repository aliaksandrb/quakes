require_relative './test_helper'
require 'quakes/parser'
require 'json'

module Quakes
  class TestParser < Minitest::Test
    def test_uses_default_if_lib_is_not_provided
      assert_equal ::JSON, Parser.new.parser
      assert_equal ::JSON, Parser.new(nil).parser
    end

    def test_fallback_to_default_if_lib_is_not_suitable
      assert_equal ::JSON, Parser.new(Object.new).parser
    end

    def test_can_provide_own_parser
      obj = Object.new
      def obj.parse; end

      assert_equal obj, Parser.new(obj).parser
    end
  end
end
