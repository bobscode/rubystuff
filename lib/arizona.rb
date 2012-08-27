module Arizona
  MAX_RECORDS_PER_WRITE = 10000
  MAX_CASE_RECS = 30000
  MAX_DOC_RECS = 30000

  CASES_NAMESPACE = "Cases"
  CUSTOMERS_NAMESPACE = "Customers"
  JOBS_ID_NAMESPACE = "Jobs ID Mapping"

  class << self
    def config
      @config ||= YAML.load_file("#{Rails.root}/config/customer/arizona.yml")[Rails.env]
    end
  
    def create_quickbase_client
      QuickbaseConfiguration.create_client(config)
    end
  end

  Resque.redis = Redis.new :db => Arizona.config["resque"]["db"]

end