require './subject_view_adapter.rb'

class Report
  include Mongoid::Document

  field :actions
  field :clicks
  field :views
  field :ctr
  field :conversion

  def self.get_subjects
    all.map { |subject| SubjectViewAdapter.adapt(subject) }
  end


end