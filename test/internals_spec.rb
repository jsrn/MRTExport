require_relative '../lib/mrtexport.rb'

describe MRTExport, "#internals" do
  it "initializes with no params" do
    MRTExport.new()
  end

  it "allows you to set the debug flag" do
    exporter = MRTExport.new
    expect(exporter.debug).to be false
    exporter.debug = true
    expect(exporter.debug).to be true
  end

  it "defaults to pdf" do
    exporter = MRTExport.new
    expect(exporter.export_format).to match "pdf"
  end
end