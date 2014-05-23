# encoding: utf-8
require 'sinatra'
require 'mongoid'
require 'json'
require './log_entry.rb'
require './dashboard.rb'
require './report.rb'
require './period_report.rb'

Mongoid.load!("./config/mongoid.yml")

options '/' do
  headers['Access-Control-Allow-Origin'] = "*"
  headers['Access-Control-Allow-Methods'] = "POST"
  headers['Access-Control-Allow-Headers'] ="Content-type"
end

post '/dashboard' do
  puts "rodando o dashboard"
  dashboard = Dashboard.new
  dashboard.run
  puts "dashboard gerado."
  status 200
end

post '/period_dashboard' do
  puts "rodando o dashboard por periodo"
  dashboard = Dashboard.new
  dashboard.run_by_period
  puts "dashboard por periodo gerado."
  status 200
end

get '/' do
  haml :index
end

get '/period/:period' do
  @month = params[:period]
  haml :period
end

get '/statistics.js' do
  send_file 'statistics.js'
end

post '/' do
  headers['Access-Control-Allow-Origin'] = "*"
  headers['Access-Control-Allow-Methods'] = "POST"
  headers['Access-Control-Allow-Headers'] ="Content-type"

  params = JSON.parse(request.env["rack.input"].read) 
  log = LogEntry.new(params)

  if log.save
    status 200
  else
    status 400
  end
end
