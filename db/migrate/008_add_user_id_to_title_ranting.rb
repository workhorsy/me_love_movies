class AddUserIdToTitleRanting < ActiveRecord::Migration
  def self.up
    add_column :title_ratings, :user_id, :integer
  end

  def self.down
    remove_column :title_ratings, :user_id
  end
end
