class String
  def underscore
    self.gsub(/::/, '/').
        gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2').
        gsub(/([a-z\d])([A-Z])/,'\1_\2').
        tr('-', '_').
        downcase
  end

  def replace_tags(tags)
    str = self
    tags.each { |name, value|
      str = str.gsub(%r(\$\{#{name.to_s}\})m, value)
    }
    str
  end

  def replace_tags!(tags)
    tags.each { |name, value|
      self.gsub!(%r(\$\{#{name.to_s}\})m, value)
    }
    self
  end

  # colorization
  def colorize(color_code)
    "\e[#{color_code}m#{self}\e[0m"
  end

  def red
    colorize(31)
  end

  def green
    colorize(32)
  end

  def yellow
    colorize(33)
  end

  def blue
    colorize(34)
  end

  def pink
    colorize(35)
  end

  def light_blue
    colorize(36)
  end

end
