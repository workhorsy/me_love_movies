class AddTitleIdToTitleRating < ActiveRecord::Migration
  def self.up
    add_column :title_ratings, :title_id, :integer
  end

  def self.down
    remove_column :title_ratings, :title_id
  end
end
