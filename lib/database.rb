require_relative "data_source"

class Database
  attr_accessor :sources

  def initialize(xml_doc)
    @xml_doc = xml_doc
    @sources = []
  end

  def connections
    connections = {}

    @xml_doc.xpath("//Dictionary/Databases/*").each do |database|
      name = database.xpath("Name").text
      connection_string = database.xpath("ConnectionString").text

      connections[name] = connection_string
    end

    return connections
  end

  def data_sources
    data_sources = {}

    data_source_container = @xml_doc.xpath("//DataSources")

    data_source_container.xpath("./*").each do |data_source_node|
      source = DataSource.new(data_source_node)

      data_source = {}
      data_source["columns"] = source.columns
      data_source["sql"]     = source.query

      data_sources[source.name] = data_source
    end

    return data_sources
  end
end
