#!/usr/bin/env ruby

def return_message(success,data={},error_message="")
  message = {}
  message[:success] = success
  message[:data] = data
  message[:error_message] = error_message
  return message.to_json
end