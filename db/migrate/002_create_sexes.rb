class CreateSexes < ActiveRecord::Migration
	def self.up
		create_table :sexes do |t|
			t.string :name
			t.string :abbreviation
		end

		Sex.create([
			{:name => 'Unspecified', :abbreviation => 'U'},
			{:name => 'Male', :abbreviation => 'M'},
			{:name => 'Female', :abbreviation => 'F'}
		])
	end

	def self.down
		drop_table :sexes
	end
end
