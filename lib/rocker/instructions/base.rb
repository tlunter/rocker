module Rocker
  module Instructions
    # Base instruction handles default methods
    class Base
      include Rocker::Util::LogHelper

      def run(config)
        container = run_container(config)
        commit(config, container)
      end

      def run_config(config)
        config.dup
      end

      def run_container(config)
        container = create_container(config)
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

      def create_container(config)
        @container ||= Docker::Container.create(config)
      end

      def commit(config, container)
        config['Cmd'] = ['/bin/bash']
        image = container.commit('run' => config)
        config['Image'] = image.id

        config
      end
    end
  end
end

