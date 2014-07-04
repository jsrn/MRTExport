#!/usr/bin/env ruby

require 'mrtexport'

MRTExport.new({
  :report_file   => "#{File.dirname(__FILE__)}/test_reports/JNCExample.mrt",
  :output_file   => "#{File.dirname(__FILE__)}/test_output/gem_out.pdf",
  :export_format => "pdf",
  :replacements  => {"QuoteID" => "1"}
  })