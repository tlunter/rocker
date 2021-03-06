# Gem dependencies
require 'docker'
require 'logger'
require 'digest'

# Rocker gem that builds Rockerfiles
module Rocker
  def logger
    @logger ||= Rocker::Util::Logger.new(
      defined?(Rails) ? Rails.logger : Logger.new(STDOUT)
    )
  end
  module_function :logger
end

# Gem code
require 'rocker/util'
require 'rocker/dsl'
require 'rocker/instructions'
require 'rocker/composer'
