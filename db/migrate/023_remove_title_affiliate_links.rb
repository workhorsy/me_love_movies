class RemoveTitleAffiliateLinks < ActiveRecord::Migration
  def self.up
    remove_column :titles, :affiliate_links
  end

  def self.down
    add_column :titles, :affiliate_links, :text
  end
end
