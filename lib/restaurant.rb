require 'mongo_mapper'
require File.join(File.dirname(__FILE__), './utils')

class Restaurant
  include MongoMapper::Document

  key :name,          String
  key :admin_user_id, String
  key :city,          String
  key :address,       String
  key :p_number,      String
  key :desc,          String
  many :menu_items
end


class MenuItem
  include MongoMapper::EmbeddedDocument

  key :name,        String
  key :description, String
  key :price ,      Integer
  key :recommended, String
end


class City
  include MongoMapper::Document

  key :_id, String
end


class RestaurantMng

  def self.create(params)
    res = Restaurant.create({"admin_user_id" => params["admin_user_id"]})
    res.save
    return res._id
  end


  def self.update(params)
    res = Restaurant.find(params["id"])
    if res.nil?
      return_message(false,{},"No restaurant was found with id #{params["id"]}")
    else
      data = {}
      menu_items = []
      if !params["menu_items"].nil?
        params["menu_items"].each do |item|
          menu_items << MenuItem.new(
              :name => item["name"],
              :description => item["description"],
              :price => item["price"],
              :recommended => item["recommended"]
          )

        end
      end

      res.update_attributes(
                              :name          => params["name"],
                              :city          => params["city"],
                              :address       => params["address"],
                              :p_number      => params["p_number"],
                              :desc          => params["desc"],
                              :menu_items    => menu_items
                          )
      res.save
      data["restaurant_id"] = res._id
      return_message(true,data)
    end

  end


  def self.get_all(city = nil)
    return return_message(true,Restaurant.all(:city => city)) unless city.nil?
    return_message(true,Restaurant.all)
  end


  def self.get_all_cities
    return_message(true,City.all)
  end


  # return field "recommend" for menu item "id"
  def self.getRecommendMenuItem(id)
    menuItems=MenuItem.where(:_id => id.to_s).fields(:recommend).collect(&:recommend)
    return menuItems
  end



end


