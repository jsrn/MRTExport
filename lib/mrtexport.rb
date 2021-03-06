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
include Utility

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

  def generate_pdf
    @y_off = 0

    @pdf = Prawn::Document.new

    @xml_doc.xpath("//Pages/*").each do |page|
      # List bands bands
      whisper "[*] listing report bands"
      page.xpath("./Components/*[contains(., 'Band')]").each do |band|
        whisper "    - #{band.name}"
      end

      # render out of band stuff
      page.xpath("./Components/*[not(contains(.,'Band'))]").each do |component|
        if component.name.include?("Text")
          render_background(component)
          render_text(component)
        elsif component.name.include?("Image")
          render_image(component)
        end
      end

      # but we want to do bands in a specific order!
      # Start with header band
      page.xpath("./Components/*[contains(., 'ReportTitleBand')]").each do |band|
        whisper "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        render_band(band)
      end

      page.xpath("./Components/*[contains(., 'HeaderBand')]").each do |band|
        whisper "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        render_band(band)
      end

      page.xpath("./Components/*[contains(., 'DataBand')]").each do |band|
        whisper "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        data_band_renderer = DataBandRenderer.new(
          band,
          @pdf,
          @database,
          @y_off
        )

         @y_off = data_band_renderer.render
      end

      page.xpath("./Components/*[contains(., 'FooterBand')]").each do |band|
        whisper "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        render_band(band)
      end
    end

    @pdf.render_file @output_file
  end

  def render_band(band)
    render_backgrounds(band)
    render_images(band)
    render_texts(band)
  end

  def render_backgrounds(page)
    page.xpath("Components/*[contains(.,'Text')]").each do |node|
      next if node.name == "Name"

      if node.name.start_with? "Text"
        x, y, w, h = Stylist.get_dimensions(node, @y_off)

        hue = node.xpath("Brush").text

        if hue != "Transparent"
          hue = hue.sub("[","").sub("]","").split(":")
          hex_hue = hue[0].to_i.to_s(16) << hue[1].to_i.to_s(16) << hue[2].to_i.to_s(16)

          @pdf.fill_color hex_hue
          @pdf.fill_rectangle [x,y], w, h
        end

        if node.xpath("Border").text != ""
          border = node.xpath("Border").text
          border_bits = border.split(";")

          sides = border_bits[0]

          if sides != "None"
            @pdf.stroke_color = Stylist.mrt_colour_to_hex(border_bits[1])
            @pdf.line_width = 1

            @pdf.line [x,   y], [x+w,   y] if sides.include? "Top"
            @pdf.line [x, y-h], [x+w, y-h] if sides.include? "Bottom"
            @pdf.line [x,   y], [x,   y-h] if sides.include? "Left"
            @pdf.line [x+w, y], [x+w, y-h] if sides.include? "Right"
            @pdf.stroke
          end
        end
      end
    end
  end

  def render_background(node)
    return if node.name == "Name"

    if node.name.start_with? "Text"
      x, y, w, h = Stylist.get_dimensions(node, @y_off)

      hue = node.xpath("Brush").text

      if hue != "Transparent"
        hue = hue.sub("[","").sub("]","").split(":")
        hex_hue = hue[0].to_i.to_s(16) << hue[1].to_i.to_s(16) << hue[2].to_i.to_s(16)

        @pdf.fill_color hex_hue
        @pdf.fill_rectangle [x,y], w, h
      end

      if node.xpath("Border").text != ""
        border = node.xpath("Border").text
        border_bits = border.split(";")

        sides = border_bits[0]

        if sides != "None"
          @pdf.stroke_color = Stylist.mrt_colour_to_hex(border_bits[1])
          @pdf.line_width = 1

          @pdf.line [x,   y], [x+w,   y] if sides.include? "Top"
          @pdf.line [x, y-h], [x+w, y-h] if sides.include? "Bottom"
          @pdf.line [x,   y], [x,   y-h] if sides.include? "Left"
          @pdf.line [x+w, y], [x+w, y-h] if sides.include? "Right"
          @pdf.stroke
        end
      end
    end
  end

  def render_images(band)
    band.xpath("Components/*[contains(.,'Image')]").each do |node|
      render_image(node)
    end
  end

  def render_image(node)
    x, y, w, h = Stylist.get_dimensions(node, @y_off)

    data = Base64::decode64(node.xpath("Image").text)

    File.open("/tmp/mrt_to_pdf_img",'wb') { |file| file.puts data }

    @pdf.image "/tmp/mrt_to_pdf_img", :at => [x, 0 + h], :width => w 

    File.delete("/tmp/mrt_to_pdf_img")
  end

  def render_texts(page)
    last_y_off = @y_off

    page.xpath("Components/*[contains(.,'Text')]").each do |node|
      last_y_off = render_text(node)
    end

    @y_off = last_y_off
  end

  def render_text(node)
    last_y_off = @y_off

    return if node.name == "Name"

    if node.name.start_with? "Text"
      x, y, w, h = Stylist.get_dimensions(node, @y_off)

      # Text
      text = node.xpath("Text").text

      # SQL replacements
      if text.include?("{")
        text.gsub!(/{.*}/) do |datum|
          source, field = datum.tr!("{}","").split(".")
          @database.get_value(source, field)
        end
      end

      # Do painting
      @pdf.fill_color = Stylist.get_text_colour(node)
      @pdf.text_box text,
                :at     => [x + 1, y - 1],
                :height => h,
                :width  => w,
                :align  => Stylist.get_horizontal_align(node),
                :valign => Stylist.get_vertical_align(node),
                :size   => Stylist.get_font_size(node),
                :font   => Stylist.get_font_face(node),
                :style  => Stylist.get_font_style(node)

      last_y_off = (740 - y) if (740 - y) > @y_off
    end

    return last_y_off
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