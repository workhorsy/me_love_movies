class AddAverageFieldsToTitles < ActiveRecord::Migration
  def self.up
    add_column :titles, :avg_action, :integer
    add_column :titles, :avg_comedy, :integer
    add_column :titles, :avg_drama, :integer
    add_column :titles, :avg_scifi, :integer
    add_column :titles, :avg_romance, :integer
    add_column :titles, :avg_musical, :integer
    add_column :titles, :avg_kids, :integer
    add_column :titles, :avg_adventure, :integer
    add_column :titles, :avg_mystery, :integer
    add_column :titles, :avg_suspense, :integer
    add_column :titles, :avg_horror, :integer
    add_column :titles, :avg_fantasy, :integer
    add_column :titles, :avg_tv, :integer
    add_column :titles, :avg_war, :integer
    add_column :titles, :avg_western, :integer
    add_column :titles, :avg_sports, :integer
    add_column :titles, :avg_premise, :integer
    add_column :titles, :avg_plot, :integer
    add_column :titles, :avg_music, :integer
    add_column :titles, :avg_acting, :integer
    add_column :titles, :avg_special_effects, :integer
    add_column :titles, :avg_pace, :integer
    add_column :titles, :avg_character_development, :integer
    add_column :titles, :avg_cinematography, :integer
  end

  def self.down
  end
end
