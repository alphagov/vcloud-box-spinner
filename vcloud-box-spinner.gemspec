# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "provisioner/version"

Gem::Specification.new do |s|
  s.name        = "vcloud-box-spinner"
  s.version     = Provisioner::VERSION
  s.authors     = ["Garima Singh"]
  s.email       = ["igarimasingh@gmail.com"]
  s.homepage    = "https://github.com/alphagov/vcloud-box-spinner"
  s.summary     = %q{Provision servers, with vcloud API}
  s.description = %q{Create new VM and apply an opinionated set of commands to
them, using vcloud API. The vcloud-box-spinner is a thin wrapper around fog,
which enables you to be able to configure VMs with static IPs}

  s.rubyforge_project = "vcloud-box-spinner"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.license = 'MIT'

  s.add_development_dependency "rake"
  s.add_development_dependency "minitest"
  s.add_development_dependency "mocha"
  s.add_development_dependency "webmock"
  s.add_development_dependency "rspec", "~> 2.11.0"
  s.add_development_dependency "equivalent-xml", "~> 0.2.9"
  s.add_development_dependency "gem_publisher", "~> 1.3.0"
  s.add_runtime_dependency "fog", "~> 1.15.0"
  s.add_runtime_dependency "parallel"
  s.add_runtime_dependency "highline"
  s.add_runtime_dependency "nokogiri", "~> 1.5.0"
end
