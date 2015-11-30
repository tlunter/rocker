module Rocker
  module Instructions
    # Run instruction mimics Dockerfile's RUN
    class Run
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
        run_config['Cmd'] = cmd.is_a?(String) ? cmd.split : cmd

        run_config
      end

      def run_container(config)
        container = create_container(config)
        container.start
        Rocker.logger.debug("Running: #{cmd}")
        container.streaming_logs(
          stdout: true, stderr: true, follow: true
        ) do |stream, chunk|
          Rocker.logger.debug(" -> #{stream}: #{chunk.chomp}")
        end
        exit_status = (container.wait || {})['StatusCode']

        fail "Command returned non-zero exit status: #{exit_status}" \
          unless exit_status && exit_status.zero?

        container
      end

      def commit(config, container)
        config['Cmd'] = ['/bin/bash']
        image = container.commit('run' => config)
        config['Image'] = image.id

        config
      end

      def create_container(config)
        @container ||= Docker::Container.create(config)
      end
    end
  end
end

Rocker::DSL.register(:run, Rocker::Instructions::Run)
