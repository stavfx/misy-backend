require 'mongo_mapper'
require 'bcrypt'
require File.join(File.dirname(__FILE__), './restaurant')
require File.join(File.dirname(__FILE__), './utils')




class User
  include MongoMapper::Document

  key :_id,           String
  key :first_name,    String
  key :last_name,     String
  key :email,         String
  key :passwordhash,  String
  key :salt,          String
  key :type,          Integer

end


class UserMng

  def self.register(params)
    if(!UserMng.exists?(params["_id"]))
      data = {}
      password_salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(params["password"], password_salt)

      user = User.create({
                      :_id  =>  params["_id"],
                      :first_name => params["first_name"],
                      :last_name => params["last_name"],
                      :email => params["email"],
                      :salt =>  password_salt,
                      :password_hash  =>  password_hash,
                      :type => params["type"]
                  })
      user.save
      data["user_id"] = user._id
      # If this is a Restaurant admin than create a restaurant
      if user.type == 2
        data["restaurant_id"] = RestaurantMng.create({"admin_user_id" => user._id})
      end
      return_message(true,data)
    else
      return_message(false)
    end

  end


  def self.login(username, password)
    if user = User.find(username)
      if user["password_hash"] == BCrypt::Engine.hash_secret(password, user["salt"])
        return_message(true)
      else
        return_message(false,{},"Wrong password!")
      end
    else
      return_message(false,{},"Can't find user #{username}")
    end
  end


  def self.exists?(username)
    if (User.find(username).nil?)
      return false
    end
    return true
  end


end


