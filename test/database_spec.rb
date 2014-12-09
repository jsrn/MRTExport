require_relative '../lib/database.rb'
require "nokogiri"

describe Database, "#database" do
  it "initialize with an xml doc" do
    xml_doc = Nokogiri::XML(File.open("#{File.dirname(__FILE__)}/test_reports/multidb.mrt"))
    database = Database.new(xml_doc)
    expect(database).to be_a Database
  end

  it "can list the connections" do
    xml_doc = Nokogiri::XML(File.open("#{File.dirname(__FILE__)}/test_reports/multidb.mrt"))
    database = Database.new(xml_doc)

    expect(database.connections).to be_a Hash
  end

  it "can list the data sources" do
    xml_doc = Nokogiri::XML(File.open("#{File.dirname(__FILE__)}/test_reports/multidb.mrt"))
    database = Database.new(xml_doc)

    expect(database.data_sources).to be_a Hash
  end
end