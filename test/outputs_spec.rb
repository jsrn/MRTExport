require_relative '../lib/mrtexport.rb'

describe MRTExport, "#outputs" do
  it "returns expected output for complex report" do
    exporter = MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/complex.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/output/complex_out.pdf",
      :export_format => "pdf",
      :replacements  => {"QuoteID" => "1"}
    })
    exporter.run
  end

  it "returns expected output for multi-db report" do
    exporter = MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/multidb.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/output/multidb_out.pdf",
      :export_format => "pdf",
      :replacements  => {"QuoteID" => "1"}
    })
    exporter.run
  end

  it "returns expected output for simple report" do
    exporter = MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/simple.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/output/simple_out.pdf",
      :export_format => "pdf"
    })
    exporter.run
  end

  it "returns expected output for mixed report" do
    exporter = MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/mixandmatch.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/output/mixandmatch_out.pdf",
      :export_format => "pdf"
    })
    exporter.run
  end
end