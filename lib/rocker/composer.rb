module Rocker
  # Runs all the Rockerfile instructions via a simple interface
  class Composer
    def self.run
      new.run
    end

    attr_reader :rockerfile

    def initialize(options = {})
      @rockerfile = options[:rockerfile] || 'Rockerfile'
    end

    def run
      store = Store.new
      store.instance_eval(IO.read(@rockerfile))

      store.compose
    end

    # Contains the instructions to run
    class Store
      include Rocker::DSL
      include Rocker::Util::LogHelper

      log_prefix "Store"

      def compose
        debug('Loading cache')
        all_images

        instructions.reduce({}) do |config, instruction|
          tagged(instruction.class.name) do
            container_config = instruction.run_config(config)
            clean_config(container_config)
            find_or_run(container_config, instruction)
          end
        end
      end

      def find_or_run(container_config, instruction)
        if (image = find_in_cache(container_config))
          config = image.info['ContainerConfig']
          config['Image'] = image.id
          debug("Image ID: #{config['Image']} (cache)")
        else
          config = instruction.run(container_config)
          debug("Image ID: #{config['Image']}")
        end

        config
      end

      # Hack because docker returns `nil` versus `{}` in other parts of the API
      def clean_config(config)
        config['Labels'] ||= {}
      end

      def find_in_cache(config)
        cache_for_image(config['Image']).find do |image|
          image.info['ContainerConfig'] == config
        end
      end

      def cache_for_image(image)
        all_images
          .select { |i| i.info['ParentId'] == image }
          .map(&:refresh!)
      end

      def all_images
        @all_images ||= Docker::Image.all(all: true)
      end
    end
  end
end
