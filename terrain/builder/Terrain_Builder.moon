bool terrain_builder::load_images(building_rule& rule)
{
	// If the rule has no constraints, it is invalid
	if(rule.constraints.empty())
		return false;

	// Parse images and animations data
	// If one is not valid, return false.
	for(terrain_constraint& constraint : rule.constraints) {
		for(rule_image& ri : constraint.images) {
			for(rule_image_variant& variant : ri.variants) {
				std::vector<std::string> var_strings = get_variations(variant.image_string, variant.variations);
				for(const std::string& var : var_strings) {
					/** @todo improve this, 99% of terrains are not animated. */
					std::vector<std::string> frames = utils::square_parenthetical_split(var, ',');
					animated<image::locator> res;

					for(const std::string& frame : frames) {
						const std::vector<std::string> items = utils::split(frame, ':');
						const std::string& str = items.front();

						const size_t tilde = str.find('~');
						bool has_tilde = tilde != std::string::npos;
						const std::string filename = "terrain/" + (has_tilde ? str.substr(0, tilde) : str);

						if(!image_exists(filename)) {
							continue; // ignore missing frames
						}

						const std::string modif = (has_tilde ? str.substr(tilde + 1) : "");

						int time = 100;
						if(items.size() > 1) {
							try {
								time = std::stoi(items.back());
							} catch(std::invalid_argument&) {
								ERR_NG << "Invalid 'time' value in terrain image builder: " << items.back() << "\n";
							}
						}
						image::locator locator;
						if(ri.global_image) {
							locator = image::locator(filename, constraint.loc, ri.center_x, ri.center_y, modif);
						} else {
							locator = image::locator(filename, modif);
						}
						res.add_frame(time, locator);
					}
					if(res.get_frames_count() == 0)
						break; // no valid images, don't register it

					res.start_animation(0, true);
					variant.images.push_back(std::move(res));
				}
				if(variant.images.empty())
					return false; // no valid images, rule is invalid
			}
		}
	}

	return true;
}

void terrain_builder::rotate(terrain_constraint& ret, int angle)
{
	static const struct
	{
		int ii;
		int ij;
		int ji;
		int jj;
	} rotations[6] {{1, 0, 0, 1}, {1, 1, -1, 0}, {0, 1, -1, -1}, {-1, 0, 0, -1}, {-1, -1, 1, 0}, {0, -1, 1, 1}};

	// The following array of matrices is intended to rotate the (x,y)
	// coordinates of a point in a wesnoth hex (and wesnoth hexes are not
	// regular hexes :) ).
	// The base matrix for a 1-step rotation with the wesnoth tile shape
	// is:
	//
	// r = s^-1 * t * s
	//
	// with s = [[ 1   0         ]
	//           [ 0   -sqrt(3)/2 ]]
	//
	// and t =  [[ -1/2       sqrt(3)/2 ]
	//           [ -sqrt(3)/2  1/2        ]]
	//
	// With t being the rotation matrix (pi/3 rotation), and s a matrix
	// that transforms the coordinates of the wesnoth hex to make them
	// those of a regular hex.
	//
	// (demonstration left as an exercise for the reader)
	//
	// So we have
	//
	// r = [[ 1/2  -3/4 ]
	//      [ 1    1/2  ]]
	//
	// And the following array contains I(2), r, r^2, r^3, r^4, r^5
	// (with r^3 == -I(2)), which are the successive rotations.
	static const struct
	{
		double xx;
		double xy;
		double yx;
		double yy;
	} xyrotations[6] {
		{ 1.,         0.,  0., 1.    },
		{ 1./2. , -3./4.,  1., 1./2. },
		{ -1./2., -3./4.,   1, -1./2.},
		{ -1.   ,     0.,  0., -1.   },
		{ -1./2.,  3./4., -1., -1./2.},
		{ 1./2. ,  3./4., -1., 1./2. },
	};

	assert(angle >= 0);

	angle %= 6;

	// Vector i is going from n to s, vector j is going from ne to sw.
	int vi = ret.loc.y - ret.loc.x / 2;
	int vj = ret.loc.x;

	int ri = rotations[angle].ii * vi + rotations[angle].ij * vj;
	int rj = rotations[angle].ji * vi + rotations[angle].jj * vj;

	ret.loc.x = rj;
	ret.loc.y = ri + (rj >= 0 ? rj / 2 : (rj - 1) / 2);

	for(rule_imagelist::iterator itor = ret.images.begin(); itor != ret.images.end(); ++itor) {
		double vx, vy, rx, ry;

		vx = double(itor->basex) - double(tilewidth_) / 2;
		vy = double(itor->basey) - double(tilewidth_) / 2;

		rx = xyrotations[angle].xx * vx + xyrotations[angle].xy * vy;
		ry = xyrotations[angle].yx * vx + xyrotations[angle].yy * vy;

		itor->basex = int(rx + tilewidth_ / 2);
		itor->basey = int(ry + tilewidth_ / 2);

		// std::cerr << "Rotation: from " << vx << ", " << vy << " to " << itor->basex <<
		//	", " << itor->basey << "\n";
	}
}

