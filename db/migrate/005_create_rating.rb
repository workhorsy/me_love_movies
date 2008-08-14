class CreateRating < ActiveRecord::Migration
	def self.up
		create_table :ratings do |t|
			t.string :name
			t.string :abbreviation
		end

		Rating.create([
			{:name => 'Unspecified', :abbreviation => 'U'},
			{:name => 'G', :abbreviation => 'G'},
			{:name => 'PG', :abbreviation => 'PG'},
			{:name => 'PG-13', :abbreviation => 'PG13'},
			{:name => 'R', :abbreviation => 'R'},
			{:name => 'NC-17', :abbreviation => 'NC17'}
		])
	end

	def self.down
		drop_table :ratings
	end
end
