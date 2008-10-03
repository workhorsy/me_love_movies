class AddIsEmailActivatedToUseres < ActiveRecord::Migration
  def self.up
    add_column :users, :is_email_activated, :bool
  end

  def self.down
    remove_column :users, :is_email_activated
  end
end
