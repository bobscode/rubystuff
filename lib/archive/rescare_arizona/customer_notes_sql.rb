require 'QuickBaseClient'

class Archive::CustomerNotesSql
  def self.run(client_settings, compare_date, fields, return_fields)

    username = client_settings["username"]
    password = client_settings["password"]
    domain = client_settings["domain"]

    client = QuickBase::Client.init("username" => username, "password" => password, "org" => domain, "stopOnError" => true)

    look_up_fields = fields["lookup"]
    dbid = look_up_fields["dbid"]
    client.apptoken = look_up_fields["app_token"] if look_up_fields["app_token"]

    qb_criteria = "{'#{look_up_fields["date_created"]}'.OBF.'#{compare_date}'}"

    record_count = client.doQueryCount(dbid, qb_criteria)
    puts "record count: #{record_count}"

    i = 0
    max_number_of_records = 5000
    while i < record_count.to_i

      #reinitialize client every 5000 records to prevent ticket from expiring after 12 hours.
      client = QuickBase::Client.init("username" => username, "password" => password, "org" => domain, "stopOnError" => true)
      client.apptoken = look_up_fields["app_token"] if look_up_fields["app_token"]

      records = client.doQuery(dbid, qb_criteria, nil, nil, return_fields, nil, "structured", "num-#{max_number_of_records}.skp-#{i}")
      records = records.select { |record| record.is_a?(REXML::Element) }
      records.each do |record|
        record_id = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["record_id"]}']/text()").to_s.strip)
        comment = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["comment"]}']/text()").to_s.strip)
        customer_id = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["customer_id"]}']/text()").to_s.strip)
        related_staff = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["related_staff"]}']/text()").to_s.strip)
        staff_name = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["staff_name"]}']/text()").to_s.strip)
        status = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["status"]}']/text()").to_s.strip)
        date_created = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["date_created"]}']/text()").to_s.strip)
        date_modified = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["date_modified"]}']/text()").to_s.strip)
        last_modified_by = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["last_modified_by"]}']/text()").to_s.strip)
        related_office = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["related_office"]}']/text()").to_s.strip)
        date = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["date"]}']/text()").to_s.strip)
        denied_reason = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["denied_reason"]}']/text()").to_s.strip)
        key = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["key"]}']/text()").to_s.strip)
        adabas_isn = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["adabas_isn"]}']/text()").to_s.strip)
        dps_pe_seq = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["dps_pe_seq"]}']/text()").to_s.strip)
        jobs_id = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["jobs_id"]}']/text()").to_s.strip)
        system_screen = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["system_screen"]}']/text()").to_s.strip)
        benefit_start_date = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["benefit_start_date"]}']/text()").to_s.strip)
        system_page = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["system_page"]}']/text()").to_s.strip)
        jobs_asgn_cwrkr = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["jobs_asgn_cwrkr"]}']/text()").to_s.strip)
        time = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["time"]}']/text()").to_s.strip)
        last_comment_number = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["last_comment_number"]}']/text()").to_s.strip)
        monthly_review = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["monthly_review"]}']/text()").to_s.strip)
        jobs_status = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["jobs_status"]}']/text()").to_s.strip)
        jobs_start_date = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["jobs_start_date"]}']/text()").to_s.strip)
        jobs_cost_ctr = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{look_up_fields["jobs_cost_ctr"]}']/text()").to_s.strip)

        date_created = Time.at(date_created.to_i / 1000).utc
        date_modified = Time.at(date_modified.to_i / 1000).utc
        date = Time.at(date.to_i / 1000).utc
        benefit_start_date = Time.at(benefit_start_date.to_i / 1000).utc
        jobs_start_date = Time.at(jobs_start_date.to_i / 1000).utc
        time = Time.at(time.to_i / 1000).utc

        note = ArizonaCustomerNote.create do |note|
          note.record_id = record_id
          note.comment = comment
          note.customer_id = customer_id
          note.related_staff = related_staff
          note.staff_name = staff_name
          note.status = status
          note.qb_created = date_created
          note.qb_modified = date_modified
          note.qb_modified_by = last_modified_by
          note.related_office = related_office
          note.date = date
          note.denied_reason = denied_reason
          note.key = key
          note.adabas_isn = adabas_isn
          note.dps_pe_seq = dps_pe_seq
          note.jobs_id = jobs_id
          note.system_screen = system_screen
          note.benefit_start_date = benefit_start_date
          note.system_page = system_page
          note.jobs_asgn_cwrkr = jobs_asgn_cwrkr
          note.time = time
          note.last_comment_number = last_comment_number
          note.monthly_review = monthly_review
          note.jobs_status = jobs_status
          note.jobs_start_date = jobs_start_date
          note.jobs_cost_ctr = jobs_cost_ctr
        end

        client.deleteRecord(dbid, record_id)
      end
      i += max_number_of_records
    end
  end
end