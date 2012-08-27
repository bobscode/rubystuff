class DateTime
  def qb_time
    self.to_time.qb_time
  end

  def self.init_from_csv val
    if (val && val.length > 7)
      year = val[0, 4].to_i
      month = val[4, 2].to_i
      day = val[6, 2].to_i
      if (Date.valid_civil?(year, month, day))
        return DateTime.new(year, month, day)
      else
        nil
      end
    else
      nil
    end
  end
  
  def self.reformat_datetime(fmt) #mm-dd-ccyy-hh.mm.ss.zone ->MM-DD-YYYY HH:MM (AM/PM)  for Quickbase fmt  zone =6 digits <zeroes>
      return ' ' if fmt.nil?
      ccyy	= fmt[0..3]    ||= 0 
      mm		= fmt[5..6]    ||= 0 
      dd		= fmt[8..9]    ||= 0 
      hh		= fmt[11..12]  ||= 0 # ** ? do I need to switch in AM or PM if its 24 hrs
      mins	= fmt[14..15]  ||= 0 	
      #puts "reformat_date in=#{fmt} , out= #{mm + '-' + dd + '-' + ccyy + ' ' + hh + ':' + mins}"
      return   mm + '-' + dd + '-' + ccyy + ' ' + hh + ':' + mins
  end


  def self.csv_to_qb_time val
    date_time = DateTime.init_from_csv val
    date_time ? date_time.qb_time : ''
  end
end