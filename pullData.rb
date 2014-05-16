require "mysql2"
require "json"

Dir["ext/*.rb"].each {|file| require file }

# Script Parameters
LAYOUT_FILE = "layouts/full_play.json"
$DATABASE_KEY = "db"
$DATABASE_NAME = "nfl_data"

$client = Mysql2::Client.new(:host => "localhost", :username => "root")

layout = JSON.parse( IO.read(LAYOUT_FILE) )

$layoutClean = (layout.cleanLayout)
puts $layoutClean

puts "Building arrays"

puts layout.buildRecord.to_json
