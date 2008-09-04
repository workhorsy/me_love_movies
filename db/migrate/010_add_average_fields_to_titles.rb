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
    remove_column :titles, :avg_action
    remove_column :titles, :avg_comedy
    remove_column :titles, :avg_drama
    remove_column :titles, :avg_scifi
    remove_column :titles, :avg_romance
    remove_column :titles, :avg_musical
    remove_column :titles, :avg_kids
    remove_column :titles, :avg_adventure
    remove_column :titles, :avg_mystery
    remove_column :titles, :avg_suspense
    remove_column :titles, :avg_horror
    remove_column :titles, :avg_fantasy
    remove_column :titles, :avg_tv
    remove_column :titles, :avg_war
    remove_column :titles, :avg_western
    remove_column :titles, :avg_sports
    remove_column :titles, :avg_premise
    remove_column :titles, :avg_plot
    remove_column :titles, :avg_music
    remove_column :titles, :avg_acting
    remove_column :titles, :avg_special_effects
    remove_column :titles, :avg_pace
    remove_column :titles, :avg_character_development
    remove_column :titles, :avg_cinematography
  end
end
