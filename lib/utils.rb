require File.join(File.dirname(__FILE__), './restaurant')
require File.join(File.dirname(__FILE__), './service')

def return_message(success,data={},error_message="")
  message = {}
  message[:success] = success
  message[:data] = data
  message[:error_message] = error_message
  return message
end

def get_opening_data
  data = {}
  data["restaurants"] = (RestaurantMng.get_all)[:data]
  data["cities"] = (RestaurantMng.get_all_cities)[:data]
  return data
end