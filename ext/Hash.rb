
class Hash
    def removeKeys(  deletekeys = ["objqry"] )
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
          clnLayout[k] = v.cleanLayout
       end
       return clnLayout
    end

    def buildRecord( val = nil , opts = {})
      opts = {:isarray => false}.merge(opts)
      if self.has_key?("objqry")
        qry = "#{self["objqry"]}"
        # TODO include other keys from previous row in qry replace
        qry.replaceVar({$DATABASE_KEY=>$DATABASE_NAME})
        puts "Executing qry: #{qry}"
        out = Array.new
        found = false
        $client.query(qry).each do |row|
          found = true
          tmp = self.cleanLayout
          puts tmp
          row.each do |k,v|
            if tmp.has_key?(k)
                puts k
                tmp[k] = self[k].buildRecord(v)
             else
              puts "No #{k} key in layout"
            end
            # TODO: handle when key in layout not in db
          end
          out << tmp
        end
        if !found
            out << self.cleanLayout
        end
        return opts[:isarray] == true ? out : out[0]
      else
        puts "No Object Query... Script Aborted"
        abort
      end
    end
end