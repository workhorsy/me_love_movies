class CreateReviewComments < ActiveRecord::Migration
  def self.up
    create_table :review_comments do |t|
      t.integer :title_review_id
      t.integer :user_id
      t.text :body

      t.timestamps
    end
  end

  def self.down
    drop_table :review_comments
  end
end
