module Getto
  module Roda
    class Logger
      attr_reader :data

      def log(data)
        @data ||= []
        @data.push data
      end
    end
  end
end
