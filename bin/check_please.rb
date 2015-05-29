require 'rubygems'
require 'sinatra'
Dir['../lib/*.rb'].each { |file| require file }
require 'mongo'
require 'mongo_mapper'
require 'json'

enable :sessions
set :bind, '0.0.0.0'
set :port, 80


# MongoMapper.connection = Mongo::Connection.new(host, port)
# MongoMapper.database = db_name
# MongoMapper.database.authenticate(db_name, pw)

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'misy'




# before do
#   request.body.rewind
#   @request_params = JSON.parse request.body.read
# end


get '/' do
  "Hello World!\nMongo version: " + Gem.loaded_specs["mongo"].version.to_s
end


post '/api/services' do
  ServiceMng.create(params['service'])
end

get '/api/services' do
  ServiceMng.get_all
end

post '/api/register' do
#  session[:username] = username
  return_message = {}
  if UserMng.register(params)
    return_message[:success] = true
  else
    return_message[:success] = false
  end
  return_message.to_json
end


post '/api/login' do
  return_message = {}
  if UserMng.login(params[:username],params[:password])
    return_message[:success] = true
  else
    return_message[:success] = false
  end

  return_message.to_json
end
