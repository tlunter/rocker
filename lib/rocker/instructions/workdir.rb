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
        run_config['WorkingDir'] = cleaned_workdir
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# WORKDIR #{cleaned_workdir}"
        ]

        run_config
      end

      def cleaned_workdir
        if workdir.end_with?('/')
          workdir[0..-2]
        else
          workdir
        end
      end
    end
  end
end

Rocker::DSL.register(:workdir, Rocker::Instructions::Workdir)
