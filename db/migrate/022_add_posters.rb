class AddPosters < ActiveRecord::Migration
  def self.up
    create_table :posters do |t|
      t.integer :title_id
      t.text :small_image_file
      t.text :big_image_file
      t.string :product_id
    end
  end

  def self.down
    drop_table :posters
  end
end
