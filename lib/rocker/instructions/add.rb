module Rocker
  module Instructions
    # Add instruction mimics Dockerfile's ADD
    class Add
      attr_reader :host_path, :container_path

      def initialize(host_path, container_path)
        @host_path = host_path
        @container_path = container_path
      end

      def run(config)
        container = run_container(config)
        context.rewind
        container.archive_in_stream(container_path) { context.read }
        commit(config, container)
      end

      def run_config(config)
        run_config = config.dup
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# (nop) hash:#{hash_of_host_path}"
        ]

        run_config
      end

      def run_container(config)
        container = create_container(config)
        container.start
        container.streaming_logs(
          stdout: true, stderr: true, follow: true
        ) do |stream, chunk|
          puts "#{stream}: #{chunk}"
        end
        container.wait
        container
      end

      def context
        return @output if @output
        @output = StringIO.new

        Rocker::Util.create_relative_file_tar(host_path, @output)

        @output
      end

      def hash_of_host_path
        path = host_path
        fail "`#{path}` doesn't exist!" unless File.exist?(path)

        path += '/' if File.directory?(path) && !path.end_with?('/')

        output = StringIO.new
        Rocker::Util.create_relative_file_tar(path, output)
        sha256 = Digest::SHA256.new
        sha256 << output.string
        sha256.hexdigest
      end

      def create_container(config)
        @container ||= Docker::Container.create(config)
      end

      def commit(config, container)
        image = container.commit
        config['Image'] = image.id

        config
      end
    end
  end
end
