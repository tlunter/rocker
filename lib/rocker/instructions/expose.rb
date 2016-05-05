module Rocker
  module Instructions
    class Expose < Base
      include Rocker::Util::LogHelper

      attr_reader :ports

      log_prefix "Expose"

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
        debug "Parsing port binding: #{binding}"
        ports, _, proto = binding.rpartition("/")

        if ports.empty?
          ports, proto = proto, 'tcp'
          debug "Did not find slash, ports: #{ports} proto: #{proto}"
        end

        ports = parse_ports(ports)
        debug "Parsed ports: #{ports}"
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

      def parse_port_range(port)
        if port.include?("-")
          low, high = port.split("-", 1).map { |i| Integer(i) }
        else
          low = high = Integer(port)
        end

        [low, high]
      end
    end
  end
end

Rocker::DSL.register(:expose, Rocker::Instructions::Expose)
