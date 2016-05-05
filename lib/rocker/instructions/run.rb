module Rocker
  module Instructions
    # Run instruction mimics Dockerfile's RUN
    class Run < Base
      attr_reader :cmd

      def initialize(cmd)
        @cmd = cmd
      end

      def run_container(config)
        runnable_config = config.dup
        container = super(runnable_config.merge('Entrypoint' => []))
        container.start

        container.streaming_logs(
          stdout: true, stderr: true, follow: true
        ) do |stream, chunk|
          debug(" -> #{stream}: #{chunk.chomp}")
        end

        exit_status = (container.wait || {})['StatusCode']
        fail "Command returned non-zero exit status: #{exit_status}" \
          unless exit_status && exit_status.zero?

        container
      end

      def run_config(config)
        run_config = config.dup
        run_config['Cmd'] = cmd.is_a?(String) ? cmd.split : cmd

        run_config
      end
    end
  end
end

Rocker::DSL.register(:run, Rocker::Instructions::Run)
