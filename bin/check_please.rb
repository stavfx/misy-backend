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
  content_type :json
  request.body.rewind
  json_params = request.body.read
  @request_params = {}
  @request_params = JSON.parse json_params unless (json_params.nil? || json_params.empty?)
end


get '/' do
  "Hi #{cookies["username"]}, Welcome to Misy! :)"
end

get '/api/testCookies' do
	cookies.to_json
end

get '/api/restaurants' do
  RestaurantMng.get_all(@params["city"]).to_json
end

put '/api/restaurants' do
  RestaurantMng.update(@request_params).to_json
end

post '/api/services' do
  ServiceMng.create(@request_params['service']).to_json
end

get '/api/services' do
  ServiceMng.get_all.to_json
end

post '/api/register' do
  msg = UserMng.register(@request_params)
  if msg["success"]
    cookies["username"] = @request_params["id"]
  end
  msg.to_json
end


post '/api/login' do
  msg = UserMng.login(@request_params["id"],@request_params["password"])
  if msg["success"]
    cookies["username"] = @request_params["id"]
  else
    cookies.delete("username")
  end
  msg.to_json
end


post '/api/logout' do
  cookies.delete("username")
  return_message(true).to_json
end

