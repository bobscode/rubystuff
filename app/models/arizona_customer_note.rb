class ArizonaCustomerNote < ActiveRecord::Base
  validates_presence_of :customer_id
  validates_uniqueness_of :key
end
