class CreateTitles < ActiveRecord::Migration
  def self.up
    create_table :titles do |t|
      t.string :name
      t.date :release_date
      t.string :source
      t.string :director
      t.text :cast
      t.integer :runtime
      t.string :rating
      t.text :premise

      t.timestamps
    end
  end

  def self.down
    drop_table :titles
  end
end
