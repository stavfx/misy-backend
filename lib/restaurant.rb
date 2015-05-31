require 'mongo_mapper'


class Restaurant
  include MongoMapper::Document

  key :name,          String
  key :admin_user_id, String
  key :city,          String
  key :address,       String
  key :p_number,      String
  key :desc,          String
  key :services,      Array
  many :menu_items
end

class MenuItem
  include MongoMapper::EmbeddedDocument

  key :name,        String
  key :description, String
  key :price ,      Integer
end


class RestaurantMng

  def self.create(params)
    menu_items = []
    params["menu_items"].each do |item|
      menu_items << MenuItem.new(
                                  :name => item["name"],
                                  :description => item["description"],
                                  :price => item["price"]
                                )

    end
    Restaurant.create({
                        :name          => params["name"],
                        :admin_user_id => params["admin_user_id"],
                        :city          => params["city"],
                        :address       => params["address"],
                        :p_number      => params["p_number"],
                        :desc          => params["desc"],
                        :services      => params["services"],
                        :menu_items    => menu_items
                      })
    return true

  end

  def self.get_all(city = nil)
    return Restaurant.all(:city => city) unless city.nil?
    Restaurant.all
  end



end


