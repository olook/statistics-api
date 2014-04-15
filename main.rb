require 'sinatra'
require 'mongoid'
require 'json'
require './log_entry.rb'
require './dashboard.rb'
require './report.rb'

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


get '/' do
  puts "gerando o relatorio: #{Report.all.count}"
  html = "<table border='1'><tr><th>Assunto</th><th>Visualizações</th><th>Cliques</th><th>CTR</th><th>Compras</th><th>Conversão</th></tr>"

  html += Report.all.map do |subject|
    views = subject["value"]["view"].round(2)
    clicks = subject["value"]["click"].round(2)
    ctr = (subject["value"]["ctr"] * 100).round(2)
    actions = subject["value"]["action"].round(2)
    conversion = subject["value"]["conversion"] == "NaN" ? "-" : (subject["value"]["conversion"] * 100).round(2)

    "<tr><td>#{subject["_id"]}</td><td>#{views}</td><td>#{clicks}</td><td>#{ctr} %</td><td>#{actions}</td><td>#{conversion} %</td></tr>"
  end.join()

  html += "</table>"

  puts "relatorio gerado"
  html
end

get '/statistics.js' do
  send_file 'statistics.js'
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
