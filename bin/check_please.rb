require 'rubygems'
require 'sinatra'
require "sinatra/cookies"
Dir['../lib/*.rb'].each { |file| require file }
require 'mongo'
require 'mongo_mapper'
require 'json'

enable :sessions
set :bind, '0.0.0.0'
#set :port, 80

# MongoMapper.connection = Mongo::Connection.new(host, port)
# MongoMapper.database = db_name
# MongoMapper.database.authenticate(db_name, pw)

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'misy'

def return_message(success,data={},error_code=0)
  message = {}
  message[:success] = success
  message[:data] = data
  message[:errorCode] = error_code
  return message.to_json
end


before do
  request.body.rewind
  json_params = request.body.read
  @request_params = {}
  @request_params = JSON.parse json_params unless (json_params.nil? || json_params.empty?)
end


get '/' do
  "Hi #{cookies["username"]}, Welcome to Misy! :)"
end


get '/api/restaurants' do
  return_message(true,RestaurantMng.get_all(@request_params["city"]),200)
end

post '/api/restaurants' do
  return_message(RestaurantMng.create(@request_params))
end

post '/api/services' do
  ServiceMng.create(@request_params['service'])
end

get '/api/services' do
  return_message(true,ServiceMng.get_all,200)
end

post '/api/register' do
  return_message(UserMng.register(@request_params))
end


post '/api/login' do
  if UserMng.login(@request_params["username"],@request_params["password"])
    cookies["username"] = @request_params["username"]
    p cookies
    return_message(true)
  else
    cookies.delete("username")
    return_message(false)
  end
end

post '/api/logout' do
  cookies.delete("username")
end
