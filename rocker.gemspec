# -*- encoding: utf-8 -*-
lib_dir = File.join(Dir.pwd, 'lib')
$LOAD_PATH.unshift(lib_dir) unless $LOAD_PATH.include?(lib_dir)
require 'rocker/version'
require 'English'

Gem::Specification.new do |gem|
  gem.authors       = ['Todd Lunter']
  gem.email         = %w(tlunter@gmail.com)
  gem.description   = 'A Dockerfile replacement'
  gem.summary       = 'Replaces the Dockerfile build'
  gem.homepage      = 'https://github.com/tlunter/rocker'
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.split($OUTPUT_RECORD_SEPARATOR)
  gem.executables   = gem.files.grep(%r{^bin/}).map { |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = 'rocker'
  gem.require_paths = %w(lib)
  gem.version       = Rocker::VERSION
  gem.add_dependency 'docker-api', '>= 1.23.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'simplecov'
end
