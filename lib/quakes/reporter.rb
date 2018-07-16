# frozen_string_literal: true

require 'quakes/states'
require 'quakes/errors'

module Quakes
  class Reporter
    def initialize(options)
      @dir = options.delete(:asc) ? :asc : :desc
      @argv = options.delete(:argv)
      @command = options.delete(:command)

      validate!
    end

    def read_from(reader)
      @reader = reader
      self
    end

    def use(parser)
      @parser = parser
      self
    end

    def run
      @store = parser.read_from(reader)
      public_send(command, argv, dir)
    end

    def top_by_occurrence(limit = 1, dir)
      sorted = store.sort_by { |state, data| data[:total_count] }

      puts "TOP #{limit} US states by number of earthquakes, #{dir_message(dir)}"
      puts "#{'#'.ljust(3)} #{'State'.ljust(States.max)} Count"

      extract_output(sorted, limit, dir).each_with_index do |(state, data), i|
        puts "#{(i + 1).to_s.ljust(3)} #{state.upcase.ljust(States.max)} #{data[:total_count]}"
      end
    end

    def top_by_state(name, dir, limit = 25)
      name = States.state_if_exists(name)
      return unless store.key?(name)

      sorted = store[name][:quakes].sort_by { |mag, occ| mag }

      puts "TOP #{limit} strongest earthquakes in #{name.capitalize}, #{dir_message(dir)}"
      puts "#{'#'.ljust(3)} #{'Time'.ljust(26)} #{'Mag'.ljust(5)} #{'Place'.ljust(20)}"

      i = 0
      extract_output(sorted, limit, dir).each do |(mag, records)|
        records.each do |record|
          return if i == limit
          puts "#{(i + 1).to_s.ljust(3)} #{Time.at(record['time'] / 1000).utc.to_s.ljust(26)} "\
               "#{mag.to_s.ljust(5)} #{record['place'].ljust(20)}"
          i += 1
        end
      end
    end

    private
      attr_reader :reader, :parser
      attr_reader :store, :command, :argv, :dir

      def validate!
        raise MissedCommandError.new("missed command: #{command.inspect}") unless command
        raise UnknownCommandError.new("unknown command: #{command.inspect}") unless respond_to?(command)
        raise MissedArgumentError.new("missed argument: #{argv.inspect}") unless argv
      end

      def extract_output(list, limit, dir)
        dir == :asc ? list.first(limit) : list.last(limit).reverse
      end

      def dir_message(dir)
        dir == :asc ? 'lowest to highest' : 'highest to lowest'
      end
  end
end
