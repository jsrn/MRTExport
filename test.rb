#!/usr/bin/env ruby

Dir["reports/*.mrt"].each do |report|
  puts `mrttopdf #{report} reports/out.pdf QuoteID=1`
  sleep 2
end