#!/usr/bin/env ruby
require "prawn"
require "nokogiri"
require "mysql2"
require "base64"

require "dbdb_builder"
require "data_band"
require "stylist"

class MRTExport
  def initialize(params)
    @report_file   = params[:report_file]
    @output_file   = params[:output_file]
    @export_format = params[:export_format]
    @replacements  = params[:replacements]
    
    puts "[+] Compiling new report: #{@report_file}"

    @xml_doc = Nokogiri::XML(File.open(@report_file))

    @sql_connections = DatabaseDatabaseBuilder.get_database_database(@xml_doc)
    @data_sources    = DatabaseDatabaseBuilder.get_data_sources(@xml_doc)

    puts @sql_connections

    initialize_database_connection if @sql_connections.length > 0

    @y_off = 0

    generate_pdf
  end

  def initialize_database_connection
    sql_connection_string = @sql_connections["Localhost"]
    sql_connection_array = {}

    sql_connection_string.split(";").each do |x|
      sql_connection_array[x.split("=")[0]] = x.split("=")[1]
    end

    @sql_connection = Mysql2::Client.new(
      :host     => sql_connection_array["Server"],
      :username => sql_connection_array["User"],
      :password => sql_connection_array["Password"],
      :database => sql_connection_array["Database"]
    )
  end

  def get_value_from_db(name)
    name.sub! "{", ""
    name.sub! "}", ""

    query_parts = name.split(".")
    query_name  = query_parts[0]
    query_field = query_parts[1]

    sql = @data_sources[query_name]["sql"]

    @replacements.each do |key, val|
      sql.sub!("{#{key}}", val)
    end
    
    text = ""

    rs = @sql_connection.query sql
    rs.each do |r|
      text = r[query_field]
      text = Util.number_format(text) if Util.is_number?(text)
    end 

    return text
  end

  def generate_pdf
    @pdf = Prawn::Document.new

    @xml_doc.xpath("//Pages/*").each do |page|
      # List bands bands
      puts "[*] listing report bands"
      page.xpath("./Components/*[contains(., 'Band')]").each do |band|
        puts "    - #{band.name}"
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
        puts "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        render_band(band)
      end

      page.xpath("./Components/*[contains(., 'HeaderBand')]").each do |band|
        puts "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        render_band(band)
      end

      page.xpath("./Components/*[contains(., 'DataBand')]").each do |band|
        puts "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        #render_band(band)
        data_band_renderer = DataBandRenderer.new(
          band,
          @pdf,
          @sql_connection,
          @replacements,
          @data_sources,
          @y_off
        )

         @y_off = data_band_renderer.render
      end

      page.xpath("./Components/*[contains(., 'FooterBand')]").each do |band|
        puts "[*] Doing band: #{band.name}, ref: #{band.attribute("Ref")}"
        render_band(band)
      end
    end

    puts "OUTPUT FILE: #{@output_file}"
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

    File.open("/tmp/mrt_to_pdf_img",'w') { |file| file.puts data }

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
        text.gsub!(/{.*}/) { |m| get_value_from_db(m) }
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
    :export_format => "pdf",
    :replacements  => replacements
  })
end