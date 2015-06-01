Dir['../lib/*.rb'].each do |file|
  puts file
  require file
end
require 'rubygems'
require 'sinatra'
require "sinatra/cookies"
require 'mongo'
require 'mongo_mapper'
require 'json'

enable :sessions
set :bind, '0.0.0.0'
set :port, 80



MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'misy'


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
  RestaurantMng.get_all(@params["city"])
end

put '/api/restaurants' do
  RestaurantMng.update(@request_params)
end

post '/api/services' do
  ServiceMng.create(@request_params['service'])
end

get '/api/services' do
  ServiceMng.get_all
end

post '/api/register' do
  UserMng.register(@request_params)
end


post '/api/login' do
  msg = UserMng.login(@request_params["username"],@request_params["password"])
  if msg["success"]
    cookies["username"] = @request_params["username"]
  else
    cookies.delete("username")
  end
  msg
end


post '/api/logout' do
  cookies.delete("username")
  return_message(true)
end
