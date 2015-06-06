require 'mongo_mapper'
require 'bcrypt'
require File.join(File.dirname(__FILE__), './restaurant')
require File.join(File.dirname(__FILE__), './utils')




class User
  include MongoMapper::Document

  key :_id,           String
  key :first_name,    String
  key :last_name,     String
  key :password_hash,  String
  key :salt,          String
  key :type,          Integer

  def serializable_hash(options = {})
    super({:except => [:password_hash,:salt]}.merge(options))
  end
end


class UserMng

  def self.register(params)
    if(!UserMng.exists?(params["id"]))
      password_salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(params["password"], password_salt)

      user = User.create({
                      :_id  =>  params["id"],
                      :first_name => params["first_name"],
                      :last_name => params["last_name"],
                      :salt =>  password_salt,
                      :password_hash  =>  password_hash,
                      :type => params["type"]
                  })
      user.save

      data = {"user" => user.serializable_hash}
      admin_user = nil
      # If this is a Restaurant admin than create a restaurant
      if user.type == 2
        admin_user = user._id
        data["restaurant_id"] = RestaurantMng.create({"admin_user_id" => user._id})
      end

      data.merge!(get_opening_data(admin_user))
      return_message(true,data)
    else
      return_message(false)
    end

  end


  def self.login(username, password)
    if user = User.find(username)
      if user["password_hash"] == BCrypt::Engine.hash_secret(password, user["salt"])
        data = {"user" => user.serializable_hash}
        admin_user = (user["type"] == 2) ? user["id"] : nil
        data.merge!(get_opening_data(admin_user))
        return_message(true, data)
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


