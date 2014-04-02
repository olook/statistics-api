require 'sinatra'
require 'mongoid'
require 'json'
require './log_entry.rb'

Mongoid.load!("mongoid.yml")

get '/' do
  'Ola Mundo!'
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