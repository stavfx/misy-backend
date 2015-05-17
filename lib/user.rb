require 'mongo_mapper'

class User
  include MongoMapper::Document

  key :first_name,  String
  key :last_name,   String
  key :username,    String

end





