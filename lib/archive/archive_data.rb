require 'QuickBaseClient'
require 'archive/rescare_indiana/participant_notes_archive_app'
require 'archive/rescare_indiana/participant_notes_sql'
require 'archive/rescare_arizona/customer_notes_sql'

class ArchiveData
  @queue = :archive
  
  class << self
    def perform
      config = Portal.config("archive")
      config["tables"].each do |table|     
           
        client_settings = {
          "username" => table["client"]["username"],
          "password" => table["client"]["password"],
          "domain" => table["client"]["domain"]
        }
        
        archive_criteria = table["archive_criteria"]
        processor = table["processor"]
        
        now = Time.now.utc
        now = now - archive_criteria["years"].to_i.years
        now = now - archive_criteria["months"].to_i.months
        now = now - archive_criteria["days"].to_i.days
        compare_date = Time.utc(now.year, now.month, now.day).qb_time
        
        return_fields = []
        look_up_fields = table["fields"]["lookup"]
        look_up_fields.each do |field_id|
          return_fields << field_id[1] if field_id[1].class == Fixnum
        end
        return_fields = return_fields.join(".")
        
        processor = "Archive::#{processor.camelize}".constantize
        processor.run(client_settings, compare_date, table["fields"], return_fields)   
      end
    end
  end
end
