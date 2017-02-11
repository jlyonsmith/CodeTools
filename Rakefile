task :default => :test

VERSION = '5.0.1'
BUILD = '20170211.3'
TOOL = 'code-tools'

task :test do
  Dir.glob('./test/test_*.rb').each { |file| require file}
end

task :vamper do
  `bundle exec vamper -u`
  `git add :/`
  `git commit -m 'Update version info'`
  puts "Updated version"
end

task :release do
  `git tag -a 'v#{VERSION}' -m 'Release v#{VERSION}-#{BUILD}'`
  puts "Pushing tags to GitHub..."
  `git push --follow-tags`
  `rm *.gem`
  `gem build #{TOOL}.gemspec`
  puts "Pushing gem..."
  `gem push #{TOOL}-#{VERSION}.gem`
end
