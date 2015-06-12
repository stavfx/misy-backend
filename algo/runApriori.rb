require 'mongo_mapper'
Dir['/root/maayan/lib/*.rb'].each do |file|
  puts file
  require file
end
require 'apriori'
require 'csv'
require 'rubygems'
require 'json'



# prepare csv array for apriori
def getCSV(restid)
  # get all ordered items of users who ordered in restaurant "restid"
  userItems=OrderMng.getAllUsersItemsByRestID(restid)
  csv=[]
  for userItem in userItems
    tmp=Array.new
    for item in userItem
      tmp.push(item)
    end
    csv.push(tmp)
  end
  puts("B4 P")
  p csv
  p userItems
  return userItems
end

def getHash(restid)
  userItems=OrderMng.getAllUsersItemsByRestID(restid)
  userItems=Hash[userItems.map.with_index { |value, index| [index, value] }]
  p userItems
  return userItems
end


def run(restid,userOrders)
  outputArray = []
  test_data = getHash(restid)
  item_set = Apriori::ItemSet.new(test_data)
  outA = item_set.mine(60, 60)
  p outA
  restItems=RestaurantMng.get_all_menu_items(restid)

  puts "__________________________________"
  #outA.each {|key, value| outputArray.push(key.to_s.split("=>").drop(1).join("").split(",").flatten(2)); p "ia"}
  puts "*****************"
  restItems.push("5575f87ce138231659000003");
  p restItems
  puts "*****************"
  outA.each {
      |key, value|tmp = key.to_s.split("=>");
    tmp[tmp.length-1] = tmp.last.split(",").join("");
    tmp[0] = tmp[0].split(",");
    tmp = tmp.flatten(2);
    outputArray.push(tmp) if restItems.include?(tmp.last);
  }
  p outputArray
  recommendedItem=[]
  recommendedItem.push(maxIntersection(userOrders,outputArray))

  puts "__________________________________"
  return recommendedItem
end

def maxIntersection(userOrders, recommendationArr)
  max=0
  recommendation=""

  for cell in recommendationArr
    tmp=cell.clone
    tmp.delete(tmp.last)
    p tmp
    p cell
    interArr=(tmp&userOrders)
    interSize=interArr.length
    p interSize
    if interSize>max
      max=interSize
      recommendation=cell.last
    end
  end
  p recommendation
  return recommendation

end
MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'misy'

#getCSV("5575f0f7e1382313d7000003")
#runApriori("5575f0f7e1382313d7000003",["5575f87ce138231659000001","55783815e138231b2100000f","55783815e138231b2100000e"])
run("5575f0f7e1382313d7000003",["5575f87ce138231659000001","55783815e138231b2100000f","55783815e138231b2100000e"])
#getHash("5575f0f7e1382313d7000003")
