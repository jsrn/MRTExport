class Util
  def Util.cm_to_px(cm)
    return cm / 2.5 * 72
  end

  def Util.trans_y(off, y)
    720 - off - y
  end

  def Util.is_number?(object)
    true if Float(object) rescue false
  end

  def Util.number_format(number)
    '%.2f' % number.to_f
  end
end