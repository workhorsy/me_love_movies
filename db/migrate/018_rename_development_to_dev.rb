class RenameDevelopmentToDev < ActiveRecord::Migration
  def self.up
	rename_column "titles", "avg_character_development", "avg_character_dev"
	rename_column "title_ratings", "character_development", "character_dev"
  end

  def self.down
	rename_column "titles", "avg_character_dev", "avg_character_development"
	rename_column "title_ratings", "character_dev", "character_development"
  end
end
