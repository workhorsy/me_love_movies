class AddIndexes < ActiveRecord::Migration
	def self.up
		# Add indexes for id
		add_index :title_ratings, :id
		add_index :title_review_ratings, :id
		add_index :title_reviews, :id
		add_index :titles, :id
		add_index :users, :id

		# Add indexes for name
		add_index :titles, :name
		add_index :users, :name
	end

	def self.down
		# Add indexes for name
		remove_index :users, :name
		remove_index :titles, :name

		# Add indexes for id
		remove_index :users, :id
		remove_index :titles, :id
		remove_index :title_reviews, :id
		remove_index :title_review_ratings, :id
		remove_index :title_ratings, :id
	end
end
