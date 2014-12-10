require_relative "data_source"

class Database
  attr_accessor :sources, :connections

  def initialize(xml_doc)
    @xml_doc     = xml_doc
    @sources     = get_data_sources
    @connections = get_connections
  end

  def get_connections
    connections = {}

    @xml_doc.xpath("//Dictionary/Databases/*").each do |database|
      name              = database.xpath("Name").text
      connection_string = database.xpath("ConnectionString").text

      conn_details = {}

      connection_string.split(";").each do |x|
        conn_details[x.split("=")[0]] = x.split("=")[1]
      end

      connections[name] = Mysql2::Client.new(
        :host     => conn_details["Server"],
        :username => conn_details["User"],
        :password => conn_details["Password"],
        :database => conn_details["Database"]
      )
    end

    return connections
  end

  def get_data_sources
    sources = {}

    data_source_container = @xml_doc.xpath("//DataSources")

    data_source_container.xpath("./*").each do |data_source_node|
      source = DataSource.new(data_source_node)
      sources[source.name] = source
    end

    return sources
  end

  def connection_from_source(source_name)
    @connections[@sources[source_name].connection_name]
  end
end
