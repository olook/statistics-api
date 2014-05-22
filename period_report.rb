require './subject_view_adapter.rb'

class PeriodReport
  include Mongoid::Document

  field :actions
  field :clicks
  field :views
  field :ctr
  field :conversion

  def self.get_subjects period
    where({"_id.month" => period}).map { |subject| SubjectViewAdapter.adapt(subject) }
  end
end