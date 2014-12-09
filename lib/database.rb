class Database
  def initialize(xml_doc)
    @xml_doc = xml_doc
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
    data_source_count = data_source_container.attribute("count")

    data_source_container.xpath("./*").each do |data_source_node|
      # Data source name
      name = data_source_node.xpath("Name").text

      # Column names
      column_container = data_source_node.xpath("Columns")
      columns = []
      column_container.xpath("./value").each do |column|
        columns << column.text.split(",")[0]
      end

      # SQL query
      sql = data_source_node.xpath("SqlCommand").text
      sql.gsub!("\n", " ")

      data_source = {}
      data_source["columns"] = columns
      data_source["sql"] = sql

      data_sources[name] = data_source
    end

    return data_sources
  end
end