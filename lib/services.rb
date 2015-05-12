require 'mongo_mapper'

class Services
  include MongoMapper::Document

  key :name,    String

end