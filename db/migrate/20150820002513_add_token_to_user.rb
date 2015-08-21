class AddTokenToUser < ActiveRecord::Migration
  def change
    change_table :users do |t|
      t.string :token, index: true
    end
  end
end
