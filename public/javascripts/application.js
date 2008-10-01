// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults


function get_cookie(name) {
	var value = null;
	document.cookie.split('; ').each(function(cookie) {
		var name_value = cookie.split('=');
		if(name_value[0] == name) {
			value = name_value[1];
		}
	});
	return value;
}

function is_logged_in() {
	value = get_cookie('user_name');
	return (value != null && value != "");
}

function is_user_admin() {
	return (get_cookie('user_type') == 'A');
}

function is_user_moderator() {
	return (get_cookie('user_type') == 'M' || is_user_admin());
}

function is_user_critic() {
	return (get_cookie('user_type') == 'C' || is_user_moderator() || is_user_admin());
}

function is_user_user() {
	return (get_cookie('user_type') == 'U' || is_user_critic() || is_user_moderator() || is_user_admin());
}

function is_originating_user(user_id) {
	return (get_cookie('user_id') == user_id);
}

function show_tags_to_user_only(tag_type, name_pattern) {
	show_tags_to_user_type(tag_type, name_pattern, is_user_user());
}

function show_tags_to_critic_only(tag_type, name_pattern) {
	show_tags_to_user_type(tag_type, name_pattern, is_user_critic());
}

function show_tags_to_moderator_only(tag_type, name_pattern) {
	show_tags_to_user_type(tag_type, name_pattern, is_user_moderator());
}

function show_tags_to_admin_only(tag_type, name_pattern) {
	show_tags_to_user_type(tag_type, name_pattern, is_user_admin());
}

function show_tags_to_originating_user_only(tag_type, name_pattern, user_id) {
	show_tags_to_user_type(tag_type, name_pattern, is_originating_user(user_id.toString()));
}

//private

function show_tags_to_user_type(tag_type, name_pattern, is_user_type) {
	// Just return if the user type is wrong
	if(is_user_type == false) return;

	// If they are not, hide all the tags that match the pattern
	var is_pattern_string = (typeof(name_pattern) == 'string');
	var tags = document.getElementsByTagName(tag_type);
	for(i=0; i< tags.length; i++) {
		if(tags[i].id.toString() == "") continue;
		if(is_pattern_string == true && name_pattern == tags[i].id ||
			is_pattern_string == false && name_pattern.match(tags[i].id)) {
			tags[i].show();
		}
	}
}

function has_default_text(tag_id) {
	$(tag_id).onfocus = function() {
		if (this.value == this.defaultValue) this.value = '';
	};
	$(tag_id).onblur = function() {
		if (this.value == '') this.value = (this.defaultValue ? this.defaultValue : '');
	};
}


function star_update_images(self, number) {
	var stars = self.parentNode.getElementsByTagName('a');
	var got_self = false;
	for(i=0; i <= 5; i++) {
		if(i != 0) {
			stars[i].className = (got_self ? "off" : "on");
		}
		if(self == stars[i]) got_self = true;
	}
}

function star_mouse_off_rating(self) {
	var got_self = false;
	var holder = null;
	var inputs = self.parentNode.getElementsByTagName('input');
	for(i=0; i<inputs.length; i++) {
		if(inputs[i].type == "hidden") {
			holder = inputs[i];
		}
	}

	var stars = self.parentNode.getElementsByTagName('a');
	for(i=0; i <= 5; i++) {
		if(i != 0) {
			stars[i].className = (got_self ? "off" : "on");
		}
		if(holder.value == i) got_self = true;
	}
}

function star_click_rating(self) {
	var holder = null;
	var inputs = self.parentNode.getElementsByTagName('input');
	for(i=0; i<inputs.length; i++) {
		if(inputs[i].type == "hidden") {
			holder = inputs[i];
		}
	}

	var stars = self.parentNode.getElementsByTagName('a');
	for(i=0; i <= 5; i++) {
		if(self == stars[i])
			holder.value = i;
	}
	star_update_images(self);
}

