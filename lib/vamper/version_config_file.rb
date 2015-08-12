require 'nokogiri'
require 'core_ext.rb'

class VersionConfigFile
  def initialize(io, tags)
    doc = Nokogiri::XML(io)

    @file_types = []
    doc.xpath('/VersionConfig/FileType').each do |node|
      file_type_struct = Struct.new(:name, :file_specs, :updates, :write)
      search_replace_struct = Struct.new(:search, :replace)
      file_type = file_type_struct.new
      file_type.name = node.name
      file_type.file_specs = node.xpath('FileSpec').map { |sub_node|
        Regexp.new('^' + Regexp::escape(sub_node.text).gsub('\\*', '.*').gsub('\\?', '.') + '$')
      }
      update_node_set = node.xpath('Update')
      if update_node_set
        file_type.updates = update_node_set.map { |sub_node|
          s_and_r = search_replace_struct.new(
            %r(#{sub_node.at_xpath('Search').text.gsub(/\(\?'(\w+)'/, '(?<\\1>')}),
            sub_node.at_xpath('Replace').text.replace_tags(tags))
        }
      end
      write_node = node.at_xpath('Write')
      if write_node
        file_type.write = write_node.text.replace_tags(tags)
      end
      @file_types.push(file_type)
    end
  end

  attr_reader :file_types
end
