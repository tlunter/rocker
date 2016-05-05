module Rocker
  module Instructions
    # Base instruction handles default methods
    class Base
      include Rocker::Util::LogHelper

      def run(config)
        debug "#{self.inspect}"
        container = run_container(config)
        commit(config, container)
      end

      def run_config(config)
        config.dup
      end

      def run_container(config)
        create_container(config)
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

