require "mysql2"
require "json"
require "restclient"

Dir["ext/*.rb"].each {|file| require file }

# Script Parameters
LAYOUT_FILE = "layouts/ArmchairAnalysisNFL.json"
$DATABASE_KEY = "db"
$DATABASE_NAME = "nfl_data"
$OUTPUT_FILE = "json_out.json"
$DEBUG = false
$BATCHSIZE = 1000
$STARTROW = 0
$ESTSTOP = -1

$client = Mysql2::Client.new(:host => "localhost", :username => "root")

puts "#{Time.new} >>> Loading Layout..."
layout = JSON.parse( IO.read(LAYOUT_FILE) )
$layoutClean = (layout.cleanLayout)
puts "#{Time.new} >>> Layout Loaded & Cleaned"

batch = 1
startnum = $STARTROW
continue = true

prsstart = Time.new

while(continue)
  bthstart = Time.new
  puts "#{Time.new} >>> Batch ##{batch} >>> Starting Conversion..."
  output = layout.buildRecord(nil , {:batchsize => $BATCHSIZE , :startrow => startnum , :forceblankarray => false })
  puts "#{Time.new} >>> Batch ##{batch} >>> Conversion Complete"
  
  if output.size == 0
      continue = false
      break
  else
    startnum = startnum + $BATCHSIZE
  end
 
  puts "#{Time.new} >>> Batch ##{batch} >>> Writing to output file..."
  File.open($OUTPUT_FILE, 'w') {|f| 
    f.write(output.to_json) 
  }
  puts "#{Time.new} >>> Batch ##{batch} >>> Bulk API file write completed. JSON written to #{$OUTPUT_FILE}"
  
  puts "#{Time.new} >>> Batch ##{batch} >>> Posting to Elastic Search..."
  str = ""
  
  output.each do |p|
    str = "#{str}{ \"index\" : { \"_index\" : \"nfl_data\", \"_type\" : \"play\", \"_id\" : \"#{p["PID"]}\" }\n"
    str = "#{str}#{p.to_json}\n"
  end
  RestClient.post "http://localhost:9200/_bulk",str , :accept => :json 
   
  
  puts "#{Time.new} >>> Batch ##{batch} >>> Posting to ElasticSearch complete"

  bthend = Time.new
  puts "Batch Duration: #{(bthend - bthstart)} sec"
  
  batch += 1
  if $ESTSTOP != -1 && startnum >= $ESTSTOP 
     break
   end
  
end

prsend = Time.new

puts "#{Time.new} >>> JOB COMPLETE"
puts "Job Duration: #{(prsend - prsstart)/60.0} min"
   

