require 'nokogiri'
require_relative '../core_ext.rb'

class BadVersionFile < StandardError; end

class VersionFile
  attr_reader :tags

  def initialize(io)
    if io
      @doc = Nokogiri::XML(io, &:noblanks)

      unless @doc.root.name == 'Version'
        raise BadVersionFile, 'Root element must be Version'
      end
    else
      @doc = Nokogiri::XML::Document.new
      @doc.root.add_child(Nokogiri::XML::Element.new('Version', @doc))
    end

    add_attribute @doc.root, :BuildValueType => :JDate
    add_child_list_element @doc.root, :Files, :Tags
    add_child_element tags_element,
      :Major => 1, :Minor => 0, :Build => 0, :Patch => 0, :Revision => 0, :TimeZone => 'UTC'
    add_child_element tags_element, {:StartYear => TZInfo::Timezone.get(self.time_zone).now.year}
  end

  def add_attribute(parent_node, attr_definitions)
    attr_definitions.each { |attr_symbol, attr_default|
      method_name = attr_symbol.to_s.underscore
      unless parent_node[attr_symbol]
        parent_node[attr_symbol] = attr_default
      end
      define_singleton_method(method_name.to_sym) {
        parent_node[attr_symbol].to_sym
      }
      define_singleton_method((method_name + '=').to_sym) { |value|
        parent_node[attr_symbol] = value.to_s
      }
    }
  end

  def add_child_list_element(parent_element, *element_symbols)
    element_symbols.each { |element_symbol|
      name = element_symbol.to_s
      elem = parent_element.at(name)
      unless elem
        elem = parent_element.add_child(Nokogiri::XML::Element.new(name, @doc))
      end

      method_name = name.underscore + '_element'
      define_singleton_method(method_name.to_sym) {
        elem
      }
    }
  end

  def add_child_element(parent_element, element_definitions)
    element_definitions.each { |element_symbol, element_default|
      name = element_symbol.to_s
      elem = parent_element.at(name)
      unless elem
        elem = parent_element.add_child(Nokogiri::XML::Element.new(name, @doc))
        elem.content = element_default.to_s
      end

      method_name = name.underscore
      case element_default
        when Fixnum
          define_singleton_method(method_name.to_sym) {
            Integer(elem.content)
          }
        when String
          define_singleton_method(method_name.to_sym) {
            elem.content.to_s
          }
      end
      define_singleton_method((method_name + '=').to_sym) { |value|
        elem.content = value.to_s
      }
    }
  end

  def write_to(io)
    @doc.write_xml_to(io, :indent_text => ' ', :indent => 2)
  end

  def tags
    Hash[tags_element.children.select {|node| node.name != 'text'}.map {|node| [node.name.to_sym, node.content]}]
  end
  def files
    files_element.children.select {|node| node.name != 'text'}.map {|node| node.content}
  end

end
