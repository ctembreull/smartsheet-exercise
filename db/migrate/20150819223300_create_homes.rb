class CreateHomes < ActiveRecord::Migration
  def change
    create_table :homes do |t|
      t.integer :user_id, index: true, required: true
      t.string  :raw_json
    end
  end
end
