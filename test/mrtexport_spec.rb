require_relative '../lib/mrtexport.rb'

describe MRTExport, "#score" do
  it "returns 0 for all gutter game" do
    MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/JNCExample.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/test_output/out.pdf",
      :export_format => "pdf",
      :replacements  => {"QuoteID" => "1"}
    })
  end
end