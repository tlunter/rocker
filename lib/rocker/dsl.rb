module Rocker
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
  end
end
