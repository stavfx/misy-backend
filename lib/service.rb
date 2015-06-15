require 'mongo_mapper'
require File.join(File.dirname(__FILE__), './utils')

class Service
  include MongoMapper::Document
  plugin MongoMapper::Plugins::IdentityMap

  key :_id,    String

end


class ServiceMng

  def self.create(service)
    Service.create({:_id => service})
    return_message(true)
  end

  def self.get_all
    return_message(true,Service.all)
  end



end


