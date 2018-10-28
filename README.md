# getto-roda

[rubygems: getto-roda](https://rubygems.org/gems/getto-roda)

The web app entry point helper for [Roda](https://roda.jeremyevans.net/index.html)


###### Table of Contents

- [Requirements](#Requirements)
- [Usage](#Usage)
- [License](#License)

<a id="Requirements"></a>
## Requirements

- developed on ruby: 2.5.1
- [Roda](https://roda.jeremyevans.net/index.html)


<a id="Usage"></a>
## Usage

### entry point

```ruby
require "getto/roda/entry_point"

require "logger"
require "exception_notifier"
require "jwt"
require "sequel"

class AppError < RuntimeError
  extend Getto::Roda::HttpErrorHelper

  error 401, :unauthorized
  ... # other errors
end

module MyApp
  class EntryPoint < Getto::Roda::EntryPoint

    # Getto::Roda::EntryPoint
    #   def initialize(
    #     error:, time_zone:,
    #     app:, request:,
    #     config:, params:,
    #     request_logger:, exception_notifier:)
    #   ...
    #   end
    #
    #   attr_reader(
    #     :app,     # => Roda app object
    #     :request, # => Roda request object
    #     :error,
    #     :config,
    #     :params,
    #     :account,
    #     :exception_notifier,
    #     :time,   # => Getto::Time
    #     :logger, # => Getto::Logger
    #   )

    def initialize(config:, **args)
      super(
        error:     AppError,
        config:    config,           # Getto::Roda::Config
        time_zone: config.time.zone, # TZInfo::TimeZone

        request_logger:     ::Logger.new(STDOUT),
        exception_notifier: ::ExceptionNotifier,

        **args,
      )
    end

    private

      def init_controller(controller)
        # initialize controller class
        controller.new(
          error:   error,
          time:    time,
          logger:  logger,
          params:  params,
          config:  config,
          account: account, # <= detect_account
          sequel:  ::Sequel.connect(config.db),
        )
      end

      def detect_account
        ::JWT.decode(
          app.env["HTTP_" + config.authorized.header],
          config.authorized.secret,
          true,
          {
            algorithm: config.authorized.algorithm,
          }
        ).first.transform_keys(&:to_sym)
      rescue ::JWT::DecodeError => e
        error.invalid_token! e.message
      end
  end
end


module MyApp
  class Main < Roda
    config = MyApp.config # Getto::Roda::Config

    launch = ->(app,r, path, **params){
      require "my_app/controller/#{path}"
      EntryPoint.new(app: app, request: r, config: config, params: params)
        .handle(
          path.split("/")
            .map{|name|
              name.gsub(%r{_.}){|c| c[1].upcase}
                .sub(%r{\A.}){|c| c.upcase}
                .to_sym
            }
            .inject(Controller){|klass,name| klass.const_get(name)}
        ).to_json
    }

    route do |r|
      r.root { VERSION }

      r.get("information"){ launch[self,r, "information"] }
    end
  end
end
```

### config definition

```ruby
require "getto/roda/config"

config =
  Getto::Roda::Config.configure(
    name: String,
    key: {
      roles: Array,
      config: Hash,
    },
  ) do |c|
    c.name = "Name"
    c.group :key do |sub|
      sub.roles = [:user, :system]
      sub.config = {
        path: :path,
        url:  :url,
      }
    end
  end

config.name       # => "Name"
config.key.roles  # => [:user, :system]
config.key.config # => { path: :path, url: :url }
```

# decode params

```ruby
require "getto/roda/decode"

# decode post body with content-type info
params = Getto::Roda::Decode::Post.new("application/json", '{"key":"value"}').to_h
# => {"key" => "value"}

# nil if content-type is not "application/json"
params = Getto::Roda::Decode::Post.new("text/plain", '{"key":"value"}').to_h
# => nil

# decode get query string
params = Getto::Roda::Decode::Get.new("key=value").to_h
# => {"key" => "value"}
```

### http error

```ruby
require "getto/roda/http_error_helper"

class AppError < RuntimeError
  extend Getto::Roda::HttpErrorHelper

  error 401, :unauthorized
end

begin
  AppError.unauthorized!
rescue AppError => e
  e.status  # => 401
  e.message # => "unauthorized"
end

begin
  AppError.unauthorized!("login required", "login_id or password not valid")
rescue AppError => e
  e.status  # => 401
  e.message # => "unauthorized: login required: login_id or password not valid"
end
```

### logger

```ruby
require "getto/roda/logger"

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

logger.data
# => [
#   {
#     name: "value",
#   },
#   "message",
#   [
#     "value1",
#     "value2",
#     "value3",
#   ],
# ]
```

### time

```ruby
require "getto/roda/time"

now = Time.now
time_zone = TZInfo::Timezone.get("Asia/Tokyo")

Getto::Roda::Time.new(now: now, time_zone: time_zone).now # => now, not Time.now

Getto::Roda::Time.new(now: now, time_zone: time_zone).parse("2018-10-10 10:09:30")
# => Time.parse("2018-10-10 01:09:30") : parse with time-zone
```

## Install

Add this line to your application's Gemfile:

```ruby
gem 'getto-roda'
```

And then execute:

```
$ bundle
```

Or install it yourself as:

```
$ gem install getto-roda
```


<a id="License"></a>
## License

getto/roda is licensed under the [MIT](LICENSE) license.

Copyright &copy; since 2018 shun@getto.systems
