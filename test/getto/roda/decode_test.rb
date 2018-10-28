require "test_helper"

require "getto/roda/decode"

module Getto::Roda::DecodeTest
  describe Getto::Roda::Decode do
    describe "post" do
      it "decode successfuly with valid json data and json content-type" do
        assert_equal(
          Getto::Roda::Decode::Post.new("application/json", '{"message":"ok"}').to_h,
          {"message" => "ok"}
        )
      end

      it "decode nil with empty string and json content-type" do
        assert_nil(
          Getto::Roda::Decode::Post.new("application/json", '').to_h
        )
      end

      it "cannot decode with no json content-type" do
        assert_nil(
          Getto::Roda::Decode::Post.new("application/octet", '{"message":"ok"}').to_h
        )
      end

      it "cannot decode with invalid json data and json content-type" do
        assert_nil(
          Getto::Roda::Decode::Post.new("application/json", '{"message":"ok"invalid}').to_h
        )
      end
    end

    describe "get" do
      it "decode successfuly with valid query string" do
        assert_equal(
          Getto::Roda::Decode::Get.new("message=ok").to_h,
          {"message" => "ok"}
        )
      end

      it "cannot decode with invalid query string" do
        assert_equal(
          Getto::Roda::Decode::Get.new("=ok").to_h,
          {}
        )
      end
    end
  end
end
