require 'mongo_mapper'

class Tags
  include MongoMapper::Document

  key :name,    String
end