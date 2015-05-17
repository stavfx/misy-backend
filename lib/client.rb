require 'mongo_mapper'

class Client
  include MongoMapper::Document

  key :first_name,    String
  key :last_name,     String
  key :email,         String
  key :user_id,       String


end