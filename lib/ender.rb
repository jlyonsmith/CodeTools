require 'ostruct'
require 'optparse'
require 'colorize'

$VERSION='4.2.1-20151227.0'

class Ender

  def parse(args)
    options = OpenStruct.new
    options.output_filename = ''
    options.input_filename = ''
    options.convert_mode = nil

    opt_parser = OptionParser.new do |opts|
      opts.banner = %Q(Ender Line Ending Fixer. Version #{$VERSION}
Copyright (c) John Lyon-Smith, 2015.
Usage:            #{File.basename(__FILE__)} [options]
)
      opts.separator %Q(Options:
)

      opts.on("-o", "--output FILE", String, "The output file.  Default is the same as the input file.") do |file|
        options.output_filename = File.expand_path(file)
      end

      opts.on("-m", "--mode MODE", [:auto, :lf, :cr, :crlf], "The convert mode (auto, cr, lf, crlf)",
              "(auto) will use the most commonly occurring ending.",
              "Updates will only be done when this argument is given.") do |mode|
        options.convert_mode = mode
      end

      opts.on_tail("-?", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options.input_filename = ARGV.pop
    raise 'Need to specify a file to process' unless options.input_filename
    options.input_filename = File.expand_path(options.input_filename)
    options
  end

  def execute
    options = self.parse(ARGV)

    if !File.exist?(options.input_filename)
      error "File #{options.input_filename} does not exist"
      exit
    end

    if options.output_filename.length == 0
      options.output_filename = options.input_filename
    end

    # Read the entire file and determine all the different line endings
    file_contents = IO.read(options.input_filename)
    num_cr = 0
    num_lf = 0
    num_crlf = 0
    num_lines = 1

    i = 0
    while i < file_contents.length do
      c = file_contents[i]

      if c == "\r"
        if i < file_contents.length - 1 and file_contents[i + 1] == "\n"
          num_crlf += 1
          i += 1
        else
          num_cr += 1
        end

        num_lines += 1
      elsif c == "\n"
        num_lf += 1
        num_lines += 1
      end
      i += 1
    end

    num_endings = (num_cr > 0 ? 1 : 0) + (num_lf > 0 ? 1 : 0) + (num_crlf > 0 ? 1 : 0)
    le = num_endings > 1 ? :mixed : num_cr > 0 ? :cr : num_lf > 0 ? :lf : :crlf
    msg = "\"#{options.input_filename}\", #{le.to_s}, #{num_lines} lines"

    if options.convert_mode == nil
      puts msg
      exit
    end

    if options.convert_mode == :auto
      # Find the most common line ending and make that the automatic line ending
      auto_line_ending = :lf
      n = num_lf

      if num_crlf > n
        auto_line_ending = :crlf
        n = num_crlf
      end

      if num_cr > n
        auto_line_ending = :cr
      end

      options.convert_mode = auto_line_ending
    end

    new_num_lines = 1

    if (options.convert_mode == :cr and num_cr + 1 == num_lines) or
        (options.convert_mode == :lf and num_lf + 1 == num_lines) or
        (options.convert_mode == :crlf and num_crlf + 1 == num_lines)
      # We're not changing the line endings; nothing to do
      new_num_lines = num_lines
    else
      newline_chars =
        options.convert_mode == :cr ? "\r" :
        options.convert_mode == :lf ? "\n" :
        "\r\n"

      file = nil

      begin
        file = File.new(options.output_filename, 'w')

        i = 0
        while i < file_contents.length
          c = file_contents[i]

          if c == "\r"
            if i < file_contents.length - 1 && file_contents[i + 1] == "\n"
              i += 1
            end

            new_num_lines += 1
            file.write(newline_chars)
          elsif c == "\n"
            new_num_lines += 1
            file.write(newline_chars)
          else
            file.write(c)
          end

          i += 1
        end
      rescue Exception => e
        error "unable to write #{options.output_filename}. #{e.to_s}"
        exit
      ensure
        file.close() unless !file
      end

      msg += " -> \"#{options.output_filename}\", #{options.convert_mode.to_s}, #{new_num_lines} lines"
    end

    puts msg
  end


  def error(msg)
    STDERR.puts "error: #{msg}".colorize(:red)
  end

end
