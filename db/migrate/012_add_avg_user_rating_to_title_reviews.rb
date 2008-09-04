class AddAvgUserRatingToTitleReviews < ActiveRecord::Migration
  def self.up
	add_column :title_reviews, :avg_user_rating, :integer
  end

  def self.down
	remove_column :title_reviews, :avg_user_rating
  end
end
