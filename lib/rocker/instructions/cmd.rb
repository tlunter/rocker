module Rocker
  module Instructions
    # Cmd instruction mimics Dockerfile's CMD
    class Cmd < Base
      attr_reader :cmd

      def initialize(cmd)
        @cmd = cmd
      end

      def run_config(config)
        run_config = config.dup
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# CMD #{cmd}"
        ]

        run_config
      end

      def commit(config, container)
        config['Cmd'] = cmd
        image = container.commit('run' => config)
        config['Image'] = image.id

        config
      end
    end
  end
end

Rocker::DSL.register(:cmd, Rocker::Instructions::Cmd)
