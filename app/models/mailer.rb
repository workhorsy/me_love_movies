
require 'cgi'

class Mailer < ActionMailer::Base
	def user_created(user_id, server_domain, user_name, human_name, email)
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
		body[:secret] = CGI.escape(Base64.encode64(Crypt.encrypt(user_id.to_s)))
	end

	def forgot_password(server_domain, user_name, email, hashed_password, salt)
		@subject       = "Me Love Movies password reminder"
		@body          = {}
		@recipients    = email
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/html"

		body[:user_name] = user_name
		body[:email] = email
		body[:password] = User.decrypt_password(hashed_password, salt)
		body[:server_domain] = server_domain
	end
end


