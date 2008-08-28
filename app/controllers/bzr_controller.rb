
class BzrController < ApplicationController
	layout nil

	# FIXME: Change this so it does not allow access if you are not an admin or there is no bazaar
	def log
		@log = `bzr log`.chomp

		revstrings = []
		@log.gsub(/revno: [0-9]*\n/) do |match|
			revstrings << match
		end

		revstrings.each do |revstring|
			n = revstring.gsub('revno: ', '')
			@log.gsub!(revstring, "<a href=\"/bzr/changes/#{n}\">#{revstring}</a>")
		end

		@log = '<pre>' + @log + '</pre>'

		render :text => @log
	end

	def diff
		@view = ActionView::Base.new
		@diff = `bzr diff`.chomp
		@diff = '<pre>' + @view.send('h', @diff) + '</pre>'

		render :text => @diff
	end

	def status
		@view = ActionView::Base.new
		@status = `bzr status`.chomp
		@status = '<pre>' + @view.send('h', @status) + '</pre>'

		render :text => @status
	end

	def changes
		revno = params[:id].to_i
		a, b = revno, revno-1
		@view = ActionView::Base.new
		@diff = `bzr diff -r#{a}..#{b}`.chomp
		@diff = '<pre>' + @view.send('h', @diff) + '</pre>'

		render :text => @diff
	end
end


