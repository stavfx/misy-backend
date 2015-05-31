require 'mongo_mapper'

class Service
  include MongoMapper::Document

  key :_id,    String

end


class ServiceMng

  def self.create(service)
    Service.create({:_id => service})
  end

  def self.get_all
    Service.all
  end



end


