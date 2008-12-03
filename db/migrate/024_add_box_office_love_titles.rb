class AddBoxOfficeLoveTitles < ActiveRecord::Migration
  def self.up
    create_table :box_office_love_titles do |t|
      t.integer :title_id
      t.string :amount
    end
  end

  def self.down
    drop_table :box_office_love_titles
  end
end
