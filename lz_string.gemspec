require File.expand_path("../lib/lz_string/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "lz_string"
  s.version     = LZString::VERSION
  s.licenses    = ["MIT"]
  s.authors     = ["Altivi"]
  s.email       = ["altivi.prog@gmail.com"]
  s.homepage    = "https://github.com/Altivi/lz-string"
  s.summary     = "Ruby implementation of LZ-String compression algorithm"
  s.description = s.summary
  s.files       = Dir["{lib}/**/*", "README.md"]

  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "pry"
  s.add_development_dependency "colorize"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov-text"
end
