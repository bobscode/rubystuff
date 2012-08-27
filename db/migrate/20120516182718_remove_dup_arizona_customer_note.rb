class RemoveDupArizonaCustomerNote < ActiveRecord::Migration
  def change
    remove_column :arizona_customer_notes, :qb_last_modified
  end
end
