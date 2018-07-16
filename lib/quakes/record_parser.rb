# frozen_string_literal: true

module Quakes
  module RecordParser
      RECORD_REGEX = /"properties":(\{.*?\})/.freeze

      private
        def extract_record(str)
          str.match(RECORD_REGEX) { |m| m[1] }
        end
  end
end
