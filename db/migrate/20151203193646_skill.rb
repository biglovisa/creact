class Skill < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.text :name
      t.text :details
      t.integer :level

      t.timestamps null:false
    end
  end
end
