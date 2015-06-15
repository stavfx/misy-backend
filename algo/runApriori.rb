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
# Note - not returning a hash anymore
def getHash(restid)
  # get all ordered items of users who ordered in restaurant "restid"
  userItems=OrderMng.getAllUsersItemsByRestID(restid)
  # userItems=Hash[userItems.map.with_index { |value, index| [index, value] }]
  return userItems
end


def getFinalRecommended(rest_items,items_to_filter)

  puts "Items to filter:"
  p items_to_filter
  puts "rest_items:"
  p rest_items
  p items_to_filter
  frequency_hash = Hash.new(0)
  items_to_filter.each do |items_array|
    arr = (items_array&rest_items)
    arr.each {|item| frequency_hash[item] += 1}
  end
  puts "frequency_hash:"
  p frequency_hash
  final_arr = []
  for i in 0..2
    max_k_v = frequency_hash.max
    if !max_k_v.nil?
      max = max_k_v[0]
      final_arr << max
      frequency_hash.delete(max)
    end
  end
  return final_arr
end


# run Apriori algorithm
def runApriori(restid,userOrders)
  orderedItems = getHash(restid)
  # get all menu items of specific restaurant
  restItems=RestaurantMng.get_all_menu_items(restid)

  # get 3 most accurate recommendations by checking which recommendation most similar to current user prev orders
  recommendedItem=maxIntersection(userOrders,orderedItems)
  return [] if recommendedItem.empty?
  recommendFinal = getFinalRecommended(restItems,recommendedItem)
  return recommendFinal
end

def maxIntersection(userOrders, recommendationArr)
  recommendation=[]
  count=-1
  i=0
  del=0
  outRecommendationArr=[]
  a =[]
  for i in 0..2
    max=0
    for cell in recommendationArr
      count=count+1
      tmp=cell.clone
      tmp.delete(tmp.last)
      interArr=(tmp&userOrders)
      interSize=interArr.length
      if interSize>=max
        max=interSize
        recommendation = cell
      end
    end
    outRecommendationArr.push(recommendation) unless recommendation.empty?
    recommendationArr.delete(recommendation)
    count=-1
  end
  return  outRecommendationArr.uniq
end



