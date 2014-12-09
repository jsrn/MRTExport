require 'nokogiri'

class DataSource
  attr_accessor :name, :connection_name, :columns, :query

  def initialize(xml_node=nil)
    if xml_node
      @xml_node = xml_node

      @name            = xml_node.xpath("Name").text
      @connection_name = xml_node.xpath("NameInSource").text
      @columns         = get_columns
      @query           = xml_node.xpath("SqlCommand").text.gsub("\n", " ")
    end
  end

  def get_columns
    column_container = @xml_node.xpath("Columns")

    columns = []
    column_container.xpath("./value").each do |column|
      columns << column.text.split(",")[0]
    end

    columns
  end

  def inspect
    "NAME: #{@name}\nCONN: #{@connection_name}\nCOLS: #{@columns}\nQUER: #{@query}"
  end
end
