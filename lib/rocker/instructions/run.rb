module Rocker
  module Instructions
    # Run instruction mimics Dockerfile's RUN
    class Run < Base
      attr_reader :cmd

      def initialize(cmd)
        @cmd = cmd
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
