module Rocker
  module Instructions
    class Expose < Base
      attr_reader :ports

      def initialize(ports)
        @ports = Array(ports)
      end

      def run_config(config)
        run_config = config.dup

        run_config['ExposedPorts'] ||= {}
        run_config['ExposedPorts'].merge!(exposed_ports)
        run_config['Cmd'] = [
          '/bin/sh',
          '-c',
          "# EXPOSE #{ports.to_json}"
        ]

        run_config
      end

      def exposed_ports
        ports.flat_map(&method(:split_port_and_proto))
          .map { |port| [port, {}] }
          .to_h
      end

      def split_port_and_proto(binding)
        ports, _, proto = binding.rpartition("/")

        if ports.nil?
          ports, proto = proto, 'tcp'
        end

        ports = parse_ports(ports)
        ports.map { |p| "#{p}/#{proto}" }
      end

      def parse_ports(port)
        ip, host, container = port.split(":")
        if host.nil? && container.nil?
          ip, container = container, ip
        elsif container.nil?
          ip, host, container = container, ip, host
        end

        raise "Must supply container port for config: `expose #{ports.inspect}`" if container.nil?

        lowContainerPort, highContainerPort = parse_port_range(container)

        (lowContainerPort .. highContainerPort).to_a
      end

      def part_port_range(port)
        if port.include?("-")
          low, high = port.split("-", 1).map { |i| Integer(i) }
        else
          low = high = Integer(port)
        end
      end
    end
  end
end

Rocker::DSL.register(:expose, Rocker::Instructions::Expose)
