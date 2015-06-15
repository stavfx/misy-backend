require 'mongo_mapper'
require File.join(File.dirname(__FILE__), './utils')


# Class that represents a menu item.
# Each item has a Menu Category which defines the category within the menu:
# Main Course, Desserts etc...
class MenuItem
  include MongoMapper::EmbeddedDocument

  key :name,             String
  key :description,      String
  key :price ,           Integer
  key :menu_category,    String
  key :comment,          String
end


# Class that represents a Menu Category such as:
# Drinks, Main Courses etc...
# Recommend marks whether items under that category will be included in dish recommendation (f.e. Drinks: false, Main Courses: true).
# Priority defines the order of categories in the menu - what will come first, second etc...
class MenuCategory
  include MongoMapper::Document

  key :_id,         String
  key :recommend,   Boolean
  key :priority,    Integer
end



# Class that manages both Menu Items and their categories.
# Used to create, update, find relevant MongoDB documents

class MenuItemMng

  def self.create(params)
    return MenuItem.new(
        :name => params["name"],
        :description => params["description"],
        :price => params["price"],
        :menu_category => params["menu_category"],
        :comment => params["comment"]
    )
  end

  # Return as an array of strings
  def self.get_all_menu_categories
    return_message(true,MenuCategory.all)
  end

  def self.create_menu_category(params)
    menu_category = MenuCategory.create({
                                            :_id => params["menu_category"],
                                            :recommend => params["recommend"],
                                            :priority => params["priority"]
                                        })
    return_message(true,menu_category.serializable_hash)
  end

end