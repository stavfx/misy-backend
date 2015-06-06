require 'mongo_mapper'
require 'base64'
require 'date'
require File.join(File.dirname(__FILE__), './utils')

class Order
  include MongoMapper::Document

  key :restaurant_id,   String
  key :user_id,         String
  key :table_num,       Integer
  key :menu_items,      Array
  key :service,         String
  key :state,           Integer # 0 - active, 1 - not active, 2 - archived
  key :dining_session,  String


end

# get\post_dish
# get\post_service


class OrderMng

  def self.create(params)
    if params["dining_session"].nil?
      params["dining_session"] = ::Base64.encode64(params.to_s+DateTime.now.to_s)
    end
    order = Order.create({
                     :restaurant_id   => params["restaurant_id"],
                     :user_id         => params["user_id"],
                     :table_num       => params["table_num"],
                     :menu_items      => params["menu_items"],
                     :service         => params["service"],
                     :state           => params["state"],
                     :dining_session  => params["dining_session"]
                 })
    order.save
    data = order.serializable_hash
    return_message(true,data)
  end

  def self.update(params)
    order = Order.find(params["id"])
    if order.nil?
      return_message(false,{},"No Order was found with id #{params["id"]}")
    else
      puts "State = #{params["state"]}"
      if (!order.service.nil?) && params["state"].eql?('2')
        order.destroy
      else
        order.update_attributes(
            :restaurant_id   => params["restaurant_id"],
            :user_id         => params["user_id"],
            :table_num       => params["table_num"],
            :menu_items      => params["menu_items"],
            :service         => params["service"],
            :state           => params["state"]
        )
        order.save
      end
      get_orders(order.restaurant_id)
    end
  end

  def self.get_orders(res_id)
    services_orders = Order.where(:restaurant_id => res_id, :service => { :$exists => true}, :service => {:$not => {:$size => 0}}, :state =>
    { :$ne => 2})
    dishes_orders = Order.where(:restaurant_id => res_id, :menu_items => { :$exists => true}, :menu_items => {:$not => {:$size => 0}}, :state =>
    { :$ne => 2})
    return_message(true,{"services_orders" => services_orders, "dishes_orders" => dishes_orders})
  end

  # return all menu items ids of users who ordered in restaurant "restid"
  def self.getAllUsersItemsByRestID(restid=nil)
    # get ids of all users who ordered in restaurant "restid"
    userIds=Order.where(:restaurant_id => restid).fields(:user_id).collect(&:user_id).uniq
    userItems=Array.new

    for id in userIds
      # get all orders of usersIds
      order=Order.where(:user_id => id).fields(:menu_items).collect(&:menu_items)
      items=[]
      order.each do |arr|
        items=items+arr
      end
      # remove duplicate items and add to user items
      items.uniq!
      userItems.push(items)
    end
    return userItems
  end

end