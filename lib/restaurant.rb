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
  key :icon,          String
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
                              :icon          => params["icon"],
                              :menu_items    => menu_items
                          )
      res.save
      data = build_menu(res)
      return_message(true,data)
    end

  end

  def self.update_icon(res_id,icon)
    res = Restaurant.find(res_id)
    if res.nil?
      return_message(false,{},"No restaurant was found with id #{params["id"]}")
    else
      res.update_attributes(:icon => icon)
      res.save
      return_message(true,{},"Success")
    end
  end


  def self.get_all()
    restaurants_arr = []
    Restaurant.all(:name => { :$exists => true}).each do |res|
      restaurants_arr << build_menu(res)
    end
    return_message(true,restaurants_arr)
  end

  # First adds a menu param to restaurant hash
  # Menu has all menu categories and each category holds its relevant menu_items
  def self.build_menu(res)
    menu = {}
    res.menu_items.each do |menu_item|
      if menu[menu_item.menu_category].nil?
        menu[menu_item.menu_category] = [menu_item]
      else
        menu[menu_item.menu_category] << menu_item
      end
    end
    res[:menu] = menu
    res.menu_items = []
    return res
  end

  def self.get_restaurant_id_by_user(user)
    msg = get_restaurant_by_user(user)
    return msg unless msg[:success]
    msg[:data] = msg[:data]._id.to_s
    return msg
  end

  def self.get_restaurant_by_user(user)
    res = Restaurant.where(:admin_user_id => user).first
    return return_message(true,build_menu(res)) unless res.nil?
    return_message(false,{},"User #{user} is not an admin user of any restaurant")
  end

  def self.create_city(city)
    return_message(true,City.create({:_id => city}).serializable_hash)
  end

  def self.get_all_cities
    city_arr = []
    City.all.each { |doc| city_arr << doc.id }
    return_message(true,city_arr)
  end


  def self.get_all_menu_items(restid)
    menuItems=Restaurant.where(:_id => restid).fields(:menu_items).collect(&:menu_items)
    menuItems=menuItems[0]
    menuItemsIds=[]
    for item in menuItems
      strid=item['_id'].to_s
      menuItemsIds.push(strid)
    end
    return menuItemsIds
  end


end


