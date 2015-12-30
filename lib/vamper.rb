require 'tzinfo'
require 'nokogiri'
require 'ostruct'
require 'optparse'
require 'colorize'
require_relative './vamper/version_file.rb'
require_relative './vamper/version_config_file.rb'
require_relative './core_ext.rb'

$VERSION='4.2.0-20151225.0'

class Vamper

  def parse(args)
    options = OpenStruct.new
    options.do_update = false
    options.version_file_name = ''

    opt_parser = OptionParser.new do |opts|
      opts.banner = %Q(Vamper Version Stamper. Version #{$VERSION}
Copyright (c) John Lyon-Smith, 2016.
Usage:            #{File.basename(__FILE__)} [options]
)
      opts.separator %Q(Options:
)

      opts.on("-u", "--update", "Increment the build number and update all files") do |update|
        options.do_update = update
      end

      opts.on_tail("-?", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options
  end

  def execute
    options = self.parse(ARGV)

    if options.version_file_name.length == 0
      find_version_file options
    end

    options.version_file_name = File.expand_path(options.version_file_name)

    project_name = File.basename(options.version_file_name, '.version')
    version_config_file_name = "#{File.dirname(options.version_file_name)}/#{project_name}.version.config"

    puts "Version file is '#{options.version_file_name}'"
    puts "Version config is '#{version_config_file_name}'"
    puts "Project name is '#{project_name}'"

    if File.exists?(options.version_file_name)
      version_file = VersionFile.new(File.open(options.version_file_name))
    else
      verson_file = VersionFile.new
    end

    tags = version_file.tags
    now = TZInfo::Timezone.get(version_file.time_zone).now

    case version_file.build_value_type
      when :JDate
        build = get_jdate(now, version_file.start_year)

        if version_file.build != build
          version_file.revision = 0
          version_file.build = build
        else
          version_file.revision += 1
        end
      when :Incremental
        version_file.build += 1
        version_file.revision = 0
      else # :FullDate
        build = get_full_date(now)

        if version_file.build != build
          version_file.revision = 0
          version_file.build = build
        else
          version_file.revision += 1
        end
        build_str = build.to_s
        tags[:DashBuild] = build_str[0..3] + '-' + build_str[4..5] + '-' + build_str[6..7]
    end

    puts 'Version data is:'
    tags.each { |key, value|
      puts "  #{key}=#{value}"
    }

    if options.do_update
      puts 'Updating version information:'
    end

    unless File.exists?(version_config_file_name)
      FileUtils.cp(File.join(File.dirname(__FILE__), 'default.version.config'), version_config_file_name)
    end

    version_config_file = VersionConfigFile.new(File.open(version_config_file_name), tags)
    file_list = version_file.files.map { |file_name| file_name.replace_tags!(tags) }

    file_list.each do |file_name|
      path = File.expand_path(File.join(File.dirname(options.version_file_name), file_name))
      path_file_name = File.basename(path)
      match = false

      for file_type in version_config_file.file_types do
        match = file_type.file_specs.any? { |file_spec| file_spec.match(path_file_name) }
        unless match
          next
        end

        if file_type.write
          dir = File.dirname(path)
          unless Dir.exists?(dir)
            error "Directory '#{dir}' does not exist to write file ''#{path_file_name}''"
            exit(1)
          end

          if options.do_update
            IO.write(path, file_type.write)
          end
        else # !file_type.write
          if File.exists?(path)
            if options.do_update
              file_type.updates.each do |update|
                content = IO.read(path)
                # At this the only ${...} variables left in the replace strings are Before and After
                # This line converts the ${...} into \k<...>
                content.gsub!(%r(#{update.search})m, update.replace.gsub(/\${(\w+)}/,'\\\\k<\\1>'))
                IO.write(path, content)
              end
            end
          else
            error "file #{path} does not exist to update"
            exit(1)
          end
        end

        break
      end

      unless match
        error "file '#{path}' has no matching file type in the .version.config"
        exit(1)
      end

      puts path

      if options.do_update
        version_file.write_to(File.open(options.version_file_name, 'w'))
      end
    end
  end

  def find_version_file(options)
    dir = Dir.pwd

    while dir.length != 0
      files = Dir.glob('*.version')
      if files.length > 0
        options.version_file_name = files[0]
        break
      else
        if dir == '/'
          dir = ''
        else
          dir = File.expand_path('..', dir)
        end
      end
    end

    if options.version_file_name.length == 0
      error 'Unable to find a .version file in this or parent directories.'
      exit(1)
    end
  end

  def get_full_date(now)
    now.year * 10000 + now.month * 100 + now.mday
  end

  def get_jdate(now, start_year)
    (((now.year - start_year + 1) * 10000) + (now.month * 100) + now.mday).to_s
  end

  def error(msg)
    STDERR.puts "error: #{msg}".red
  end

end
