require_relative './test_helper'
require 'quakes/net_reader'

module Quakes
  class TestNetReader < Minitest::Test
    def test_fails_if_source_is_empty
      assert_raises(BadURLError) { NetReader.new('') }
    end

    def test_uses_default_if_source_is_missed
      assert_equal URI(NetReader::DEFAULT_DATASET_URL), NetReader.new(nil).uri
    end

    def test_has_default_dataset_url
      refute_empty NetReader::DEFAULT_DATASET_URL
    end

    def test_exits_on_bad_urls
      assert_raises(BadURLError) { NetReader.new('://111') }
    end

    def test_prints_notice_if_server_unknown
      nr = NetReader.new('https://example.com')
      Net::HTTP.expects(:start).raises(SocketError)

      assert_raises(TimeoutError) { nr.call {} }
    end

    def test_retries_gracefully
      nr = NetReader.new('https://example.com')
      nr.stubs(:read_response)
      nr.stubs(:wait)

      http = mock
      http.stubs(:request).yields(Net::HTTPClientError).then.
        yields(Net::HTTPClientError.new(1, 2, 3)).then.
        yields(Net::HTTPClientError.new(1, 2, 3)).then.
        yields(Net::HTTPOK.new(1, 2, 3))
      Net::HTTP.stubs(:start).yields(http)

      nr.call {}
    end
  end
end
