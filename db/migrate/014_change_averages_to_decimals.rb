class ChangeAveragesToDecimals < ActiveRecord::Migration
	def self.up
		change_column :title_reviews, :avg_user_rating, :float

		change_column :titles, :avg_action, :float
		change_column :titles, :avg_comedy, :float
		change_column :titles, :avg_drama, :float
		change_column :titles, :avg_scifi, :float
		change_column :titles, :avg_romance, :float
		change_column :titles, :avg_musical, :float
		change_column :titles, :avg_kids, :float
		change_column :titles, :avg_adventure, :float
		change_column :titles, :avg_mystery, :float
		change_column :titles, :avg_suspense, :float
		change_column :titles, :avg_horror, :float
		change_column :titles, :avg_fantasy, :float
		change_column :titles, :avg_tv, :float
		change_column :titles, :avg_war, :float
		change_column :titles, :avg_western, :float
		change_column :titles, :avg_sports, :float
		change_column :titles, :avg_premise, :float
		change_column :titles, :avg_plot, :float
		change_column :titles, :avg_music, :float
		change_column :titles, :avg_acting, :float
		change_column :titles, :avg_special_effects, :float
		change_column :titles, :avg_pace, :float
		change_column :titles, :avg_character_development, :float
		change_column :titles, :avg_cinematography, :float
	end

	def self.down
	end
end
