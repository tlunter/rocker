module Rocker
  module Instructions
    class Volume < Base
      attr_reader :volumes

      def initialize(volumes)
        @volumes = Array(volumes)
      end

      def run_config(config)
        run_config = config.dup

        run_config['Volumes'] ||= {}
        run_config['Volumes'].merge!(formatted_volumes)
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# VOLUME #{volumes.to_json}"
        ]
      end

      def formatted_volumes
        volumes.map { |v| [v.strip, {}] }.to_h
      end
    end
  end
end

Rocker::DSL.register(:volume, Rocker::Instructions::Volume)
