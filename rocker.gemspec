# -*- encoding: utf-8 -*-
$LOAD_PATH.unshift(File.join(Dir.pwd, 'lib')) unless $LOAD_PATH.include?(File.join(Dir.pwd, 'lib'))
require 'rocker/version'

Gem::Specification.new do |gem|
  gem.authors       = ["Todd Lunter"]
  gem.email         = %w{tlunter@gmail.com}
  gem.description   = %q{A Dockerfile replacement}
  gem.summary       = %q{Replaces the Dockerfile build buy makes it more extensible}
  gem.homepage      = 'https://github.com/tlunter/rocker'
  gem.license       = 'MIT'
  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "rocker"
  gem.require_paths = %w{lib}
  gem.version       = Rocker::VERSION
  gem.add_dependency 'docker-api', '>= 1.23.0'
  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'rspec', '~> 3.0'
  gem.add_development_dependency 'rubocop'
  gem.add_development_dependency 'pry'
  gem.add_development_dependency 'simplecov'
end

