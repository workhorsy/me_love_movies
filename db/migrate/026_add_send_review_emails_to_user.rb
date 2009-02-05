class AddSendReviewEmailsToUser < ActiveRecord::Migration
  def self.up
	add_column :users, :send_comment_email, :boolean
  end

  def self.down
	remove_column :users, :send_comment_email
  end
end
