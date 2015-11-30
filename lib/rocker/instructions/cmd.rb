module Rocker
  module Instructions
    # Cmd instruction mimics Dockerfile's CMD
    class Cmd
      attr_reader :cmd

      def initialize(cmd)
        @cmd = cmd
      end

      def run(config)
        container = run_container(config)
        commit(config, container)
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

      def run_container(config)
        container = create_container(config)
        container.start
        container.streaming_logs(
          stdout: true, stderr: true, follow: true
        ) do |stream, chunk|
          Rocker.logger.debug("#{stream}: #{chunk}")
        end
        container.wait
        container
      end

      def create_container(config)
        @container ||= Docker::Container.create(config)
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
