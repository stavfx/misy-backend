require 'mongo_mapper'
Dir['../lib/*.rb'].each do |file|
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
  puts "before Apriori run"
  outA = orderedItems.mine(80, 85)
  puts "after Apriori run"
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
  recommendedItem=maxIntersection(userOrders,outputArray)
  puts "---------------"
  puts "recommended items:"
  p recommendedItem
  return recommendedItem
  #return recommendedItem
end

def maxIntersection(userOrders, recommendationArr)
  recommendation=""
  count=-1
  i=0
  del=0
  outRecommendationArr=[]
  a =[]
  for i in 0..2
    max=0
    puts "++++++++++++++++++++++"
    p recommendationArr
    puts "++++++++++++++++++++++"

    for cell in recommendationArr
      count=count+1
      tmp=cell.clone
      tmp.delete(tmp.last)
      interArr=(tmp&userOrders)
      interSize=interArr.length
      if interSize>=max
        max=interSize
        recommendation=cell.last
        del=count
      end
    end
    #recommendationArr.delete_at(del)
    a=recommendationArr
    recommendationArr=[]
    outRecommendationArr.push(recommendation)
    count=-1
    for cell in a
      count=count+1
      if cell.last != recommendation
        recommendationArr.push(cell)
      end
    end
    del=0
    count=-1
    i=0
  end
  return  outRecommendationArr.uniq
end
#MongoMapper.connection = Mongo::Connection.new('localhost')
#MongoMapper.database = 'misy'

#getCSV("5575f0f7e1382313d7000003")
#runApriori("5575f0f7e1382313d7000003",["5575f87ce138231659000001","55783815e138231b2100000f","55783815e138231b2100000e"])
#run("5575f0f7e1382313d7000003",["5575f87ce138231659000001","55783815e138231b2100000f","55783815e138231b2100000e"])
#getHash("5575f0f7e1382313d7000003")
