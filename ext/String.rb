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
    return val == "\r" ? nil : val
  end
end