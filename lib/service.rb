require 'mongo_mapper'

class Service
  include MongoMapper::Document

  key :name,    String

end


class ServiceMng

  def self.create(name)
    Service.create({:name => name})
  end

  def self.get_all
    puts Service.all
  end

  def self.test
    puts "################## hello $$$$$$$$$$$$$$$"
  end
end


