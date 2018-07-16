# frozen_string_literal: true

require 'quakes/record_parser'
require 'quakes/errors'

module Quakes
  class FileReader
    include RecordParser

    def initialize(filepath)
      @filepath = filepath
      validate!
    end

    def call
      File.open(filepath).each_line do |line|
        record = extract_record(line)
        next unless record

        yield record
      end
    rescue IOError, Errno::ENOENT => exc
      STDERR.puts "#{self}: unable to read a file `#{filepath}`: #{exc.inspect}"
    end

    private
      attr_reader :filepath

      def validate!
        if filepath.nil? || filepath == '' || !File.exist?(filepath)
          raise FileNotFoundError.new("missed local source file: #{filepath.inspect}")
        end
      end
  end
end
