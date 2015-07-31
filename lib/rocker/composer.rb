module Rocker
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

    class Store
      include Rocker::DSL

      def compose
        instructions.reduce(nil) do |config, instruction|
          puts instruction.class.name
          config = instruction.run(config)
          puts "Image ID: #{config['Image']}"

          config
        end
      end
    end
  end
end
