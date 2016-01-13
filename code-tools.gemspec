Gem::Specification.new do |s|
  s.name = 'code-tools'
  s.version = '5.0.0'
  s.date = '2016-01-13'
  s.summary = "Source code tools"
  s.description = "Tools for source code maintenance, including version stamping, line endings and tab/space conversion."
  s.authors = ["John Lyon-smith"]
  s.email = "john@jamoki.com"
  s.files = `git ls-files -- lib/*`.split("\n")
  s.executables = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.homepage = 'http://rubygems.org/gems/code_tools'
  s.license  = 'MIT'
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency "tzinfo", ["~> 1.2"]
  s.add_runtime_dependency "nokogiri", ["~> 1.6"]
  s.add_runtime_dependency "methadone", ["~> 1.9"]
end
