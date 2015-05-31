require 'mongo_mapper'
require 'bcrypt'




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
    if(!UserMng.exists?(params["username"]))
      password_salt = BCrypt::Engine.generate_salt
      password_hash = BCrypt::Engine.hash_secret(params["password"], password_salt)

      User.create({
                      :_id  =>  params["username"],
                      :first_name => params["first_name"],
                      :last_name => params["last_name"],
                      :email => params["email"],
                      :salt =>  password_salt,
                      :password_hash  =>  password_hash,
                      :type => params["type"]
                  })
      return true
    end
    return false
  end

  def self.login(username, password)
    if user = User.find(username)
      if user["password_hash"] == BCrypt::Engine.hash_secret(password, user["salt"])
        return true
      end
      return false
    end
    return false
  end

  def self.exists?(username)
    if (User.find(username).nil?)
      return false
    end
    return true
  end


end


