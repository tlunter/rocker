module Rocker
  module Instructions
    # Workdir instruction mimics Dockerfile's WORKDIR
    class Workdir < Base
      attr_reader :workdir

      def initialize(workdir)
        @workdir = workdir
      end

      def run_config(config)
        run_config = config.dup
        run_config['WorkingDir'] = workdir
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# WORKDIR #{workdir}"
        ]

        run_config
      end
    end
  end
end

Rocker::DSL.register(:workdir, Rocker::Instructions::Workdir)
