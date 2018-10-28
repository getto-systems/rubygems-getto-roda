require "getto/roda/time"
require "getto/roda/decode"
require "getto/roda/logger"

module Getto
  module Roda
    class EntryPoint
      def initialize(
        error:, time_zone:,
        app:, request:,
        config:, params:,
        request_logger:, exception_notifier:)

        @error = error
        @time = Getto::Roda::Time.new(now: ::Time.now, time_zone: time_zone)

        @app = app
        @request = request
        @config = config
        @params = params

        @request_logger = request_logger
        @exception_notifier = exception_notifier

        @logger = Getto::Roda::Logger.new
      end

      attr_reader :error, :time,
        :app, :request,
        :config, :params, :account,
        :logger, :exception_notifier


      def handle(controller)
        params.merge! parse_params.to_h
        @account = detect_account

        init_controller(controller).action
      rescue error => e
        error! e

        if e.status >= 500
          exception_notifier.notify(e, data: request_data)
        end

        app.response.status = e.status

        {message: e.message.split(":").first}
      rescue Exception => e
        error! e
        exception_notifier.notify_exception(e, data: request_data)
        raise e
      ensure
        if @error_data
          @request_logger.error(name: :handle){ request_data }
        else
          @request_logger.info(name: :handle){ request_data }
        end
      end

      private

        def detect_account
          error.not_implemented!
        end

        def init_controller(controller)
          error.not_implemented!
        end


        def parse_params
          if app.env["REQUEST_METHOD"].upcase == "GET"
            parse_query_string!
          else
            parse_request_body!
          end
        end

        def parse_request_body!
          Getto::Roda::Decode::Post.new(app.env["CONTENT_TYPE"], request.body.read)
            .to_h or error.invalid_params!
        end

        def parse_query_string!
          Getto::Roda::Decode::Get.new(app.env["QUERY_STRING"])
            .to_h or error.invalid_params!
        end


        def error!(e)
          @error_data = {
            error:   e.class.to_s,
            message: e.message,
          }
        end

        def request_data
          {
            start:   time.now.iso8601,
            remote:  app.env['HTTP_X_FORWARDED_FOR'] || app.env["REMOTE_ADDR"] || "-",
            account: account,
            method:  app.env["REQUEST_METHOD"],
            uri:  "#{app.env["PATH_INFO"]}#{app.env["QUERY_STRING"].tap{|s| break s.empty? ? s : "?#{s}" }}",
            elapsed: "%.3f" % (::Time.now.to_f - time.now.to_f),
            app:     @logger.data,
          }.tap{|data|
            if @error_data
              data[:error] = @error_data
            else
              data[:result] = :ok
            end
          }
        end
    end
  end
end
