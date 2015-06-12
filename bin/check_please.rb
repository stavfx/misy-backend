Dir['../lib/*.rb'].each { |file| require file }
require 'rubygems'
require 'sinatra'
require "sinatra/cookies"
require 'mongo'
require 'mongo_mapper'
require 'json'
require 'base64'

#enable :sessions
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
  @user = (request.cookies["session"].nil?) ? nil : ::Base64.decode64(request.cookies["session"]).chomp!('salt')
  @dining_session = request.cookies["dining_session"]
end

def set_user_in_cookies(response, user)
  response.set_cookie("session", :value => ::Base64.encode64(user+'salt'), :path => '/')
end

def set_dining_session_in_cookies(response, dining_session)
  response.set_cookie("dining_session", :value => dining_session, :path => '/')
end

def delete_user_from_cookies(response)
  response.delete_cookie("session")
end

def delete_dining_session_from_cookies(response)
  response.delete_cookie("dining_session")
end


get '/' do
  "Hi #{@user}, Welcome to Misy! :)"
end

get '/api/testCookies' do
	cookies.to_json
end

get '/api/restaurants' do
  RestaurantMng.get_all().to_json
end

put '/api/restaurants' do
  RestaurantMng.update(@request_params).to_json
end

post '/api/cities' do
  RestaurantMng.create_city(@request_params["city"]).to_json
end

get '/api/cities' do
  RestaurantMng.get_all_cities().to_json
end

post '/api/services' do
  ServiceMng.create(@request_params['service']).to_json
end

get '/api/services' do
  ServiceMng.get_all.to_json
end

get '/api/menuCategories' do
  MenuItemMng.get_all_menu_categories().to_json
end

post '/api/menuCategories' do
  MenuItemMng.create_menu_category(@request_params["menu_category"]).to_json
end


def order(request_params)
  return return_message(false,{},'Session not found') if @user.nil?
  request_params["user_id"] = @user
  request_params["dining_session"] = @dining_session
  msg = OrderMng.create(request_params)
  set_dining_session_in_cookies(response,msg[:data]["dining_session"])
  return msg
end

post '/api/orders/service' do
  msg = order(@request_params)
  delete_dining_session_from_cookies(response) if (!@request_params["service"].nil?) && @request_params["services"].eql?("check")
  msg.to_json
end

post '/api/orders/dishes' do
  order(@request_params).to_json
end

get '/api/orders' do
  return return_message(false,{},"No user logged in").to_json if @user.nil?
  msg = RestaurantMng.get_restaurant_id_by_user(@user)
  if msg[:success]
    res_id = msg[:data]
    OrderMng.get_orders(res_id).to_json
  else
    msg.to_json
  end
end

put '/api/orders' do
  OrderMng.update(@request_params).to_json
end

get '/api/orders/restaurant/history' do
  return return_message(false,{},"No user logged in") if @user.nil?
  msg = RestaurantMng.get_restaurant_id_by_user(@user)
  if msg[:success]
    res_id = msg[:data]
    OrderMng.get_orders_history_by_res(res_id).to_json
  else
    msg.to_json
  end

end

get '/api/orders/user/history' do
  puts "history"
  return return_message(false,{},"No user logged in") if @user.nil?
  puts "before func"
  OrderMng.get_orders_history_by_user(@user).to_json
  puts "after func"
end

get '/api/orders/archive' do
  return return_message(false,{},"No user logged in") if @user.nil?
  response = RestaurantMng.get_restaurant_id_by_user(@user)
  return response unless response[:success]
  res = response[:data]
  OrderMng.send_not_active_to_archive(res).to_json
end


get '/api/getRecommended/:res_id' do
  return return_message(false,{},"No user logged in") if @user.nil?
  res_id = params[:res_id]
end
#TODO icons


put '/api/user' do
  UserMng.update(@request_params).to_json
end

post '/api/register' do
  msg = UserMng.register(@request_params)
  if msg[:success]
    set_user_in_cookies(response,@request_params["id"])
  end
  msg.to_json
end


post '/api/login' do
  msg = UserMng.login(@request_params["id"],@request_params["password"])
  if msg[:success]
    set_user_in_cookies(response,@request_params["id"])
  else
    response.delete_cookie("session")
  end
  msg.to_json
end




post '/api/logout' do
  response.delete_cookie("session")
  return_message(true).to_json
end


