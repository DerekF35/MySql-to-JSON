
class Array
  def cleanLayout
      tmp = Array.new
      self.each do |a|
        tmp << a.cleanLayout
      end
      return tmp
  end
  
  def buildRecord( val = nil  ,  opts = {})
      self.each do |w|
        return w.buildRecord(nil , {:isarray => false}.merge!(opts))
      end
  end
end