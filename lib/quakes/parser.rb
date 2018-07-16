# frozen_string_literal: true

require 'quakes/states'
require 'json'

module Quakes
  class Parser
    attr_reader :store, :parser

    def initialize(parser = nil)
      set parser
      @store = {}
    end

    def read_from(enumerator)
      enumerator.call { |line| store_record parser.parse(line) }
      store
    end

    private
      attr_writer :parser

      def set(parser)
        if parser.respond_to?(:parse)
          self.parser = parser
          return
        end

        puts "#{self}: provided parser (#{parser.inspect}) is not supported. Fallback to defaults" if parser
        self.parser = JSON
      end

      def store_record(record)
        state = extract_state(record)
        return unless state
        # looks like a bug in dataset https://earthquake.usgs.gov/earthquakes/eventpage/nc71109044#executive
        mag = record['mag'] || 0.0

        if store.key?(state)
          store[state].tap do |known_state|
            known_state[:total_count] += 1
            known_state[:quakes][mag] << dump_record(record)
          end

          return
        end

        store[state] = {
          total_count: 1,
          quakes: Hash.new { |h, k| h[k] = [] }
        }

        store[state][:quakes][mag] << dump_record(record)
      end


      def extract_state(record)
        place = record['place']
        return unless place

        comma_index = place.rindex(',')
        unless comma_index
          place.downcase!
          return States.state_if_exists(place)
        end

        name = place[comma_index + 1..-1]
        name.lstrip!
        name.downcase!

        States.state_if_exists(name)
      end

      def dump_record(record)
        record.slice('place', 'mag', 'time')
      end
  end
end
