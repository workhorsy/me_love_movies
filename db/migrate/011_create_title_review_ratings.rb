class CreateTitleReviewRatings < ActiveRecord::Migration
  def self.up
    create_table :title_review_ratings do |t|
      t.integer :title_review_id
      t.integer :user_id
      t.integer :rating

      t.timestamps
    end
  end

  def self.down
    drop_table :title_review_ratings
  end
end
