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

  it "exits cleanly if any of the important fields are missing" do
    exporter = MRTExport.new
    expect{exporter.run}.to throw_symbol(:report_file_invalid)

    exporter.report_file = "#{File.dirname(__FILE__)}/test_reports/simple.mrt"
    expect{exporter.run}.to throw_symbol(:output_file_invalid)

    exporter.output_file = "#{File.dirname(__FILE__)}/output/simple_out.pdf"
    exporter.run
  end

  it "exits properly with an unwritable file" do
    exporter = MRTExport.new
    exporter.report_file = "#{File.dirname(__FILE__)}/test_reports/simple.mrt"
    exporter.output_file = "/etc/issue"

    expect{exporter.run}.to throw_symbol(:output_file_invalid)
  end
end