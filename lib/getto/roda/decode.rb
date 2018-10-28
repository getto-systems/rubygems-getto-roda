require "rack"
require "json"

module Getto
  module Roda
    module Decode
      class Post
        def initialize(content_type, body)
          @content_type = content_type
          @body = body
        end

        def to_h
          return unless @content_type == "application/json"
          ::JSON.parse @body
        rescue ::JSON::ParserError
          nil
        end
      end

      class Get
        def initialize(query_string)
          @query_string = query_string
        end

        def to_h
          ::Rack::Utils.parse_nested_query(@query_string)
        end
      end
    end
  end
end
