class Stylist
  def Stylist.mrt_colour_to_hex(mrt_colour)
    mrt_colour = mrt_colour.sub("[","").sub("]","").split(":")
    return mrt_colour[0].to_i.to_s(16) << mrt_colour[1].to_i.to_s(16) << mrt_colour[2].to_i.to_s(16)
  end

  def Stylist.get_text_colour(node)
    hue = node.xpath("TextBrush").text
    case hue
    when "Black"
      "000000"
    else
      Stylist.mrt_colour_to_hex(hue)
    end
  end

  def Stylist.get_horizontal_align(node)
    if node.xpath("HorAlignment").text != ""
      return node.xpath("HorAlignment").text.downcase.to_sym
    else
      return :left
    end
  end

  def Stylist.get_vertical_align(node)
    if node.xpath("VertAlignment").text != ""
      return node.xpath("VertAlignment").text.downcase.to_sym
    else
      return :top
    end
  end

  def Stylist.get_font_face(node)
    node.xpath("Font").text.split(",")[0]
  end

  def Stylist.get_font_size(node)
    node.xpath("Font").text.split(",")[1].to_i
  end

  def Stylist.get_font_style(node)
    font_style = node.xpath("Font").text.split(",")[2]
    if font_style.nil?
      return :normal
    else
      return font_style.downcase.to_sym
    end
  end

  def Stylist.get_dimensions(node, y_off)
    position = node.xpath("ClientRectangle").text.split(",")
    position = position.map {|x| x.to_f}

    x = Util.cm_to_px(position[0])
    y = Util.trans_y(y_off, Util.cm_to_px(position[1]))
    w = Util.cm_to_px(position[2])
    h = Util.cm_to_px(position[3])

    return x, y, w, h
  end
end