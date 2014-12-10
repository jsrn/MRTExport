require_relative "data_source"

class Database
  attr_accessor :sources, :conns

  def initialize(xml_doc)
    @xml_doc = xml_doc
    @sources = []
    @conns   = get_connections
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

  def data_sources
    data_sources = {}

    data_source_container = @xml_doc.xpath("//DataSources")

    data_source_container.xpath("./*").each do |data_source_node|
      source = DataSource.new(data_source_node)
      @sources << source

      data_source = {}
      data_source["columns"] = source.columns
      data_source["sql"]     = source.query

      data_sources[source.name] = data_source
    end

    return data_sources
  end

  def connection_from_source(source_name)
    source = @sources.find { |source| source.name == source_name}
    @conns[source.connection_name]
  end
end
