module Rocker
  module Instructions
    # Env instruction mimics Dockerfile's ENV
    class Env < Base
      attr_reader :env_variable

      def initialize(*env_variable)
        @env_variable = Array(env_variable).join('=')
      end

      def run_config(config)
        config = config.dup
        config['Env'] ||= []
        config['Env'] = config['Env'].dup + [*env_variable]
        config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# ENV #{[*env_variable]}"
        ]

        config
      end
    end
  end
end

Rocker::DSL.register(:env, Rocker::Instructions::Env)
