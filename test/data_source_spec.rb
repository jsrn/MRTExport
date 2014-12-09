require_relative '../lib/database.rb'
require_relative '../lib/data_source.rb'
require "nokogiri"

describe DataSource, "#data sources" do
  it "initializes with xml" do
    @xml_doc = Nokogiri::XML(File.open("#{File.dirname(__FILE__)}/test_reports/multidb.mrt"))

    data_sources = {}

    data_source_container = @xml_doc.xpath("//DataSources")

    data_source_container.xpath("./*").each do |data_source_node|
      expect(DataSource.new(data_source_node)).to be_a DataSource
    end
  end

  it "initializes with nothing" do
    source = DataSource.new
    expect(source.name).to be nil
    source.name = "ATestSource"
    expect(source.name).to match "ATestSource"
  end
end
