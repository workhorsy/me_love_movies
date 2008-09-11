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
	return (get_cookie('user_name') != null);
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

function tags_visible_to_user_only(tag_type, name_pattern) {
	tags_visible_to_user_type_only(tag_type, name_pattern, is_user_user());
}

function tags_visible_to_critic_only(tag_type, name_pattern) {
	tags_visible_to_user_type_only(tag_type, name_pattern, is_user_critic());
}

function tags_visible_to_moderator_only(tag_type, name_pattern) {
	tags_visible_to_user_type_only(tag_type, name_pattern, is_user_moderator());
}

function tags_visible_to_admin_only(tag_type, name_pattern) {
	tags_visible_to_user_type_only(tag_type, name_pattern, is_user_admin());
}

function tags_visible_to_originating_user_only(tag_type, name_pattern, user_id) {
	tags_visible_to_user_type_only(tag_type, name_pattern, is_originating_user(user_id.toString()));
}

//private

function tags_visible_to_user_type_only(tag_type, name_pattern, is_user_type) {
	// Just return if they have the correct user type
	if(is_user_type) return;

	// If they are not, hide all the tags that match the pattern
	var is_pattern_string = (typeof(name_pattern) == 'string');
	var tags = document.getElementsByTagName(tag_type);
	for(i=0; i< tags.length; i++) {
		if(is_pattern_string == true && name_pattern == tags[i].id ||
			is_pattern_string == false && name_pattern(tags[i].id)) {
			tags[i].hide();
		}
	}
}

