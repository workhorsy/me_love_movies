


require File.join(File.dirname(__FILE__), "..", "..", "spec_helper.rb")

describe "/users/index.html.erb" do
	it "should list all the users in an unordered list" do
		assigns[:users] = [
			stub("user1", :name => "Bobrick Bobberton",
							:email => "bobrick@bobbertown.net")
		]

		render "/users/index.html.erb"

		response.should have_tag("ul") do
			with_tag("li") do
				with_tag("div", "First Person")
			end
		end
	end
end
