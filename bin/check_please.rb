require 'rubygems'
require 'sinatra'
Dir['./lib/*.rb'].each { |file| require file }
require 'mongo'
require 'mongo_mapper'

enable :sessions
puts Gem.loaded_specs["mongo"].version


regex_match = /.*:\/\/(.*):(.*)@(.*):(.*)\//.match(ENV['MONGOLAB_URI'])
host = regex_match[3]
port = regex_match[4]
db_name = regex_match[1]
pw = regex_match[2]

MongoMapper.connection = Mongo::Connection.new(host, port)
MongoMapper.database = db_name
MongoMapper.database.authenticate(db_name, pw)

get '/' do
  "Hello World!\nMongo version: " + Gem.loaded_specs["mongo"].version.to_s
end


post '/api/services' do
  p params
  ServiceMng.create(params['service'])
end

get '/api/services' do
  ServiceMng.get_all
end

post '/api/register' do
  session[:username] = username
  UserMng.register(params[:username],params[:password])
end