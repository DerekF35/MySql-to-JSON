
class Hash
    def removeKeys(  deletekeys = ["objqry","objactive"] )
      deletekeys.each do |toDel|
          if self.has_key?(toDel)
            self.delete(toDel)
          end
      end
    end
    
    def cleanLayout
       clnLayout = self.clone
       clnLayout.removeKeys
        clnLayout.each do |k,v|
            if v == false
              clnLayout.delete(k)
            else
              clnLayout[k] = v.cleanLayout
            end
       end
       return clnLayout
    end

    def buildRecord( val = nil , opts = {})
      opts = {:isarray => false , :batchsize => nil , :forceblankarray => true , :startrow=> 0}.merge(opts)
      if self.has_key?("objqry") && !(self.has_key?("objactive") and self["objactive"] == false)
        qry = "#{self["objqry"]}"
        # TODO include other keys from previous row in qry replace
        qry.replaceVar({$DATABASE_KEY=>$DATABASE_NAME})
        if val.is_a?(Hash)
          qry.replaceVar(val)
        end
        if !opts[:batchsize].nil?
           qry = "#{qry} LIMIT #{opts[:startrow]} , #{opts[:batchsize]}"
        end
        if $DEBUG then  puts "Executing qry: #{qry}" end
        out = Array.new
        found = false
        $client.query(qry).each do |row|
          found = true
          tmp = self.cleanLayout
          tmplayout = self.clone
          tmplayout.removeKeys
          tmplayout.each do |k,v|
              if v != false
                tmp[k] =  (v.class == Array || v.class == Hash) ? v.buildRecord(row) : v.buildRecord(row[k])
              end
          end 
          out << tmp
        end
        if !found && opts[:forceblankarray]
           #if no results found, blank layout is sent.  need make this a param
            out << self.cleanLayout
        end
        return opts[:isarray] == true ? out : out[0]
      end
    end
end