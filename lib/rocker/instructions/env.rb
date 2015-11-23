module Rocker
  module Instructions
    class Env
      attr_reader :env_variable

      def initialize(*env_variable)
        @env_variable = Array(env_variable).join('=')
      end

      def run(config)
        config
      end

      def run_config(config)
        config = config.dup
        config['Env'] ||= []
        config['Env'] = config['Env'].dup + [*env_variable]

        config
      end
    end
  end
end

