require_relative "util.rb"

class DataBandRenderer
  def initialize(data, pdf, database, y_off)
    @data = data
    @pdf = pdf
    @database = database
    @y_off = y_off

    @row_data = prepare_dataset
  end

  def render
    @row_data.each do |row|
      draw_row(row)
    end

    return @y_off
  end

  def prepare_dataset
    source_name = @data.xpath("DataSourceName").text
    sql = @database.sources[source_name].query

    connection = @database.connection_from_source(source_name)

    return connection.query sql
  end

  def draw_row(row)
    last_y_off = @y_off

    @data.xpath("Components/*[contains(.,'Text')]").each do |node|
      next if node.name == "Name"

      if node.name.start_with? "Text"
        x, y, w, h = Stylist.get_dimensions(node, @y_off)

        # Text
        text = node.xpath("Text").text

        # SQL replacements
        if text.include?("{")
          text.gsub!(/{.*}/) do |m|
            index = m.split(".")[1].sub("}","")
            text = row[index]
            text = Util.number_format(text) if Util.is_number?(text)
            text
          end
        end

        # Do painting
        @pdf.fill_color Stylist.get_text_colour(node)
        @pdf.text_box text,
                  :at     => [x + 1, y - 1],
                  :height => h,
                  :width  => w,
                  :align  => Stylist.get_horizontal_align(node),
                  :valign => Stylist.get_vertical_align(node),
                  :size   => Stylist.get_font_size(node),
                  :font   => Stylist.get_font_face(node),
                  :style  => Stylist.get_font_style(node)

        last_y_off = (720 + h - y) if (720 + h - y) > @y_off
      end
    end

    @y_off = last_y_off
  end
end