class ContainerAbstraction < ActiveRecord::Migration
  def change

    create_table :containers do |t|
      t.string  :type
      t.integer :container_id, index: true
      t.string  :smartsheet_id, null: false, index: true, unique: true
      t.string  :name          # null in case of type:home
      t.string  :permalink     # null in case of type:home
      t.string  :access_level  # null in case of type:folder or type:home
    end

  end
end
