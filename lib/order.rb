require 'mongo_mapper'

class Order
  include MongoMapper::Document

  key :restaurant_id,   String
  key :user_id,         String
  key :table_num,       Integer
  key :menu_items,      Array
  key :services,        Array
  key :active,          Boolean

end