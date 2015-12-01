class Skill < ActiveRecord::Migration
  def change
    create_table :skills do |t|
      t.string  :name
      t.string  :details
      t.integer :level

      t.timestamps
    end
  end
end
