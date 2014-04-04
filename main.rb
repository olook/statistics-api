require 'sinatra'
require 'mongoid'
require 'json'
require './log_entry.rb'

Mongoid.load!("./config/mongoid.yml")

options '/' do
  headers['Access-Control-Allow-Origin'] = "*"
  headers['Access-Control-Allow-Methods'] = "POST"
  headers['Access-Control-Allow-Headers'] ="Content-type"
end

get '/' do
  "It's Alive!!!"
end

post '/' do
  params = JSON.parse(request.env["rack.input"].read)
  log = LogEntry.new(params)

  if log.save
    status 200
  else
    status 400
  end
end
