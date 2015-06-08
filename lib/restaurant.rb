require 'mongo_mapper'
require File.join(File.dirname(__FILE__), './utils')
require File.join(File.dirname(__FILE__), './menuItems')

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


class City
  include MongoMapper::Document

  key :_id, String
end


class RestaurantMng

  def self.create(params)
    res = Restaurant.create({"admin_user_id" => params["admin_user_id"]})
    res.save
  end

  def self.update(params)
    res = Restaurant.find(params["id"])
    if res.nil?
      return_message(false,{},"No restaurant was found with id #{params["id"]}")
    else
      menu_items = []
      if !params["menu_items"].nil?
        params["menu_items"].each { |item| menu_items << MenuItemMng.create(item) }
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
      data = res.serializable_hash
      return_message(true,data)
    end

  end


  # First adds a menu param to restaurant hash
  # Menu has all menu categories and each category holds its relevant menu_items
  def self.get_all()
    menu_categories = MenuItemMng.get_all_menu_categories[:data]
    restaurants_arr = []
    Restaurant.all(:name => { :$exists => true}).each do |res|
      menu = {}
      menu_categories.each { |category| menu[category] = []}
      res.menu_items.each do |menu_item|
        menu[menu_item.menu_category] << menu_item
      end
      res[:menu] = menu
      res.menu_items = []
      restaurants_arr << res
    end
    return_message(true,restaurants_arr)
  end

  def self.get_restaurant_by_user(user)
    res = Restaurant.where(:admin_user_id => user).first
    return return_message(true,res) unless res.nil?
    return_message(false,{},"User #{user} is not an admin user on any restaurant")
  end

  def self.create_city(city)
    return_message(true,City.create({:_id => city}).serializable_hash)
  end

  def self.get_all_cities
    city_arr = []
    City.all.each { |doc| city_arr << doc.id }
    return_message(true,city_arr)
  end

  #TODO change
  # return field "recommend" for menu item "id"
  def self.getRecommendMenuItem(id)
    menuItems=MenuItem.where(:_id => id.to_s).fields(:recommend).collect(&:recommend)
    return menuItems
  end



end


