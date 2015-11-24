module Rocker
  # DSL methods to parse the Rockerfile
  module DSL
    def instructions
      @instructions ||= []
    end

    def from(*args)
      instructions << Instructions::From.new(*args)
    end

    def run(*args)
      instructions << Instructions::Run.new(*args)
    end

    def env(*args)
      instructions << Instructions::Env.new(*args)
    end

    def add(*args)
      instructions << Instructions::Add.new(*args)
    end
  end
end
