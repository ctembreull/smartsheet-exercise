class CreateSheets < ActiveRecord::Migration
  def change
    create_table :sheets do |t|
      t.integer  :container_id, index: true
      t.string   :smartsheet_id, null: false, index: true
      t.string   :name
      t.string   :access_level
      t.string   :permalink
      t.datetime :created_at
      t.datetime :modified_at
    end
  end
end
