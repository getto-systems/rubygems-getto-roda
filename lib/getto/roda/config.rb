require "ostruct"

module Getto
  module Roda
    class Config
      def self.configure(schema)
        c = Struct.new
        yield c
        c.freeze
        c.tap do
          Checker.new(schema).validate!(c)
        end
      end

      class Struct < OpenStruct
        def group(name)
          self[name] ||= Struct.new
          yield self[name]
        end

        def freeze
          each_pair.each do |_,value|
            value.freeze
          end
          super
        end
      end

      class Checker
        def initialize(schema)
          @schema = schema
        end

        def validate!(config)
          validate_config!([], @schema, config)
        end

        private

          def validate_config!(path, schema, config)
            unless config
              raise "#{path.join("/")} is nil"
            end

            schema.each do |key,spec|
              case spec
              when ::Class
                unless config[key].is_a?(spec)
                  raise "#{full_path(path,key)} is not a #{spec}"
                end
              when ::Array
                unless spec.include?(config[key])
                  raise  "#{full_path(path,key)} is not in [#{spec.join(",")}]"
                end
              when ::Hash
                validate_config!([*path,key], spec, config[key])
              else
                # :nocov:
                raise "invalid schema: #{full_path(path,key)} : #{spec}"
                # :nocov:
              end
            end
          end

          def full_path(path,key)
            [*path, key].join("/")
          end
      end
    end
  end
end
