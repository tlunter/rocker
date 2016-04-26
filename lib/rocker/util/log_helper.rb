module Rocker
  module Util
    module LogHelper
      def self.included(base)
        base.extend(ClassMethods)
      end

      module ClassMethods
        def log_prefix(prefix = nil)
          if prefix.nil?
            @log_prefix
          else
            @log_prefix = prefix
          end
        end

        def tagged(prefix)
          Rocker.logger.context << prefix
          yield
        ensure
          Rocker.logger.context.reject! { |i| i === prefix }
        end

        [:debug, :error, :fatal, :info, :warn].each do |method|
          define_method(method) do |*args, &block|
            tagged(log_prefix) do
              Rocker.logger.send(method, *args, &block)
            end
          end
        end
      end

      def tagged(*args, &block)
        self.class.tagged(*args, &block)
      end

      [:debug, :error, :fatal, :info, :warn].each do |method|
        define_method(method) do |*args, &block|
          self.class.send(method, *args, &block)
        end
      end
    end
  end
end
