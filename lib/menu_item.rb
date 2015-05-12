require 'mongo_mapper'

class MenuItem
  include MongoMapper::EmbeddedDocument

  key :name,        String
  key :description, String
  key :price ,      Integer
  key :tags,        Array


end