module Rocker
  module Instructions
    class Entrypoint < Base
      attr_reader :entrypoint

      def initialize(entrypoint)
        @entrypoint = entrypoint
      end

      def run_config(config)
        run_config = config.dup
        run_config['Entrypoint'] = entrypoint.is_a?(String) ? entrypoint.split : entrypoint
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# ENTRYPOINT #{entrypoint.to_json}"
        ]

        run_config
      end
    end
  end
end

Rocker::DSL.register(:entrypoint, Rocker::Instructions::Entrypoint)