void terrain_builder::replace_rotate_tokens(std::string& s, int angle, const std::vector<std::string>& replacement)
{
	std::string::size_type pos = 0;
	while((pos = s.find("@R", pos)) != std::string::npos) {
		if(pos + 2 >= s.size())
			return;
		unsigned i = s[pos + 2] - '0' + angle;
		if(i >= 6)
			i -= 6;
		if(i >= 6) {
			pos += 2;
			continue;
		}
		const std::string& r = replacement[i];
		s.replace(pos, 3, r);
		pos += r.size();
	}
}

void terrain_builder::replace_rotate_tokens(rule_image& image, int angle, const std::vector<std::string>& replacement)
{
	for(rule_image_variant& variant : image.variants) {
		replace_rotate_tokens(variant, angle, replacement);
	}
}

void terrain_builder::replace_rotate_tokens(
		rule_imagelist& list, int angle, const std::vector<std::string>& replacement)
{
	for(rule_image& img : list) {
		replace_rotate_tokens(img, angle, replacement);
	}
}

void terrain_builder::replace_rotate_tokens(building_rule& rule, int angle, const std::vector<std::string>& replacement)
{
	for(terrain_constraint& cons : rule.constraints) {
		// Transforms attributes
		for(std::string& flag : cons.set_flag) {
			replace_rotate_tokens(flag, angle, replacement);
		}
		for(std::string& flag : cons.no_flag) {
			replace_rotate_tokens(flag, angle, replacement);
		}
		for(std::string& flag : cons.has_flag) {
			replace_rotate_tokens(flag, angle, replacement);
		}
		replace_rotate_tokens(cons.images, angle, replacement);
	}

	// replace_rotate_tokens(rule.images, angle, replacement);
}

void terrain_builder::rotate_rule(building_rule& ret, int angle, const std::vector<std::string>& rot)
{
	if(rot.size() != 6) {
		ERR_NG << "invalid rotations" << std::endl;
		return;
	}

	for(terrain_constraint& cons : ret.constraints) {
		rotate(cons, angle);
	}

	// Normalize the rotation, so that it starts on a positive location
	int minx = INT_MAX;
	int miny = INT_MAX;

	for(const terrain_constraint& cons : ret.constraints) {
		minx = std::min<int>(cons.loc.x, minx);
		miny = std::min<int>(2 * cons.loc.y + (cons.loc.x & 1), miny);
	}

	if((miny & 1) && (minx & 1) && (minx < 0))
		miny += 2;
	if(!(miny & 1) && (minx & 1) && (minx > 0))
		miny -= 2;

	for(terrain_constraint& cons : ret.constraints) {
		legacy_sum_assign(cons.loc, map_location(-minx, -((miny - 1) / 2)));
	}

	replace_rotate_tokens(ret, angle, rot);
}

terrain_builder::rule_image_variant::rule_image_variant(const std::string& image_string,
		const std::string& variations,
		const std::string& tod,
		const std::string& has_flag,
		int random_start)
	: image_string(image_string)
	, variations(variations)
	, images()
	, tods()
	, has_flag()
	, random_start(random_start)
{
	if(!has_flag.empty()) {
		this->has_flag = utils::split(has_flag);
	}
	if(!tod.empty()) {
		const std::vector<std::string> tod_list = utils::split(tod);
		tods.insert(tod_list.begin(), tod_list.end());
	}
}

