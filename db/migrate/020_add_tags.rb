class AddTags < ActiveRecord::Migration
  def self.up
    create_table :tags do |t|
      t.string :name
    end

    create_table :title_tags do |t|
      t.integer :tag_id
      t.integer :user_id
    end
  end

  def self.down
    drop_table :title_tags
    drop_table :tags
  end
end
