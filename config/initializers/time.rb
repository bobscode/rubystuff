class Time
  def qb_time
    return (self.to_f * 1000).to_i
  end

  def self.qb_parse(val)
    return Time.at(val.to_i / 1000).utc
  end
end