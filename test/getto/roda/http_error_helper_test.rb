require "test_helper"

require "getto/roda/http_error_helper"

module Getto::Roda::HttpErrorHelperTest
  describe Getto::Roda::HttpErrorHelper do
    describe "error" do
      it "create raise error method and create new class with status code" do
        class AppError < RuntimeError
          extend Getto::Roda::HttpErrorHelper

          error 401, :unauthorized
        end

        assert_equal(
          AppError::E401.new("message").status,
          401
        )

        assert_raises AppError::E401 do
          AppError.unauthorized!
        end

        assert_raises AppError::E401 do
          AppError.unauthorized! "message"
        end
      end
    end
  end
end
