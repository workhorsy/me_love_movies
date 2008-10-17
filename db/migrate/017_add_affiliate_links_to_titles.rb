class AddAffiliateLinksToTitles < ActiveRecord::Migration
  def self.up
    add_column :titles, :affiliate_links, :text
  end

  def self.down
    remove_column :titles, :affiliate_links
  end
end
