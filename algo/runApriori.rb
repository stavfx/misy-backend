require 'mongo_mapper'
Dir['/root/misy-backend/lib/*.rb'].each do |file|
  puts file
  require file
end
require 'apriori/algorithm'
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
  p userItems
  p csv
  return csv
end


def runApriori(restid,userOrders)

  # transactions = getCSV(restid)
  transactions = getCSV(restid)
  #File.open("/root/misy-backend/algo/dataset.csv") do |file|
  #  file.each_line do |line|
   #   transactions << CSV.parse(line)[0]
   # end
  #end
  p transactions
  algorithm = Apriori::Algorithm.new(0.15, 0.8)
  result = algorithm.analyze(transactions)

  i=0
  j=0

  output=Array.new
  while i < result.frequent_item_sets[2].length#result.association_rules.length
    while j < result.frequent_item_sets[2][i].item_set.length
      puts(result.frequent_item_sets[2][i].item_set[j])
      for order in userOrders
        if order.to_s.eql?(result.frequent_item_sets[2][i].item_set[j].to_s)
          output.push(result.frequent_item_sets[2][i].item_set[j+1])
        end
      end
      j=j+1
    end
    j=0
    i=i+1
  end
  output.uniq!.compact!
  puts "output:"
  p output

  restItems=RestaurantMng.get_all_menu_items(restid)
  puts "ids from rest"
  p restItems

  x=output&restItems
  p x
  return x



end

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'misy'

#getCSV("5575f0f7e1382313d7000003")
runApriori("5575f0f7e1382313d7000003",["5575f87ce138231659000001","55783815e138231b2100000f","55783815e138231b2100000e"])

