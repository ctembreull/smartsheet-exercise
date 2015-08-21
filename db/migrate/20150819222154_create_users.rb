class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :smartsheet_id, null: false, index: true
      t.string :email_address, null: false, index: true
      t.string :first_name
      t.string :last_name
      t.string :locale
      t.string :time_zone

      t.timestamps null: false
    end
  end
end
