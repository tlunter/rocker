module Rocker
  module Instructions
    class Run
      attr_reader :cmd

      def initialize(cmd)
        @cmd = cmd
      end

      def run(config)
        run_config = config.dup
        run_config['Cmd'] = cmd

        container = run_container(run_config)
        commit(config, container)
      end

      def run_container(config)
        container = create_container(config)
        container.start
        container.streaming_logs(stdout: true, stderr: true, follow: true) do |stream, chunk|
          puts "#{stream}: #{chunk}"
        end
        container.wait
        container
      end

      def commit(config, container)
        image = container.commit
        config['Image'] = image.id

        config
      end

      def create_container(config)
        @container ||= Docker::Container.create(config)
      end
    end
  end
end
