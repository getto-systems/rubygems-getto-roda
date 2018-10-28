require "time"

module Getto
  module Roda
    class Time
      def initialize(now:, time_zone:)
        @time_zone = time_zone
        @now = now
      end

      attr_reader :now

      def parse(str)
        @time_zone.local_to_utc ::Time.parse(str)
      end
    end
  end
end
