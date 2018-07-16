# frozen_string_literal: true

require 'quakes/version'
require 'quakes/errors'
require 'quakes/file_reader'
require 'quakes/net_reader'
require 'quakes/parser'
require 'quakes/reporter'

module Quakes
  KNOWN_OPTIONS = %i(command argv asc filepath url debug).freeze

  class << self
    def run!(**options)
      return run_in_debug_mode(options) if options.delete(:debug)

      do_run(options).call
    end

    private
      def run_in_debug_mode(options)
        begin
          require 'memory_profiler'

          MemoryProfiler.report(allow_files: 'quakes/lib') do
            start = Time.now
            do_run(options).call
            puts "Executed in: #{Time.now - start}"
          end.pretty_print
        rescue LoadError
          puts "`gem install 'memory_profiler'` required prior debug mode execution"
        end
      end

      def do_run(options)
        proc do
          reader = new_reader(options)
          new_reporter(options).read_from(reader).use(new_parser).run
        end
      end

      def new_reader(options)
        return new_file_reader(options.delete(:filepath)) if options.key?(:filepath)

        new_net_reader(options.delete(:url))
      end

      def new_file_reader(filepath)
        FileReader.new(filepath)
      end

      def new_net_reader(url)
        NetReader.new(url)
      end

      def new_parser
        Parser.new
      end

      def new_reporter(options)
        Reporter.new(options)
      end
  end
end
