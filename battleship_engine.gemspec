# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "battleship_engine/version"

Gem::Specification.new do |s|
  s.name        = "battleship_engine"
  s.version     = BattleshipEngine::VERSION
  s.authors     = ["Mike Weber"]
  s.email       = ["mike@weberapps.com"]
  s.homepage    = ""
  s.summary     = %q{Battleship}
  s.description = %q{Game rules for the game Battleship}
  
  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- spec/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # specify any dependencies here; for example:
  # s.add_development_dependency "rspec"
  # s.add_runtime_dependency "rest-client"
end
