require 'csv'
require 'net/sftp'
require 'enumerator'

class Arizona::LoadJobsComments
  @queue = :testing

  def self.perform
    puts "starting..."
    ftp_config = Arizona.config["ftp"]
    
    logger = Rails.logger
    cust_keys = ActiveSupport::Cache.lookup_store(:redis_store, {:db => Arizona.config["cache"]["db"], :namespace => Arizona::CUSTOMERS_NAMESPACE})
    cases = ActiveSupport::Cache.lookup_store(:redis_store, {:db => Arizona.config["cache"]["db"], :namespace => Arizona::CASES_NAMESPACE})

   # read quickbase credentials from config file
   client = Arizona.create_quickbase_client

    customer_notes_table = Arizona.config["tables"]["customer_notes"]["fields"]
    customer_dbid = Arizona.config["tables"]["customer_notes"]["dbid"]
    notes = client.doQuery(customer_dbid,"{'61'.OAF.'25+days+ago'}","#{customer_notes_table["comment"]}","#{customer_notes_table["comment"]}")
    notes = notes.select { |record| record.is_a?(REXML::Element) }
    notes.each do |record|
    this_note = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{customer_notes_table['comment']}']/text()").to_s.strip)
    #notes = REXML::Text.unnormalize(REXML::XPath.first(record, ".//f[@id='#{customer_notes_table['employer_city']}']/text()").to_s.strip)
    puts "found: #{this_note}"
    end
    
   customers_file = ""
    Net::SFTP.start(ftp_config["host"], ftp_config["login"],
      :password => ftp_config["password"], :auth_methods => ["password"]) do |sftp|
      customers_file = sftp.download!("jobs_comments.txt")
    end
    puts 'downloaded data from arizona'
    customers_arr = CSV.parse(customers_file)
    customers = []
    dups = []
    # add key so can group key by later
    customers_arr.each do |row|
      dup = row[11][0,20] if row[11] != nil
      dups << [dup] if dup != nil
      puts "#{dup} is unique key?" if dup != nil
      if row[8] == nil
        row[8] = ' '
      elsif row[11] == nil
        row[11] = ' '
      end
      customers << [row[0],row[1],row[2],row[3],row[4],row[5],row[6],row[7],row[8],row[9],row[10],row[11],row[2] + '-'+catch]
    end
    puts "#{uni.uniq} is total unique?"
    puts 'parsed data and added key'
    condensed = []
    customers.group_by{|row| row[12]}.values.each do |group|
      comments = group.map{|r| r[11]} * ' '
      comments = "no comments" if comments.blank?
      timeqb = DateTime.reformat_datetime(group.first[10]) #DateTime.init_from_csv(group.first[10]) # don't use DateTime.init_from_csv() ??
      benefit_start_date = DateTime.init_from_csv(group.first[6])      
      date_begin = DateTime.init_from_csv(group.first[9])
      key = group.first[12]
      condensed << [group.first[0],group.first[1],group.first[2],key,group.first[3],group.first[4],group.first[5],benefit_start_date,group.first[7],group.first[8],date_begin,timeqb,comments]
    end

    #File.open('/Users/RR/workspace/test_data.txt', 'w') {|f| f.write(condensed) }

    
    puts "total rows: #{condensed.length}"

    
    customers_notes_columns = ['adabas_isn', 'dps_pe_seq','jobs_id', 'key', 'customer', 'cost_center', 'screen_id','initial_date',
        'com_page','jobs_asn_coworker','date_entered','time_entered','comment'].map {|field| customer_notes_table[field]}.join(".") #'key', 

    logger.info "Attempting to write #{condensed.length} records to Customers table"
    condensed.each_slice(Arizona::MAX_RECORDS_PER_WRITE) do |chunk|
      csv_data = CSV.generate { |csv| chunk.each { |row| csv << row } }.escape_xml
      3.attempts do
        client.importFromCSV(Arizona.config["tables"]["customer_notes"]["dbid"], csv_data, customers_notes_columns)
      end
    end
  end
end
