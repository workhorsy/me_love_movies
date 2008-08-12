class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :name
      t.string :user_name
      t.string :hashed_password
      t.string :salt
      t.string :time_zone
      t.integer :year_of_birth
      t.string :gender
      t.string :email
      t.string :avatar_file
      t.string :user_type

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
