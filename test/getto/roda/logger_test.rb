require "test_helper"

require "getto/roda/logger"

module Getto::Roda::LoggerTest
  describe Getto::Roda::Logger do
    describe "log" do
      it "hold data within array" do
        logger = Getto::Roda::Logger.new

        logger.log(
          name: "value",
        )
        logger.log("message")
        logger.log([
          "value1",
          "value2",
          "value3",
        ])

        assert_equal(
          logger.data,
          [
            {
              name: "value",
            },
            "message",
            [
              "value1",
              "value2",
              "value3",
            ],
          ]
        )
      end
    end
  end
end
