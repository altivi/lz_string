require File.expand_path("../lib/lz_string/version", __FILE__)

Gem::Specification.new do |s|
  s.name        = "lz_string"
  s.version     = LZString::VERSION
  s.licenses    = ["MIT"]
  s.authors     = ["Altivi"]
  s.email       = ["altivi.prog@gmail.com"]
  s.homepage    = "https://github.com/altivi/lz_string"
  s.summary     = "Ruby implementation of LZ-String compression algorithm"
  s.description = "A full Ruby port of lz-string (JavaScript), with the same results for every input, emoji too: " \
                  "raw, Base64, URI-safe, UTF-16, Uint8Array and custom alphabets, and the same command line tool. " \
                  "It passes the test suite of lz-string itself."
  s.metadata    = {
    "source_code_uri" => "https://github.com/altivi/lz_string",
    "changelog_uri" => "https://github.com/altivi/lz_string/blob/master/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/altivi/lz_string/issues",
  }
  s.files       = Dir["{lib,exe}/**/*", "README.md", "CHANGELOG.md", "LICENSE"]
  s.bindir      = "exe"
  s.executables = ["lz_string"]
  s.required_ruby_version = ">= 2.7"

  s.add_development_dependency "rake"
  s.add_development_dependency "yard"
  s.add_development_dependency "rspec"
  s.add_development_dependency "rspec_junit_formatter"
  s.add_development_dependency "pry"
  s.add_development_dependency "colorize"
  s.add_development_dependency "simplecov"
  s.add_development_dependency "simplecov-rcov-text"
end
