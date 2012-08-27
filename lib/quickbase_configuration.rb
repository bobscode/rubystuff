require 'QuickBaseClient'
class QuickbaseConfiguration

  def self.method_missing(method_sym, *arguments, &block)
    @instance ||= QuickbaseConfiguration.new
    @instance.send(method_sym, *arguments, &block)
  end

  def self.respond_to?(method_sym, *arguments, &block)
    res = super.respond_to?(method_sym)
    return res if res
    @instance ||= QuickbaseConfiguration.new
    @instance.respond_to?(method_sym)
  end

  def create_client(config)
    QuickBase::Client.init("username" => config["client"]["username"], "password" => config["client"]["password"], "org" => config["client"]["domain"], "stopOnError" => true)
  end

  # config["client"]
  # config["system_client"]

  # def create_client
  #   QuickBase::Client.init("username" => config["client"]["username"], "password" => config["client"]["password"], "org" => config["client"]["domain"], "stopOnError" => true)
  # end
  # 
  # def create_system_client
  #   QuickBase::Client.init("username" => config["system_client"]["username"], "password" => config["system_client"]["password"], "org" => config["system_client"]["domain"], "stopOnError" => true)
  # end


  def [] value
    return self.config[value]
  end

  def []= key, value
    self.config[key] = value
  end

  def sanitize_parameter str
    str.gsub(/[{}]/, "")
  end
end