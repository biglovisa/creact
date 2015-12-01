class ChangeStringToText < ActiveRecord::Migration
  def change
    change_column :skills, :details, :text
  end
end
