require 'mongo_mapper'
require File.join(File.dirname(__FILE__), './utils')

class Service
  include MongoMapper::Document

  key :id,    String

end


class ServiceMng

  def self.create(service)
    Service.create({:id => service})
    return_message(true)
  end

  def self.get_all
    return_message(true,Service.all)
  end



end


