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


before do
  request.body.rewind
  @request_params = JSON.parse request.body.read
end


get '/' do
  "Hello World!\nMongo version: " + Gem.loaded_specs["mongo"].version.to_s
end


post '/api/services' do
  ServiceMng.create(@request_params['service'])
end

get '/api/services' do
  ServiceMng.get_all
end

post '/api/register' do
#  session[:username] = username
  return_message = {}
  if UserMng.register(@request_params)
    return_message[:success] = true
  else
    return_message[:success] = false
  end
  return_message.to_json
end


post '/api/login' do
  return_message = {}
  if UserMng.login(@request_params[:username],@request_params[:password])
    return_message[:success] = true
  else
    return_message[:success] = false
  end

  return_message.to_json
end