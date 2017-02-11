require 'ostruct'

module Spacer
  module CSharp
    def self.count_bol_spaces_and_tabs(lines)
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

    def self.untabify(lines, tabsize)
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
            num_spaces = tabsize - (new_line.length % tabsize)

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

    def self.tabify(lines, tabsize, round_down_spaces)
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

            new_line += "\t" * (num_bol_spaces / tabsize)

            if !round_down_spaces
              new_line += " " * (num_bol_spaces % tabsize)
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

  end
end
