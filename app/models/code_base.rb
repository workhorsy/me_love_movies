class CodeBase
	def self.is_available
		# Just return false when on windows
		return false if RUBY_PLATFORM =~ /.*mswin.*/

		`which bzr`.length > 0
	end
end
