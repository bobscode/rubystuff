require 'QuickBaseClient'

class Archive::ParticipantNotesArchiveApp
  def self.run(client_settings, compare_date, fields, return_values)
    client = QuickBase::Client.init("username" => client_settings["username"], "password" => client_settings["password"], "org" => client_settings["domain"], "stopOnError" => true)
    lookup_fields = fields["lookup"]
    write_to_fields = fields["write_to"]
    
    qb_criteria = "{'#{lookup_fields["date_created"]}'.OBF.'#{compare_date}'}"
    client.apptoken = lookup_fields["app_token"]
    record_count = client.doQueryCount(lookup_fields["dbid"], qb_criteria)
    puts record_count
    
    i = 0
    max_number_of_records = 5000
    records = []
    while i < record_count.to_i
      client = QuickBase::Client.init("username" => client_settings["username"], "password" => client_settings["password"], "org" => client_settings["domain"], "stopOnError" => true)
      client.apptoken = lookup_fields["app_token"]

      records = client.doQuery(lookup_fields["dbid"], qb_criteria, nil, nil, return_values, nil, "structured", "num-#{max_number_of_records}.skp-#{i}")
      records = records.select { |record| record.is_a?(REXML::Element) }
      records.each do |record|
        record_id = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['record_id']}']/text()").to_s.strip)
        comment = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['comment']}']/text()").to_s.strip)
        customer = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['customer']}']/text()").to_s.strip)
        related_staff = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_staff']}']/text()").to_s.strip)
        related_staff_2 = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_staff_2']}']/text()").to_s.strip)
        staff_name = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['staff_name']}']/text()").to_s.strip)
        status = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['status']}']/text()").to_s.strip)
        date_created = format_date(REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['date_created']}']/text()").to_s.strip))
        date_modified = format_date(REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['date_modified']}']/text()").to_s.strip))
        last_modified_by = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['last_modified_by']}']/text()").to_s.strip)
        related_office = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_office']}']/text()").to_s.strip)
        date = format_date(REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['date']}']/text()").to_s.strip))
        denied_reason = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['denied_reason']}']/text()").to_s.strip)
        
        rec = {
          write_to_fields['old_record_id'] => record_id,
          write_to_fields['comment'] => comment,
          write_to_fields['related_customer'] => customer,
          write_to_fields['related_staff'] => related_staff,
          write_to_fields['related_staff_2'] => related_staff_2,
          write_to_fields['staff_name'] => staff_name,
          write_to_fields['status'] => status,
          write_to_fields['related_office'] => related_office,
          write_to_fields['denied_reason'] => denied_reason,
          write_to_fields['last_modified_user'] => last_modified_by,
          write_to_fields['date'] => date.utc.strftime('%F'),
          write_to_fields['created_date'] => date_created.strftime('%Y-%m-%d %I:%M%p'),
          write_to_fields['modified_date'] => date_modified.strftime('%Y-%m-%d %I:%M%p')
        }
        
        client.addRecord(write_to_fields["dbid"], rec)
        client.deleteRecord(lookup_fields["dbid"], record_id)
      end
      i += max_number_of_records
    end
  end
  
  def self.format_date(value)
    value = Time.at(value.to_i / 1000).in_time_zone("Eastern Time (US & Canada)")
  end
end