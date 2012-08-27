class AddColumnsArizonaCustomerNote < ActiveRecord::Migration
  def change
    change_table :arizona_customer_notes do |t|
      t.string :record_id
      t.text :comment
      t.string :customer_id
      t.string :related_staff
      t.string :staff_name
      t.string :status
      t.datetime :qb_created
      t.datetime :qb_modified
      t.datetime :qb_last_modified
      t.string :qb_modified_by
      t.string :related_office
      t.date :date
      t.string :denied_reason
      t.string :key
      t.string :adabas_isn
      t.string :dps_pe_seq
      t.string :jobs_id
      t.string :system_screen
      t.date :benefit_start_date
      t.string :system_page
      t.string :jobs_asgn_cwrkr
      t.datetime :time
      t.string :last_comment_number
      t.string :monthly_review
      t.string :jobs_status
      t.date :jobs_start_date
      t.string :jobs_cost_ctr
    end

    add_index :arizona_customer_notes, :customer_id
  end
end
