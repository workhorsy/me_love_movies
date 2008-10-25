


class Mailer < ActionMailer::Base
	def user_created(user_id, server_domain, user_name, human_name, email)
		@subject       = "Welcome to Me Love Movies"
		@body          = {}
		@recipients    = email
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/xhtml"

		body[:user_name] = user_name
		body[:human_name] = human_name
		body[:email] = email
		body[:server_domain] = server_domain
		body[:secret] = CGI.escape(Crypt.encrypt(user_id.to_s))
	end

	def user_created_beta(user_id, server_domain, user_name, human_name, email)
		@subject       = "Me Love Movies Beta Request"
		@body          = {}
		@recipients    = Settings.beta_email_processor
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/xhtml"

		body[:user_name] = user_name
		body[:human_name] = human_name
		body[:email] = email
		body[:server_domain] = server_domain
		body[:secret] = CGI.escape(Crypt.encrypt(user_id.to_s))
	end

	def forgot_password(server_domain, user_name, email, hashed_password, salt)
		@subject       = "Me Love Movies password reminder"
		@body          = {}
		@recipients    = email
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/xhtml"

		body[:user_name] = user_name
		body[:email] = email
		body[:password] = User.decrypt_password(hashed_password, salt)
		body[:server_domain] = server_domain
	end

	def user_activated_beta(user_id, server_domain, user_name, human_name, email, hashed_password, salt)
		@subject       = "Welcome to Me Love Movies"
		@body          = {}
		@recipients    = email
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/xhtml"

		body[:user_name] = user_name
		body[:human_name] = human_name
		body[:email] = email
		body[:password] = User.decrypt_password(hashed_password, salt)
		body[:server_domain] = server_domain
	end

	def user_delete_beta(user_id, server_domain, user_name, human_name, email)
		@subject       = "Me Love Movies Beta Request"
		@body          = {}
		@recipients    = email
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/xhtml"

		body[:user_name] = user_name
		body[:human_name] = human_name
		body[:email] = email
		body[:server_domain] = server_domain
	end

	def user_comment(user_id, server_domain, comment, user_name, user_email)
		@subject       = "Me Love Movies User Comment"
		@body          = {}
		@recipients    = Settings.beta_email_processor
		@from          = "noreply@melovemovies.com"
		@headers       = { "Reply-to" => "noreply@melovemovies.com" }
		@sent_on       = Time.now
		@content_type  = "text/xhtml"

		body[:comment] = comment
		body[:user_name] = user_name
		body[:user_email] = user_email
		body[:user_id] = user_id
		body[:server_domain] = server_domain
	end
end


