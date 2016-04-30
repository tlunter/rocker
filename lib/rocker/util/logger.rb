require 'logger'

module Rocker
  module Util
    class Logger
      attr_accessor :context, :wrapped_logger

      def initialize(wrapped_logger)
        @wrapped_logger = wrapped_logger
        @context = []
      end

      def setup_prefix
        original_formatter = wrapped_logger.formatter || ::Logger::Formatter.new
        wrapped_logger.formatter = proc do |severity, datetime, progname, msg|
          prefix = context.compact.map { |prefix| "[#{prefix}]" }.join
          new_msg = prefix.empty? ? msg : "#{prefix} #{msg}"
          original_formatter.call(severity, datetime, progname, new_msg)
        end

        yield
      ensure
        wrapped_logger.formatter = original_formatter
      end

      [:debug, :error, :fatal, :info, :warn].each do |method|
        define_method(method) do |msg, &block|
          setup_prefix do
            wrapped_logger.send(method, msg, &block)
          end
        end
      end
    end
  end
end
