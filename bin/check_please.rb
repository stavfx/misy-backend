require 'rubygems'
require 'sinatra'
Dir['./lib/*.rb'].each do |file|
  puts file
  require file
end
require 'mongo'
require 'mongo_mapper'



puts Dir['./lib']
puts "_file_"
puts Dir[__FILE__]
puts "========================>stav"
# puts Gem.loaded_specs["mongo"].version
#
#
# regex_match = /.*:\/\/(.*):(.*)@(.*):(.*)\//.match(ENV['MONGOLAB_URI'])
# host = regex_match[3]
# port = regex_match[4]
# db_name = regex_match[1]
# pw = regex_match[2]
#
# MongoMapper.connection = Mongo::Connection.new(host, port)
# MongoMapper.database = db_name
# MongoMapper.database.authenticate(db_name, pw)
#
# get '/' do
#   # mongo_uri = ENV['MONGOLAB_URI']
#   # client = Mongo::Client.new(mongo_uri);
#   # db = client.database
#   # db.collection_names.each{|name| puts name }
#   "Hello World!\nMongo version: " + Gem.loaded_specs["mongo"].version.to_s
# end
#
# #
# # post '/services' do
# #   ServiceMng.create(params['service'])
# # end
#
# get '/services' do
#   # ServiceMng.get_all
#   ServiceMng.test
#   "hello"
# end
