module Spacer
  module Text
    def self.count_bol_spaces_and_tabs(lines)
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

    def self.untabify(lines, tabsize)
      i = 0
      while i < lines.length do
        line = lines[i]
        j = 0
        new_line = ""

        while j < line.length do
          c = line[j]

          if c == "\t"
            num_spaces = tabsize - (new_line.length % tabsize)
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

    def self.tabify(lines, tabsize, round_down_spaces)
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
            new_line += "\t" * (num_bol_spaces / tabsize)

            if !round_down_spaces
              new_line += " " * (num_bol_spaces % tabsize)
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

  end
end