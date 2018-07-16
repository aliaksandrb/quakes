# frozen_string_literal: true

module Quakes
  class Error < StandardError; end

  class BadURLError < Error; end
  class FileNotFoundError < Error; end
  class MissedCommandError < Error; end
  class UnknownCommandError < Error; end
  class MissedArgumentError < Error; end
  class UnableToConnectError < Error; end
  class TimeoutError < Error; end
  class UnknownStateError < Error; end
end
