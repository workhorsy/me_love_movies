class CodeBase

	def self.is_available
		`which bzr`.length > 0
	end

	REVNO = `bzr revno`.chomp if self.is_available
	NICK = `bzr nick`.chomp if self.is_available
	LOG = `bzr log`.chomp if self.is_available
end
