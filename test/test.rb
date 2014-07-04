#!/usr/bin/env ruby

require_relative "../lib/mrtexport.rb"

MRTExport.new({
  :report_file   => "test_reports/JNCExample.mrt",
  :output_file   => "test_output/cmd_out.pdf",
  :export_format => "pdf",
  :replacements  => {"QuoteID" => "1"}
  })