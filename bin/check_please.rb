require 'rubygems'
require 'sinatra'
#Dir['../lib/*.rb'].each {|file| require file }

#require 'mongo'
#puts Gem.loaded_specs["mongo"].version

#mongo_uri = ENV['MONGOLAB_URI']
#client = Mongo::Client.new(mongo_uri);
#db = client.database
#db.collection_names.each{|name| puts name }

get '/' do
  "Hello World!"
end




