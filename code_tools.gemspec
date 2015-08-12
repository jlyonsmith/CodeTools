Gem::Specification.new do |s|
  s.name        = 'code_tools'
  s.version     = '4.0.0-20150811.0'
  s.summary     = "Source code tools"
  s.description = "Tools for source code maintenance, including version stamping, line endings and tab/space conversion."
  s.authors     = ["John Lyon-smith"]
  s.files       = [
    "lib/vamper.rb",
    "lib/vamper/default.version.config",
    "lib/vamper/version_config_file.rb",
    "lib/vamper/version_file.rb"]
  s.homepage    =
    'http://rubygems.org/gems/code_tools'
  s.license       = 'MIT'
  s.required_ruby_version = '~> 2.0'
  s.add_runtime_dependency "tzinfo", ["~> 1.2"]
  s.add_runtime_dependency "nokogiri", ["~> 1.6"]
end
