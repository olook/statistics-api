class PeriodReport
  include Mongoid::Document

  field :actions
  field :clicks
  field :views
  field :ctr
  field :conversion

end