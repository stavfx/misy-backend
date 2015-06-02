require 'mongo_mapper'
require File.join(File.dirname(__FILE__), './utils')

class Order
  include MongoMapper::Document

  key :restaurant_id,   String
  key :user_id,         String
  key :table_num,       Integer
  key :menu_items,      Array
  key :services,        Array
  key :active,          Boolean
  key :dining_session,  Integer

end


class OrderMng

  def self.create(params)
    data = {}

    order = Order.create({
                     :restaurant_id   => params["restaurant_id"],
                     :user_id         => params["user_id"],
                     :table_num       => params["table_num"],
                     :menu_items      => params["menu_items"],
                     :services        => params["services"],
                     :active          => params["active"],
                     :dining_session  => params["dining_session"]
                 })
    order.save
    data["_id"] = order._id

  end


end