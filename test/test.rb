#!/usr/bin/env ruby

require_relative "../lib/mrtexport.rb"

exporter = MRTExport.new({
  :report_file   => "reports/JNCExample.mrt",
  :output_file   => "reports/out2.pdf",
  :export_format => "pdf",
  :replacements  => {"QuoteID" => "1"}
  })

#require 'mrtexport'

#exporter = MRTExport.new

#Dir["reports/*.mrt"].each do |report|
#  puts `mrttopdf #{report} reports/out.pdf QuoteID=1`
#  sleep 2
#end