Dir['../lib/*.rb'].each { |file| require file }
require 'rubygems'
require 'sinatra'
require "sinatra/cookies"
require 'mongo'
require 'mongo_mapper'
require 'json'
require 'base64'

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

def get_user_from_session(cookies)
  return nil if (cookies.nil? || cookies["session"].nil?)
  ::Base64.decode64(cookies["session"])
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

post '/api/cities' do
  RestaurantMng.create_city(@request_params["city"])
end

post '/api/services' do
  ServiceMng.create(@request_params['service']).to_json
end

get '/api/services' do
  ServiceMng.get_all.to_json
end

def order(request_params,cookies)
  username = get_user_from_session(cookies)
  return return_message(false,{},'Session not found') if username.nil?s
  request_params["user_id"] = username
  request_params["dining_session"] = cookies["dining_session"] unless cookies["dining_session"].nil?
  msg = OrderMng.create(request_params)
  cookies["dining_session"] = msg[:data]["dining_session"] if cookies["dining_session"].nil?
  return msg
end

post '/api/orders/services' do
  msg = order(@request_params,cookies)
  cookies.delete("dining_session") if (!@request_params["services"].nil?) && @request_params["services"].include?("check")
  msg.to_json
end

post '/api/orders/dishes' do
  order(@request_params,cookies).to_json
end

get '/api/orders/services' do
  OrderMng.get_services_orders().to_json
end
get '/api/orders/dishes' do
  OrderMng.get_dish_orders().to_json
end

post '/api/register' do
  msg = UserMng.register(@request_params)
  if msg[:success]
    cookies["session"] = ::Base64.encode64(@request_params["id"]+'salt')
  end
  msg.to_json
end


post '/api/login' do
  msg = UserMng.login(@request_params["id"],@request_params["password"])
  if msg[:success]
    cookies["session"] = ::Base64.encode64(@request_params["id"]+'salt')
  else
    cookies.delete("session")
  end
  msg.to_json
end


post '/api/logout' do
  cookies.delete("session")
  return_message(true).to_json
end


