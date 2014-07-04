#!/usr/bin/env ruby

require_relative "../lib/mrtexport.rb"

MRTExport.new({
  :report_file   => "reports/JNCExample.mrt",
  :output_file   => "reports/out2.pdf",
  :export_format => "pdf",
  :replacements  => {"QuoteID" => "1"}
  })