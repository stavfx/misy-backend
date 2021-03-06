require 'mongo_mapper'
require 'base64'
require 'date'
require File.join(File.dirname(__FILE__), './utils')
require 'securerandom'


# Class that represents an order of either s Service request or Menu Items.
# Contains information such as the user that ordered, the relevant restaurant, the dishes \ services ordered etc.
#
# Dining session: Since each order is individual but multiple orders can belong to the same event, we have a dining session.
#                 Dining session is replaced when either the user requested a check or the user is ordering from a different restaurant.
# State: 0 - active, 1 - not active \ handled, 2 - archived (services are not archived, but deleted)

class Order
  include MongoMapper::Document

  key :restaurant_id,   String
  key :user_id,         String
  key :table_num,       String
  key :menu_items,      Array
  key :service,         String
  key :state,           Integer
  key :dining_session,  String
  key :date,            Integer


end



# Class that manages Orders.
# Used to create, update, find relevant MongoDB documents

class OrderMng

  # Create a new order
  def self.create(params)
    # If there is no dining session or user is ordering from a different restaurant, generate a new dining session
    if (params["dining_session"].nil? || (params["dining_session"].split('_').first != params["restaurant_id"]))
      params["dining_session"] = params["restaurant_id"]+'_'+SecureRandom.uuid
    end
    order = Order.create({
                             :restaurant_id   => params["restaurant_id"],
                             :user_id         => params["user_id"],
                             :table_num       => params["table_num"],
                             :menu_items      => params["menu_items"],
                             :service         => params["service"],
                             :state           => params["state"],
                             :dining_session  => params["dining_session"],
                             :date            => Time.now.to_i
                         })
    order.save
    data = order.serializable_hash
    return_message(true,data)
  end

  # Update order's attributes. Mostly used to change order from active to not active
  def self.update(params)
    order = Order.find(params["id"])
    if order.nil?
      return_message(false,{},"No Order was found with id #{params["id"]}")
    else
      # If the order contains a Service and is sent to archive - delete the order.
      if (!order.service.nil?) && params["state"].eql?('2')
        order.destroy
      else
        order.update_attributes(
            :restaurant_id   => params["restaurant_id"],
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

  # Return all orders except archived, where dish orders and service orders are separated.
  def self.get_orders(res_id)
    services_orders = Order.where(:restaurant_id => res_id, :service => { :$exists => true}, :state => { :$ne => 2})
    dishes_orders = Order.where(:restaurant_id => res_id, :menu_items => { :$exists => true}, :menu_items => {:$not => {:$size => 0}}, :state =>
                                                            { :$ne => 2})
    return_message(true,{"services_orders" => services_orders, "dishes_orders" => dishes_orders})
  end

  # Get all Restaurant's archived orders (only dishes)
  def self.get_orders_history_by_res(res_id)
    return_message(true,{"dishes_orders" => (Order.all(:restaurant_id => res_id, :state => 2))})
  end

  # Get all user's orders (except services) and gather them by dining session
  def self.get_orders_history_by_user(user_id)
    orders_by_session = Hash.new {|h,k| h[k] = {"menu_items" => [],"user_id" => user_id, "date" => Time.now.to_i} }  # Hash of hashes
    Order.where(:user_id => user_id, :menu_items => { :$exists => true}, :menu_items => {:$not => {:$size => 0}}).each do |order|
      orders_by_session[order.dining_session]["menu_items"] += order.menu_items
      orders_by_session[order.dining_session]["restaurant_id"] ||= order.restaurant_id
      orders_by_session[order.dining_session]["date"] = order.date if order.date < orders_by_session[order.dining_session]["date"]
    end
     return return_message(true,orders_by_session.values)
  end

  # Send all Restaurant's not active \ handled orders to archive (change to state 2)
  def self.send_not_active_to_archive(res_id)
    Order.all(:restaurant_id => res_id).each do |order|
      next if order.state == 0
      hash_order = order.serializable_hash
      p hash_order
      hash_order["state"] = '2'
      @response = update(hash_order)
      if !@response[:success]
        return return_message(false, "Failed to archive orders with error: #{@response[:error_message]}")
      end
    end
    @response
  end


  # return all menu items ids of users who ordered in restaurant "restid"
  def self.getAllUsersItemsByRestID(restid)
    # get ids of all users who ordered in restaurant "restid"
    userIds=Order.where(:restaurant_id => restid).fields(:user_id).collect(&:user_id).uniq
    userItems=Array.new

    for id in userIds
      # get all orders of usersIds
      #order=Order.where(:user_id => id).fields(:menu_items).collect(&:menu_items)
      orders=Order.where(:user_id => id)
      itemIds=[]
      for o in orders
        itemIds+=extract_recommended_menu_item_ids_from_order(o)
      end

      # remove duplicate items and add to user items
      itemIds.uniq!
      userItems.push(itemIds)
    end
    return userItems
  end

  def self.get_orders_by_userID(userid)
    orders=Order.where(:user_id => userid)
    menuItems=[]
    for o in orders
      menuItems+=extract_recommended_menu_item_ids_from_order(o)
    end
    return menuItems
  end


  def self.extract_recommended_menu_item_ids_from_order(order)
    menuItems=[]
    for item in order.menu_items
      menuItems.push(item)
    end
    menuItems=menuItems.delete_if { |elem| elem.flatten.empty? }
    itemIds=[]
    for item in menuItems
      category=item['menu_category']
      recommend=MenuCategory.where(:_id => category).fields(:recommend).collect(&:recommend)
      if recommend[0]
        itemIds.push(item['id'])
      end
    end
    return itemIds
  end
end
