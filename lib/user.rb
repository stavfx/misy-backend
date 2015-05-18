require 'mongo_mapper'
require 'bcrypt'
require 'sinatra'

enable :sessions

class User
  include MongoMapper::Document

  key :_id,           String
  key :first_name,    String
  key :last_name,     String
  key :email,         String
  key :passwordhash,  String
  key :salt,          String

end


class UserMng

  def self.register(username, password)
    password_salt = BCrypt::Engine.generate_salt
    password_hash = BCrypt::Engine.hash_secret(password, password_salt)

    User.create({
                :_id  =>  username,
                :salt =>  password_salt,
                :password_hash  =>  password_hash
                })

    session[:username] = username
  end

  def self.exists?(username)
    return true unless (User.find(username)).nil?
  end


end


