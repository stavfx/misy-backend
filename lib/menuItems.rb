require 'mongo_mapper'
require File.join(File.dirname(__FILE__), './utils')


class MenuItem
  include MongoMapper::EmbeddedDocument

  key :name,             String
  key :description,      String
  key :price ,           Integer
  key :menu_category,    String
end


class MenuCategory
  include MongoMapper::Document

  key :_id,    String
end


class MenuItemMng

  def self.create(params)
    return MenuItem.new(
        :name => params["name"],
        :description => params["description"],
        :price => params["price"],
        :menu_category => params["menu_category"]
    )
  end

  # Return as an array of strings
  def self.get_all_menu_categories
    menu_categories_arr = []
    MenuCategory.all.each { |doc| menu_categories_arr << doc.id }
    return_message(true,menu_categories_arr)
  end

  def self.create_menu_category(category)
    return_message(true,MenuCategory.create({:_id => category}).serializable_hash)
  end


end