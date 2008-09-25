class AddDataSourceToTitle < ActiveRecord::Migration
  def self.up
	add_column :titles, :data_source, :text
  end

  def self.down
	remove_column :titles, :data_source
  end
end
