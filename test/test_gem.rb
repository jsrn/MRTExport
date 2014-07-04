#!/usr/bin/env ruby

require 'mrtexport'

MRTExport.new({
  :report_file   => "test_reports/JNCExample.mrt",
  :output_file   => "test_output/out.pdf",
  :export_format => "pdf",
  :replacements  => {"QuoteID" => "1"}
  })