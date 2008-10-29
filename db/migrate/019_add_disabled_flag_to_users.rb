class AddDisabledFlagToUsers < ActiveRecord::Migration
  def self.up
	add_column :users, :disabled, :boolean
	add_column :users, :disabled_reason, :text
  end

  def self.down
	remove_column :users, :disabled_reason
	remove_column :users, :disabled
  end
end
