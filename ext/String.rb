class ::String
  def replaceVar( arr )
    arr.each do |k,v|
      self.gsub! "%%{#{k}}" , "#{v}"
    end
  end
  
  def cleanLayout()
    return nil
  end
  
  def buildRecord( val )
    val = val == "\r" ? nil : val
    case self
      when "text"
        return val.to_s
      when "int"
        return val.to_i
      when "double"
        return val.to_f
      else
        return val
    end
  end
end