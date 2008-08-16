class CreateTitleRatings < ActiveRecord::Migration
  def self.up
    create_table :title_ratings do |t|
      t.integer :title_id
      t.integer :action
      t.integer :comedy
      t.integer :drama
      t.integer :scifi
      t.integer :romance
      t.integer :musical
      t.integer :kids
      t.integer :adventure
      t.integer :mystery
      t.integer :suspense
      t.integer :horror
      t.integer :fantasy
      t.integer :tv
      t.integer :war
      t.integer :western
      t.integer :sports
      t.integer :premise
      t.integer :plot
      t.integer :music
      t.integer :acting
      t.integer :special_effects
      t.integer :pace
      t.integer :character_development
      t.integer :cinematography

      t.timestamps
    end
  end

  def self.down
    drop_table :title_ratings
  end
end
