require 'mongo_mapper'
Dir['../lib/*.rb'].each do |file|
   require file
end
require 'apriori/algorithm'
require 'csv'
require 'rubygems'
require 'json'



# prepare csv array for apriori
def getCSV(restid)
  # get all users who ordered in restaurant "restid"
  userItems=OrderMng.getAllUsersItemsByRestID(restid)
  csv=[]
  for userItem in userItems
    tmp=Array.new
    for item in userItem
      # get recommend field/flag for menu item
      x=RestaurantMng.getRecommendMenuItem(item)
      # if recommend flag is true - add item to tmp array
      if x[0]
        item=item.to_s
        tmp.push(item)
      end
    end
    # add items to csv array
    csv.push(tmp)
  end
  return csv
end


def runApriori(restid)

  transactions = getCSV(restid)
  p transactions
  algorithm = Apriori::Algorithm.new(0.15, 0.8)
  result = algorithm.analyze(transactions)

  i=0
  j=0
  max=0
  maxcount=0
  count=0
  while i < result.association_rules.length
    while j < result.frequent_item_sets[2][i].item_set.length
      puts("+++++++++++++++++++++++++++")
      puts(result.frequent_item_sets[2][i].item_set[j])
      puts("+++++++++++++++++++++++++++")

      if 1 == result.frequent_item_sets[2][i].item_set[j]
        count=count+1
      end
      j=j+1
    end
    count=0
    if (count > maxcount)
      max = i
    end
    j=0
    puts("____________________________________")
    i=i+1
  end
  puts("i")
  puts(i)
  puts("i")
  puts (result.frequent_item_sets[2][max].item_set)

end

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'misy'


runApriori("1")

