require 'mrtexport'

describe MRTExport, "#score" do
  it "returns 0 for all gutter game" do
    MRTExport.new({
      :report_file   => "#{File.dirname(__FILE__)}/test_reports/JNCExample.mrt",
      :output_file   => "#{File.dirname(__FILE__)}/test_output/gem_out.pdf",
      :export_format => "pdf",
      :replacements  => {"QuoteID" => "1"}
    })
    should be_true
  end
end