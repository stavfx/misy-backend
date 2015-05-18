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
    Service.all.to_json
  end

end


