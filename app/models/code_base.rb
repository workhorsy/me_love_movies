class CodeBase
	def self.is_available
		`which bzr`.length > 0
	end
end
