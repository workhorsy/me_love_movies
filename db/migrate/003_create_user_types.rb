class CreateUserTypes < ActiveRecord::Migration
	def self.up
		create_table :user_types do |t|
			t.string :name
			t.string :abbreviation
		end

		UserType.create([
			{:name => 'User', :abbreviation => 'U'},
			{:name => 'Critic', :abbreviation => 'C'},
			{:name => 'Moderator', :abbreviation => 'M'},
			{:name => 'Administrator', :abbreviation => 'A'}
		])
	end

	def self.down
		drop_table :user_types
	end
end
