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

function set_cookie(name, value, expires) {
    var path = "/";
    var domain = null;
    var secure = null;

    var today = new Date();
    if(expires){
        expires = expires * 1000 * 3600 * 24;
    }
    var value = name + '=' + escape(value) +
                     ((expires) ? ';expires=' + new Date(today.getTime() + expires).toGMTString() : '') +
                     ((path) ? ';path=' + path : '') +
                     ((domain) ? ';domain=' + domain : '') +
                     ((secure) ? ';secure' : '') + ';';
    document.cookie = value;
}

function delete_cookie(name) {
    if(get_cookie(name)){
        set_cookie(name, get_cookie(name), -30);
    }
} 

function get_user_greeting_from_cookie() {
	var name = get_cookie('user_name');
	var greeting = get_cookie('user_greeting');

	if(name != null) {
		return unescape(greeting).replace(/[+]/g, ' ') + ", " + unescape(name).replace(/[+]/g, ' ');
	} else {
		return "Howdy Stranger";
	}
}

function is_logged_in() {
	var value = get_cookie('user_name');
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
	return (get_cookie('user_id') == user_id || is_user_admin());
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

	// If it is, show all the tags that match the pattern
	var is_pattern_string = (typeof(name_pattern) == 'string');
	var tags = document.getElementsByTagName(tag_type);
	for(i=0; i< tags.length; i++) {
		if(tags[i].id.toString() == "") continue;
		if(is_pattern_string == true && name_pattern == tags[i].id ||
			is_pattern_string == false && name_pattern.match(tags[i].id)) {
			if(tags[i].show) {
				tags[i].show();
			} else {
				tags[i].style.display = "";
			}
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

function update_flash_notice() {
	// Get the message from the cookie
	var message = get_cookie('flash_notice');
	if(message == "") message = null;

	var is_shown = get_cookie('flash_notice_is_shown');
	if(is_shown == "false") is_shown = null;

	// Add the message to the flash and make it visible if there is a message
	if(message && is_shown == "true") {
		$('flash_notice').innerHTML = unescape(message).replace(/[+]/g, ' ');
		$('flash_notice').style.display = "";
	} else {
		$('flash_notice').innerHTML = "";
		$('flash_notice').style.display = "none";
	}

	// Remove the value from the cookie
	delete_cookie('flash_notice');
	set_cookie('flash_notice_is_shown', false);
}

function scale_avatar_images() {
	var class_names = ["big_avatar_image", "small_avatar_image"];
	for(j=0; j<class_names.length; j++) {
		divs = document.getElementsByClassName(class_names[j]);
		for(i=0; i<divs.length; i++) {
			img = divs[i].getElementsByTagName('img')[0];
			img.style.width = "";
			img.style.height = "";
			if(img.width > img.height) {
				img.style.width = '100%';
			} else {
				img.style.height = '100%';
			}
			img.style.position = "relative";
			var div_height = 0;
			if(divs[i].currentStyle) {
				div_height = divs[i].currentStyle.height.split('px')[0];
			} else {
				div_height = document.defaultView.getComputedStyle(divs[i], '').getPropertyValue("height").split('px')[0];
			}
			img.style.top = (div_height / 2) - (img.height / 2) + "px";
		}
	}
}



