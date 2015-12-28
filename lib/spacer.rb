require 'ostruct'
require 'optparse'
require 'colorize'

$VERSION='4.1.0-20151225.0'

class Spacer

  def parse(args)
    options = OpenStruct.new
    options.output_filename = ''
    options.input_filename = nil
    options.convert_mode = nil
    options.tabsize = 4
    options.round_down_spaces = false

    opt_parser = OptionParser.new do |opts|
      opts.banner = %Q(Spacer Text File Space/Tab Fixer Tool. Version #{$VERSION}
Copyright (c) John Lyon-Smith, 2015.
Usage:            #{File.basename(__FILE__)} [options]
)
      opts.separator %Q(Description:
When reporting the tool indicates beginning-of-line \(BOL\) tabs and spaces.
When replacing, all tabs not at the beginning of a line are replaced with spaces.
Spaces and tabs inside multi-line C# strings (@"...") and inside Ruby \%Q\(...\) strings
are ignored.
Note that conversion to tabs may still leave the file as mixed as some lines may have
spaces that are not a whole number multiple of the tabstop size.  In that case use the
-round option to remove smooth out the spurious spaces.

)
      opts.separator %Q(Options:
)

      opts.on("-o", "--output FILE", String, "The output file.  Default is the same as the input file.") do |file|
        options.output_filename = File.expand_path(file)
      end

      opts.on("-m", "--mode MODE", [:mixed, :tabs, :spaces], "The convert mode (mixed, tabs or spaces)",
              "Default is to just display the files current state.",
              "Updates will only be done when this argument is given.") do |mode|
        options.convert_mode = mode
      end

      opts.on("-t", "--tabsize SIZE", Integer, "Tab size. Default is 4 spaces.",
              "Default is to just display the files current state.",
              "Updates will only be done when this argument is given.") do |size|
        options.tabsize = size
      end

      opts.on("-r", "--round", "When tabifying, round BOL spaces down to an exact number of tabs.") do |round|
        options.round_down_spaces = round
      end

      opts.on_tail("-?", "--help", "Show this message") do
        puts opts
        exit
      end
    end

    opt_parser.parse!(args)
    options.input_filename = ARGV.pop
    if options.input_filename == nil
      error 'Need to specify a file to process'
      exit
    end
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

    if File.extname(options.input_filename) == '.cs'
      file_type = :csharp
    else
      file_type = :other
    end

    lines = read_file_lines(options.input_filename)

    if file_type == :csharp
      before = count_csharp_bol_spaces_and_tabs(lines)
    else
      before = count_bol_spaces_and_tabs(lines)
    end

    if options.convert_mode != nil
     if file_type == :other
       untabify(lines, options)
     else
       csharp_untabify(lines, options)
     end

     if options.convert_mode == :tabs
       if file_type == :other
         tabify(lines, options)
       else
         csharp_tabify(lines, options)
       end
     end
   end

   ws = get_whitespace_type(before)

   msg = "\"#{options.input_filename}\", #{file_type.to_s}, #{ws.to_s}"

   if options.convert_mode != nil
      if file_type == :csharp
        after = count_csharp_bol_spaces_and_tabs(lines)
      else
        after = count_bol_spaces_and_tabs(lines)
      end

      ws = get_whitespace_type(after)
      file = nil

      begin
        file = File.new(options.output_filename, 'w')

        for line in lines do
          file.write(line)
        end
      ensure
        file.close() unless file == nil
      end

      msg += " -> \"#{options.output_filename}\", #{ws.to_s}"
    end

    puts msg
  end

  def get_whitespace_type(bol)
    (bol.tabs > 0) ? (bol.spaces > 0 ? :mixed : :tabs) : :spaces
  end

  def read_file_lines(filename)
    # Read the entire file
    file_contents = File.read(filename)

    # Convert to a list of lines, preserving the end-of-lines
    lines = []
    s = 0
    i = 0

    while i < file_contents.length do
      c = file_contents[i]
      c1 = i < file_contents.length - 1 ? file_contents[i + 1] : "\0"

      if c == "\r"
        i += 1

        if c1 == "\n"
          i += 1
        end
      elsif c == "\n"
        i += 1
      else
        i += 1
        next
      end

      lines.push(file_contents[s, i - s])
      s = i
    end

    if s != i
      lines.push(file_contents[s, i - s])
    end

    lines
  end

  def count_csharp_bol_spaces_and_tabs(lines)
    bol = OpenStruct.new
    bol.tabs = 0
    bol.spaces = 0
    in_multi_line_string = false

    for line in lines do
      in_bol = true
      i = 0
      while i < line.length do
        c = line[i]
        c1 = i < line.length - 1 ? line[i + 1] : "\0"

        if in_multi_line_string and c == "\"" and c1 != "\""
          in_multi_line_string = false
        elsif c == "@" and c1 == "\""
          in_multi_line_string = true
          i += 1
        elsif in_bol and !in_multi_line_string and c == " "
          bol.spaces += 1
        elsif in_bol and !in_multi_line_string and c == "\t"
          bol.tabs += 1
        else
          in_bol = false
        end
        i += 1
      end
    end

    bol
  end

  def count_bol_spaces_and_tabs(lines)
    bol = OpenStruct.new
    bol.spaces = 0
    bol.tabs = 0

    for line in lines do
      for i in 0...line.length do
        c = line[i]

        if c == " "
          bol.spaces += 1
        elsif c == "\t"
          bol.tabs += 1
        else
          break
        end
      end
    end

    bol
  end

  def untabify(lines, options)
    i = 0
    while i < lines.length do
      line = lines[i]
      j = 0
      new_line = ""

      while j < line.length do
        c = line[j]

        if c == "\t"
          num_spaces = options.tabsize - (new_line.length % options.tabsize)
          new_line += " " * num_spaces
        else
          new_line += c
        end
        j += 1
      end

      lines[i] = new_line
      i += 1
    end
  end

  def tabify(lines, options)
    i = 0
    while i < lines.length do
      line = lines[i]
      j = 0
      bol = true
      num_bol_spaces = 0
      new_line = ""

      while j < line.length do
        c = line[j]

        if bol and c == " "
          num_bol_spaces += 1
        elsif bol and c != " "
          bol = false
          new_line += "\t" * (num_bol_spaces / options.tabsize)

          if !options.round_down_spaces
            new_line += " " * (num_bol_spaces % options.tabsize)
          end

          new_line += c
        else
          new_line += c
        end

        j += 1
      end

      lines[i] = new_line
      i += 1
    end
  end

  def csharp_untabify(lines, options)
    # Expand tabs anywhere on a line, but not inside @"..." strings
    in_multi_line_string = false

    i = 0
    while i < lines.length do
      line = lines[i]
      in_string = false
      new_line = ""
      j = 0

      while j < line.length do
        c_1 = j > 0 ? line[j - 1] : '\0'
        c = line[j]
        c1 = j < line.length - 1 ? line[j + 1] : '\0'

        raise "line #{i + 1} has overlapping regular and multiline strings" if (in_string and in_multi_line_string)

        if !in_multi_line_string and c == "\t"
          # Add spaces to next tabstop
          num_spaces = options.tabsize - (new_line.length % options.tabsize)

          new_line += " " * num_spaces
        elsif !in_multi_line_string and !in_string and c == "\""
          in_string = true
          new_line += c
        elsif !in_multi_line_string and !in_string and c == "@" and c1 == "\""
          in_multi_line_string = true
          new_line += c
          j += 1
          new_line += c1
        elsif in_string and c == "\"" and c_1 != "\\"
          in_string = false
          new_line += c
        elsif in_multi_line_string and c == "\"" and c1 != "\""
          in_multi_line_string = false
          new_line += c
        else
          new_line += c
        end

        lines[i] = new_line
        j += 1
      end
      i += 1
    end
  end

  def csharp_tabify(lines, options)
    # Insert tabs for spaces, but only at the beginning of lines and not inside @"..." or "..." strings
    in_multi_line_string = false
    i = 0

    while i < lines.length do
      line = lines[i]
      in_string = false
      bol = true
      num_bol_spaces = 0
      new_line = ""
      j = 0

      while j < line.length do
        c_1 = j > 0 ? line[j - 1] : "\0"
        c = line[j]
        c1 = j < line.length - 1 ? line[j + 1] : "\0"

        if !in_string and !in_multi_line_string and bol and c == " "
          # Just count the spaces
          num_bol_spaces += 1
        elsif !in_string and !in_multi_line_string and bol and c != " "
          bol = false

          new_line += "\t" * (num_bol_spaces / options.tabsize)

          if !options.round_down_spaces
            new_line += " " * (num_bol_spaces % options.tabsize)
          end
          # Process this character again as not BOL
          j -= 1
        elsif !in_multi_line_string and !in_string and c == '"'
          in_string = true
          new_line += c
        elsif !in_multi_line_string and !in_string and c == "@" and c1 == "\""
          in_multi_line_string = true
          new_line += c
          j += 1
          new_line += c1
        elsif in_string and c == "\"" and c_1 != "\\"
          in_string = false
          new_line += c
        elsif in_multi_line_string and c == "\"" and c1 != "\""
          in_multi_line_string = false
          new_line += c
        else
          new_line += c
        end

        lines[i] = new_line
        j += 1
      end
      i += 1
    end
  end

  def error(msg)
    STDERR.puts "error: #{msg}".colorize(:red)
  end

end
