class Mailer < ActionMailer::Base
	def user_created(server_domain, user_name, human_name, email)
		@subject       = "Welcome to Me Love Movies"
		@body          = {}
		@recipients    = email
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/html"

		body[:user_name] = user_name
		body[:human_name] = human_name
		body[:email] = email
		body[:server_domain] = server_domain
	end

	def forgetten_password(server_domain, user_name, email, password)
		@subject       = "Me Love Movies password reminder"
		@body          = {}
		@recipients    = email
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/html"

		body[:user_name] = user_name
		body[:email] = email
		body[:server_domain] = server_domain
		body[:password] = password
	end
end
