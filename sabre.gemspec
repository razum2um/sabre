# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "sabre/version"

Gem::Specification.new do |s|
  s.name        = "sabre"
  s.version     = Sabre::VERSION
  s.authors     = ["John Perkins"]
  s.email       = ["jeperkins4@gmail.com"]
  s.homepage    = "http://github.com/jeperkins4/sabre"
  s.summary     = %q{Provides utilities for sending requests and receiving responses from Sabre Travel SOAP-based web services.}
  s.description = s.summary 

  s.rubyforge_project = "sabre"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

	s.add_development_dependency 'rspec'
#	s.add_development_dependency 'ruby-debug19'
	s.add_development_dependency 'ffaker'
        s.add_development_dependency 'mocha'
	s.add_runtime_dependency('savon','>= 0.9.7')
	s.add_runtime_dependency('activesupport')

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
