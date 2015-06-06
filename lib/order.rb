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
  key :services,        Array
  key :active,          Integer # 0 - active, 1 - not active, 2 - archived
  key :dining_session,  String


end

# get\post_dish
# get\post_service


class OrderMng

  def self.create(params)
    if params["dining_session"].nil?
      params["dining_session"] = ::Base64.encode64(params.to_s+DateTime.now)
    end
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
    data = order.serializable_hash
    return_message(true,data)
  end

  def get_services_orders()
    Service.all({:services => { $exists => true}, :services => {$not => {$size => 0}}})
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