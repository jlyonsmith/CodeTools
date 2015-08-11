require 'rubygems'
require 'bundler/setup'
require 'nokogiri'
require_relative  'core_ext.rb'

class VersionConfigFile
  def initialize(io, tags)
    doc = Nokogiri::XML(io)

    @file_types = []
    doc.xpath('/VersionConfig/FileType').each { |node|
      file_type_struct = Struct.new(:name, :file_specs, :updates, :write)
      search_replace_struct = Struct.new(:search, :replace)
      file_type = file_type_struct.new
      file_type.name = node.name
      file_type.file_specs = node.xpath('FileSpec').map {|sub_node|
        Regexp.new('^' + Regexp::escape(sub_node.content).gsub('\\*', '.*').gsub('\\?', '.') + '$')
      }
      file_type.updates = node.xpath('Update').select {|sub_node|
        search_replace_struct.new(
          %r(#{sub_node.at_xpath('Search').content}),
          sub_node.at_xpath('Replace').content.replace_tags(tags))
      } rescue nil
      file_type.write = node.at_xpath('Write').content.replace_tags(tags) rescue nil
      @file_types.push(file_type)
    }
  end

  attr_reader :file_types
end