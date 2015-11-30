module Rocker
  # DSL methods to parse the Rockerfile
  module DSL
    def instructions
      @instructions ||= []
    end

    def register(word, klass)
      define_method(word) do |*args|
        instructions << klass.new(*args)
      end
    end
    module_function :register
  end
end
