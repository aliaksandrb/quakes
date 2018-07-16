# frozen_string_literal: true

require 'net/http'
require 'quakes/errors'
require 'quakes/record_parser'

module Quakes
  class NetReader
    include RecordParser

    DEFAULT_DATASET_URL = 'https://earthquake.usgs.gov/earthquakes/feed/v1.0/summary/all_month.geojson'
    MAX_RETRIES = 3

    attr_reader :uri

    def initialize(url)
      validate_and_parse!(url || DEFAULT_DATASET_URL)
    end

    def call(&block)
      Net::HTTP.start(uri.host, uri.port, use_ssl: uri.scheme == 'https') do |http|
        with_retry(http, MAX_RETRIES, &block)
      end
    rescue SocketError, Errno::ECONNREFUSED => exc
      raise TimeoutError.new("unable to read from remote: #{exc.message}")
    end

    private
      attr_writer :uri

      def validate_and_parse!(url)
        raise BadURLError.new('source url is empty') if url == ''
        parse!(url)
      end

      def parse!(url)
        self.uri = URI(url)
      rescue URI::InvalidURIError
        raise BadURLError.new("source url is not valid: #{url.inspect}")
      end

      def new_request(uri)
        Net::HTTP::Get.new(uri)
      end

      def with_retry(http, limit, &block)
        i = 0
        req = new_request(uri)

        begin
          http.request(req) do |response|
            raise TimeoutError unless success?(response)
            read_response response, &block
          end
        rescue TimeoutError => exc
          i += 1
          raise if i > limit
          puts "#{uri}: #{exc.message}, retrying: #{i}/#{limit}"
          wait i
          retry
        end
      end

      def timeout(i)
        sleep 2 << i
      end

      def success?(response)
        Net::HTTPSuccess === response
      end

      def read_response(response)
        buf = ''
        response.read_body do |chunk|
          chunk = buf + chunk

          unless chunk.index("\n")
            buf = chunk
            next
          end

          parts = chunk.split("\n")
          size = parts.size
          buf = ''
          i = 0
          parts.each do |c|
            i += 1
            record = extract_record(c)
            unless record
              buf = c if i == size
              next
            end

            yield record
          end
        end
      end
  end
end
