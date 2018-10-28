module Getto
  module Roda
    module HttpErrorHelper
      def error(code, name, &block)
        error_class_name = :"E#{code}"
        unless self.const_defined? error_class_name
          self.const_set(error_class_name, Class.new(self).tap{|klass|
            klass.class_eval{ define_method(:status){code} }
          })
        end

        self.singleton_class.class_eval do
          define_method(:"#{name}!") do |*args|
            args.unshift ":" unless args.empty?
            raise self.const_get(error_class_name), "#{name}#{args.join " "}"
          end
        end
      end
    end
  end
end
