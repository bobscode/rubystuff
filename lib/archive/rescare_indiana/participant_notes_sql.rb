require 'QuickBaseClient'

class Archive::ParticipantNotesSql
  def self.run(client_settings, compare_date, fields, return_fields)
    client = QuickBase::Client.init("username" => client_settings["username"], "password" => client_settings["password"], "org" => client_settings["domain"], "stopOnError" => true)
    lookup_fields = fields["lookup"]
    lookup_dbid = lookup_fields["dbid"]
    
    qb_criteria = "{'#{lookup_fields["created_date"]}'.OBF.'#{compare_date}'}"

    client.apptoken = lookup_fields["app_token"]
    record_count = client.doQueryCount(lookup_dbid, qb_criteria)
    puts record_count
  
    i = 0
    max_number_of_records = 5000
    while i < record_count.to_i
      client = QuickBase::Client.init("username" => client_settings["username"], "password" => client_settings["password"], "org" => client_settings["domain"], "stopOnError" => true)
      client.apptoken = lookup_fields["app_token"]
      records = client.doQuery(lookup_dbid, qb_criteria, nil, nil, return_fields, nil, "structured", "num-#{max_number_of_records}.skp-#{i}")
      records = records.select { |record| record.is_a?(REXML::Element) }
      records.each do |record|
        rid = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['rid']}']/text()").to_s.strip)
        old_record_id = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['old_record_id']}']/text()").to_s.strip)
        comment = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['comment']}']/text()").to_s.strip).gsub("<BR/>", ". ")
        related_customer = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_customer']}']/text()").to_s.strip)
        related_staff = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_staff']}']/text()").to_s.strip)
        related_staff_2 = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_staff_2']}']/text()").to_s.strip)
        related_staff_name = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_staff_name']}']/text()").to_s.strip)
        related_staff_name_2 = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_staff_name_2']}']/text()").to_s.strip)
        status = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['status']}']/text()").to_s.strip)
        created_date = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['created_date']}']/text()").to_s.strip)
        modified_date = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['modified_date']}']/text()").to_s.strip)
        modified_by = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['modified_by']}']/text()").to_s.strip)
        related_office = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['related_office']}']/text()").to_s.strip)
        date = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['date']}']/text()").to_s.strip)
        denied_reason = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['denied_reason']}']/text()").to_s.strip).gsub("<BR/>", ". ")
        record_owner = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{lookup_fields['record_owner']}']/text()").to_s.strip)

        created_date = Time.at(created_date.to_i / 1000).utc
        modified_date = Time.at(modified_date.to_i / 1000).utc
        date = Time.at(date.to_i / 1000).utc

        note = ParticipantNote.create do |note|
          note.customer_rid = related_customer
          note.comment = comment
          note.rid = old_record_id
          note.related_staff = related_staff
          note.related_staff_2 = related_staff_2
          note.status = status
          note.qb_created = created_date
          note.qb_last_modified = modified_date
          note.qb_modified_by = modified_by
          note.qb_record_owner = record_owner
          note.related_office = related_office
          note.note_date = date
          note.denied_reason = denied_reason
          note.related_staff_name = related_staff_name
          note.related_staff_name_2 = related_staff_name_2
        end

        client.deleteRecord(lookup_dbid, rid)
      end
      i += max_number_of_records
    end
  end
end