class LogEntry
  include Mongoid::Document

  field :type
  field :subject
  field :data
  field :created_at, type: DateTime, default: -> {DateTime.now}
  field :visitor_id

  validates_presence_of :type, :visitor_id
end