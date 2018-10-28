require "test_helper"

require "getto/roda/config"

module Getto::Roda::ConfigTest
  describe Getto::Roda::Config do
    describe "configure" do
      it "create frozen OpenStruct when valid config" do
        config =
          Getto::Roda::Config.configure(
            name: String,
            key: {
              array_value: Array,
              hash_value: Hash,
            },
          ) do |c|
            c.name = "Name"
            c.group :key do |sub|
              sub.array_value = [:a, :b, :c]
              sub.hash_value = {
                a: :b,
                c: :d,
              }
            end
          end

        assert_equal(config.name, "Name")
        assert_equal(config.key.array_value, [:a, :b, :c])
        assert_equal(config.key.hash_value, {a: :b, c: :d})

        assert(config.name.frozen?)
        assert(config.key.array_value.frozen?)
        assert(config.key.hash_value.frozen?)
      end

      it "raises error when invalid config : is not a Class" do
        assert_raises RuntimeError do
          Getto::Roda::Config.configure(
            name: String,
          ) do |c|
            c.name = 10
          end
        end
      end

      it "raises error when invalid config : is not in Array" do
        assert_raises RuntimeError do
          Getto::Roda::Config.configure(
            name: [:name1, :name2],
          ) do |c|
            c.name = :name
          end
        end
      end

      it "raises error when invalid config : missing key" do
        assert_raises RuntimeError do
          Getto::Roda::Config.configure(
            name: String,
            key: Integer,
          ) do |c|
            c.name = "Name"
          end
        end
      end

      it "raises error when nil entry" do
        assert_raises RuntimeError do
          Getto::Roda::Config.configure(
            config: {
              name: String,
            },
          ) do |c|
          end
        end
      end
    end
  end
end
