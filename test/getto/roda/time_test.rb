require "test_helper"

require "tzinfo"
require "getto/roda/time"

module Getto::Roda::TimeTest
  describe Getto::Roda::Time do
    describe "with time_zone" do
      it "has now timestamp" do
        now = Time.now
        time_zone = TZInfo::Timezone.get("Asia/Tokyo")
        assert_equal(
          Getto::Roda::Time.new(now: now, time_zone: time_zone).now,
          now
        )
      end

      it "can parse with localtime" do
        now = Time.now
        time_zone = TZInfo::Timezone.get("Asia/Tokyo")
        assert(
          Getto::Roda::Time.new(now: now, time_zone: time_zone).parse("2018-10-10 10:09:30"),
          Time.parse("2018-10-10 01:09:30")
        )
      end
    end
  end
end
