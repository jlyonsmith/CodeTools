# Source Code Tools

A collection of useful command line development tools for general source code maintenance.  They are written in [Ruby](https://www.ruby-lang.org/en/) for maximum portability.  I use [RubyMine](https://www.jetbrains.com/ruby/) for writing and debugging them, but it's not required.

- __vamper__ updates file and product version numbers across a variety of different file types
- __ender__ reports on and fixes line endings in text files
- __spacer__ reports on and fixes initial spaces and tabs in source code and other text files

To install the latest version of [code_tools](https://rubygems.org/gems/code_tools) simply run:

```bash
gem install code_tools
```

## Debugging

Because of the directory layout, running the tools from the command line requires a little more effort:

```bash
ruby -e 'load($0=ARGV.shift);Vamper.new.execute' -- lib/vamper.rb --help
```
