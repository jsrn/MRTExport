#!/usr/bin/env ruby

# Dependencies
require "prawn"
require "nokogiri"
require "mysql2"
require "base64"

# Included files
require_relative "data_band"
require_relative "stylist"
require_relative "util"
require_relative "database"
require_relative "renderer"
include Utility
include Renderer

class MRTExport
  attr_accessor :report_file, :output_file, :export_format, :replacements, :debug

  def initialize(params={})
    @report_file   = params[:report_file]
    @output_file   = params[:output_file]
    @export_format = params[:export_format] || "pdf"
    @replacements  = params[:replacements]  || {}
    @debug         = false
  end

  def run
    whisper "[+] Compiling new report: #{@report_file}"

    check_settings
    generate_xml
    prepare_database
    generate_pdf
  end

  def check_settings
    report_file_valid
    output_file_valid
  end

  def report_file_valid
    unless @report_file and File.file?(@report_file)
      throw :report_file_invalid
    end
  end

  def output_file_valid
    unless @output_file and Pathname.new(File.dirname(@output_file)).writable?
      throw :output_file_invalid
    end
  end

  def prepare_database
    @database = Database.new(@xml_doc)
  end

  def generate_xml
    xml = File.open(@report_file).read
    xml = perform_replacements(xml)
    @xml_doc = Nokogiri::XML(xml)
  end

  def perform_replacements(xml_string)
    @replacements.each do |key, val|
      xml_string.gsub!("{#{key}}", val)
    end

    xml_string
  end
end

# Handler for command line launch
if __FILE__ == $0
  if ARGV[1].nil?
    puts "USAGE:"
    puts "./mrttopdf.rb <report file> <output file> <replacement 1> .. <replacement n>"
    exit
  elsif ARGV[1] == "--version"
    puts "0.0.1"
  end

  report_file = ARGV[0]
  output_file = ARGV[1]

  replacements = {}

  ARGV[2..ARGV.length].each do |arg|
    arg_bits = arg.split("=")
    replacements[arg_bits[0]] = arg_bits[1]
  end

  MRTExport.new({
    :report_file   => report_file,
    :output_file   => output_file,
    :replacements  => replacements
  })
end