void terrain_builder::add_images_from_config(rule_imagelist& images, const config& cfg, bool global, int dx, int dy)
{
	for(const config& img : cfg.child_range("image")) {
		int layer = img["layer"];

		int basex = tilewidth_ / 2 + dx, basey = tilewidth_ / 2 + dy;
		if(const config::attribute_value* base_ = img.get("base")) {
			std::vector<std::string> base = utils::split(*base_);
			if(base.size() >= 2) {
				try {
					basex = std::stoi(base[0]);
					basey = std::stoi(base[1]);
				} catch(std::invalid_argument&) {
					ERR_NG << "Invalid 'base' value in terrain image builder: " << base[0] << ", " << base[1] << "\n";
				}
			}
		}

		int center_x = -1, center_y = -1;
		if(const config::attribute_value* center_ = img.get("center")) {
			std::vector<std::string> center = utils::split(*center_);
			if(center.size() >= 2) {
				try {
					center_x = std::stoi(center[0]);
					center_y = std::stoi(center[1]);
				} catch(std::invalid_argument&) {
					ERR_NG << "Invalid 'center' value in terrain image builder: " << center[0] << ", " << center[1]
						   << "\n";
				}
			}
		}

		bool is_water = img["is_water"].to_bool();

		images.push_back(rule_image(layer, basex - dx, basey - dy, global, center_x, center_y, is_water));

		// Adds the other variants of the image
		for(const config& variant : img.child_range("variant")) {
			const std::string& name = variant["name"];
			const std::string& variations = img["variations"];
			const std::string& tod = variant["tod"];
			const std::string& has_flag = variant["has_flag"];

			// If an integer is given then assign that, but if a bool is given, then assign -1 if true and 0 if false
			int random_start = variant["random_start"].to_bool(true) ? variant["random_start"].to_int(-1) : 0;

			images.back().variants.push_back(rule_image_variant(name, variations, tod, has_flag, random_start));
		}

		// Adds the main (default) variant of the image at the end,
		// (will be used only if previous variants don't match)
		const std::string& name = img["name"];
		const std::string& variations = img["variations"];

		int random_start = img["random_start"].to_bool(true) ? img["random_start"].to_int(-1) : 0;

		images.back().variants.push_back(rule_image_variant(name, variations, random_start));
	}
}

terrain_builder::terrain_constraint& terrain_builder::add_constraints(terrain_builder::constraint_set& constraints,
		const map_location& loc,
		const t_translation::ter_match& type,
		const config& global_images)
{
	terrain_constraint* cons = nullptr;
	for(terrain_constraint& c : constraints) {
		if(c.loc == loc) {
			cons = &c;
			break;
		}
	}

	if(!cons) {
		// The terrain at the current location did not exist, so create it
		constraints.emplace_back(loc);
		cons = &constraints.back();
	}

	if(!type.terrain.empty()) {
		cons->terrain_types_match = type;
	}

	int x = loc.x * tilewidth_ * 3 / 4;
	int y = loc.y * tilewidth_ + (loc.x % 2) * tilewidth_ / 2;
	add_images_from_config(cons->images, global_images, true, x, y);

	return *cons;
}

void terrain_builder::add_constraints(terrain_builder::constraint_set& constraints,
		const map_location& loc,
		const config& cfg,
		const config& global_images)

{
	terrain_constraint& constraint = add_constraints(
			constraints, loc, t_translation::ter_match(cfg["type"], t_translation::WILDCARD), global_images);

	std::vector<std::string> item_string = utils::square_parenthetical_split(cfg["set_flag"], ',', "[", "]");
	constraint.set_flag.insert(constraint.set_flag.end(), item_string.begin(), item_string.end());

	item_string = utils::square_parenthetical_split(cfg["has_flag"], ',', "[", "]");
	constraint.has_flag.insert(constraint.has_flag.end(), item_string.begin(), item_string.end());

	item_string = utils::square_parenthetical_split(cfg["no_flag"], ',', "[", "]");
	constraint.no_flag.insert(constraint.no_flag.end(), item_string.begin(), item_string.end());

	item_string = utils::square_parenthetical_split(cfg["set_no_flag"], ',', "[", "]");
	constraint.set_flag.insert(constraint.set_flag.end(), item_string.begin(), item_string.end());
	constraint.no_flag.insert(constraint.no_flag.end(), item_string.begin(), item_string.end());

	constraint.no_draw = cfg["no_draw"].to_bool(false);

	add_images_from_config(constraint.images, cfg, false);
}
