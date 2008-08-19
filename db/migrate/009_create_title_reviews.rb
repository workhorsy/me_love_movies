class CreateTitleReviews < ActiveRecord::Migration
  def self.up
    create_table :title_reviews do |t|
      t.integer :user_id
      t.integer :title_id
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :title_reviews
  end
end
