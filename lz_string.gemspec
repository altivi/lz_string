require File.expand_path("../lib/lz_string/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "lz_string"
  s.version     = LZString::VERSION
  s.authors     = ["Altivi"]
  s.email       = ["altivi.prog@gmail.com"]
  s.homepage    = "https://github.com/Altivi/lz-string"
  s.summary     = "Ruby implementation of LZ-String compression algorithm"
  s.description = s.summary
  s.files       = Dir["{lib}/**/*", "README.md"]
end
