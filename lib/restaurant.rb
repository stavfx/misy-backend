require 'mongo_mapper'

class Restaurant
  include MongoMapper::Document

  key :name,     String
  key :city,     String
  key :address,  String
  key :p_number, String
  key :desc,     String
  key :services, Array
  many :menu_items
end