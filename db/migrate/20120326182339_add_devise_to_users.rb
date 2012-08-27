class AddDeviseToUsers < ActiveRecord::Migration
  def change
    create_table(:users) do |t|
      t.string :name
      t.trackable
      t.token_authenticatable
      t.timestamps
    end

    add_index :users, :authentication_token, :unique => true
  end
end
