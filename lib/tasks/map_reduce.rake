# -*- encoding : utf-8 -*-
require 'mongoid'
require 'json'
require './dashboard.rb'
require './log_entry.rb'
require './visitor.rb'
require './period_visitor.rb'

namespace :map_reduce do

  desc "run simple map reduce"
  task :run do
    Mongoid.load!("./config/mongoid.yml")
    Dashboard.new.run
  end

  desc "run map reduce separated by month"
  task :run_by_period do
    Mongoid.load!("./config/mongoid.yml")
    Dashboard.new.run_by_period
  end  
end
