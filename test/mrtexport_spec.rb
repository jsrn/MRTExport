require_relative '../lib/mrtexport.rb'

describe MRTExport, "#score" do
  it "returns expected output for complex report" do
    MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/JNCExample.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/output/complex_out.pdf",
      :export_format => "pdf",
      :replacements  => {"QuoteID" => "1"}
    })
  end

  it "returns expected output for simple report" do
    MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/a.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/output/simple_out.pdf",
      :export_format => "pdf"
    })
  end
end