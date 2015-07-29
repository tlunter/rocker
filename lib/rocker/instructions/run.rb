module Rocker
  module Instructions
    class Run
      attr_reader :cmd

      def initialize(cmd)
        @cmd = cmd
      end

      def run(image)
        container = create_container(image)
        container.start
        container.streaming_logs(stdout: true, stderr: true, follow: true) do |stream, chunk|
          puts "#{stream}: #{chunk}"
        end
        container.wait
        container.commit
      end

      def create_container(image)
        @container ||= Docker::Container.create(
          'Image' => image.id,
          'Cmd' => cmd
        )
      end
    end
  end
end
