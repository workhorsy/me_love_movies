class CreateUserTypes < ActiveRecord::Migration
	def self.up
		create_table :user_types do |t|
			t.string :name
			t.string :abbreviation
		end

		UserType.create([
			{:name => 'User', :abbreviation => 'U'},
			{:name => 'Moderator', :abbreviation => 'M'},
			{:name => 'Critic', :abbreviation => 'C'}
		])
	end

	def self.down
		drop_table :user_types
	end
end
