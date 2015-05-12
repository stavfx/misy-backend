require 'rubygems'
require 'sinatra'
Dir['../lib/*.rb'].each {|file| require file }

MongoMapper.connection = Mongo::Connection.new('localhost')
MongoMapper.database = 'test'




