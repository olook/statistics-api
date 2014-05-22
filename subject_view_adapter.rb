class SubjectViewAdapter

  def self.adapt(subject)   
    {
      name: subject["_id"],
      views: subject["value"]["view"].round(2),
      clicks: subject["value"]["click"].round(2),
      ctr: (subject["value"]["ctr"] * 100).round(2),
      actions: subject["value"]["action"].round(2),
      conversion: subject["value"]["conversion"] == "NaN" ? "-" : (subject["value"]["conversion"] * 100).round(2)
    }
  end

end