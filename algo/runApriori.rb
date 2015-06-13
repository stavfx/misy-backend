require 'mongo_mapper'
Dir['../lib/*.rb'].each do |file|
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

# prepare hash for apriori
def getHash(restid)
  # get all ordered items of users who ordered in restaurant "restid"
  userItems=OrderMng.getAllUsersItemsByRestID(restid)
  userItems=Hash[userItems.map.with_index { |value, index| [index, value] }]
  return userItems
end

# run Apriori algorithm
def runApriori(restid,userOrders)
  outputArray = []
  orderedItems = getHash(restid)
  orderedItems = Apriori::ItemSet.new(orderedItems)
  outA = orderedItems.mine(30, 60)
  # get all menu items of specific restaurant
  restItems=RestaurantMng.get_all_menu_items(restid)

  # add to outputArray only recommended items from current restaurant
  outA.each {
    |key, value|tmp = key.to_s.split("=>");
    tmp[tmp.length-1] = tmp.last.split(",").join("");
    tmp[0] = tmp[0].split(",");
    tmp = tmp.flatten(2);
    outputArray.push(tmp) if restItems.include?(tmp.last);
  }

  # get 3 most accurate recommendations by checking which recommendation most similar to current user prev orders
  recommendedItem=[]
  recommended=maxIntersection(userOrders,outputArray)
  recommendedItem.push(recommended)
  return recommended
  #return recommendedItem
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
#MongoMapper.connection = Mongo::Connection.new('localhost')
#MongoMapper.database = 'misy'

#getCSV("5575f0f7e1382313d7000003")
#runApriori("5575f0f7e1382313d7000003",["5575f87ce138231659000001","55783815e138231b2100000f","55783815e138231b2100000e"])
#run("5575f0f7e1382313d7000003",["5575f87ce138231659000001","55783815e138231b2100000f","55783815e138231b2100000e"])
#getHash("5575f0f7e1382313d7000003")
