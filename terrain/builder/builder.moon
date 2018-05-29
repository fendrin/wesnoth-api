----
-- Copyright (C) 2004 - 2018 by Philippe Plantier <ayin@anathas.org>
-- SPDX-License-Identifier: GPL-2.0+

----
-- @file
-- Definitions for the terrain builder.


-- #include "animated.hpp"
-- #include "game_config.hpp"
Location = require"Location"
-- #include "terrain/translation.hpp"

-- class config;
-- class gamemap;
-- namespace image
-- {
-- class locator;
-- }

----
--  * The class terrain_builder is constructed from a config object, and a
--  * gamemap object. On construction, it parses the configuration and extracts
--  * the list of [terrain_graphics] rules. Each terrain_graphics rule attaches
--  * one or more images to a specific terrain pattern.
--  * It then applies the rules loaded from the configuration to the current map,
--  * and calculates the list of images that must be associated to each hex of
--  * the map.
--  *
--  * The get_terrain_at method can then be used to obtain the list of images
--  * necessary to draw the terrain on a given tile.
--  */
class Terrain_Builder
    -- Used as a parameter for the get_terrain_at function. */
    TERRAIN_TYPE = {
		"BACKGROUND" -- Represents terrains which are to be
					 -- drawn behind unit sprites
		"FOREGROUND" -- Represents terrains which are to be
					 -- drawn in front of them.
	}

    ----
    -- The position of unit graphics in a tile. Graphics whose y
    --  * position is below this value are considered background for
    --  * this tile; graphics whose y position is above this value are
    --  * considered foreground.
	UNITPOS: 36 + 18 -- @todo avoid magic numbers

	DUMMY_HASH: 0

    ----
    -- A shorthand typedef for a list of animated image locators,
    -- the base data type returned by the get_terrain_at method.
    -- typedef std::vector<animated<image::locator>> imagelist;

    ----
    -- Constructor for the terrain_builder class.
    --
    -- @param level  A level (scenario)-specific configuration file,
    --               containing scenario-specific [terrain_graphics] rules.
    -- @param map    A properly-initialized gamemap object representing
    --               the current terrain map.
    -- @param offmap_image The filename of the image which will be used as
    --                     off map image (see add_off_map_rule()).
    --                     This image automatically gets the 'terrain/'
    --                     prefix and '.png' suffix
    -- @param draw_border  Whether the map border flag should be set to
    --                     allow its drawing.
    -- terrain_builder(const config& level, const gamemap* map, const std::string& offmap_image, bool draw_border);
    new: (level, map, offmap_image, draw_border) =>

    -- /**  Set the config where we will parse the global terrain rules.
    --  *   This also flushes the terrain rules cache.
    --  *
    --  * @param cfg            The main game configuration object, where the
    --  *                        [terrain_graphics] rule reside.
    --  */
    -- static void set_terrain_rules_cfg(const config& cfg);
    set_terrain_rules_cfg: (cfg) =>

    ----
    -- Updates internals that cache map size.
    -- This should be called when the map size has changed.
    -- void reload_map();
    reload_map: =>

    -- void change_map(const gamemap* m);
    change_map: (m) =>

    ----
    -- Returns a vector of strings representing the images to load & blit
    -- together to get the built content for this tile.
    --
    -- @param loc   The location relative the the terrain map,
    --              where we ask for the image list
    -- @param tod   The string representing the current time-of day.
    --              Will be used if some images specify several
    --              time-of-day- related variants.
    -- @param terrain_type BACKGROUND or FOREGROUND,
    --        depending on whether we ask for the terrain which is
    --        before, or after the unit sprite.
    --
    -- @return      Returns a pointer list of animated images corresponding
    --              to the parameters, or nullptr if there is none.
    -- const imagelist* get_terrain_at(const map_location& loc, const std::string& tod, TERRAIN_TYPE const terrain_type);
    get_terrain_at: (loc, tod, terrain_type) =>

    ----
    -- Updates the animation at a given tile.
    -- Returns true if something has changed, and must be redrawn.
    --
    -- @param loc   the location to update
    -- @return      true if this tile must be redrawn.
    -- bool update_animation(const map_location& loc);
    update_animation: (loc) =>

    -- /**
    -- Performs a "quick-rebuild" of the terrain in a given location.
    --  * The "quick-rebuild" is no proper rebuild: it only clears the
    --  * terrain cache for a given location, and replaces it with a single,
    --  * default image for this terrain.
    --  *
    --  * @param loc   the location where to rebuild terrains
    -- void rebuild_terrain(const map_location& loc);

    ----
    -- Performs a complete rebuild of the list of terrain graphics
    -- attached to a map.
    -- Should be called when a terrain is changed in the map.
    -- void rebuild_all();
    rebuild_all: =>

	rebuild_cache_all: =>

    -- void set_draw_border(bool do_draw)
    -- {
    --     draw_border_ = do_draw;
    -- }



    -- /**
    --  * A shorthand notation for a vector of rule_images
    --  */
    -- typedef std::vector<rule_image> rule_imagelist;

    ----
    -- tile* get_tile(const map_location& loc);
    -- terrain_builder::tile* terrain_builder::get_tile(
    --     const map_location& loc)
    get_tile: (loc) =>
        if @tile_map.on_map(loc)
            return (@tile_map[loc])
        return nil


-- private:
    -- /** The tile width used when using basex and basey. This is not,
    --  * necessarily, the tile width in pixels, this is totally
    --  * arbitrary. However, it will be set to 72 for convenience.
    --  */
    -- const int tilewidth_; // = game_config::tile_size;

    -- /**
    --  * The list of constraints attached to a terrain_graphics WML rule.
    --  */
    -- typedef std::vector<terrain_constraint> constraint_set;

    -- /**
    --  * A set of building rules. In-memory representation
    --  * of the whole set of [terrain_graphics] rules.
    --  */
    -- typedef std::multiset<building_rule> building_ruleset;

    -- /**
    --  * Load images and tests for validity of a rule. A rule is considered
    --  * valid if all its images are present. This method is used, when building
    --  * the ruleset, to only add rules which are valid to the ruleset.
    --  *
    --  * @param rule  The rule to test for validity
    --  *
    --  * @return        true if the rule is valid, false if it is not.
    --  */
    -- bool load_images(building_rule& rule);
    load_images: (rule) =>

    -- /**
    --  * Starts the animation on a rule.
    --  *
    --  * @param rule  The rule on which to start animations
    --  *
    --  * @return        true
    --  */
    -- bool start_animation(building_rule& rule);
    start_animation: (rule) =>

    -- /**
    --  *  "Rotates" a constraint from a rule.
    --  *  Takes a template constraint from a template rule, and rotates
    --  *  to the given angle.
    --  *
    --  *  On a constraint, the relative position of each rule, and the "base"
    --  *  of each vertical images, are rotated according to the given angle.
    --  *
    --  *  Template terrain constraints are defined like normal terrain
    --  *  constraints, except that, flags, and image filenames,
    --  *  may contain template strings of the form
    --  *@verbatim
    --  *  <code>@Rn</code>,
    --  *@endverbatim
    --  *  n being a number from 0 to 5.
    --  *  See the rotate_rule method for more info.
    --  *
    --  *  @param constraint  A template constraint to rotate
    --  *  @param angle       An int, from 0 to 5, representing the rotation angle.
    --  */
    -- void rotate(terrain_constraint& constraint, int angle);
    rotate: (constraint, angle) =>


    ----
    --  * Replaces, in a given string, rotation tokens with their values.
    --  *
    --  * @param s            the string in which to do the replacement
    --  * @param angle        the angle for substituting the correct replacement.
    --  * @param replacement  the replacement strings.
    -- void replace_rotate_tokens(std::string& s, int angle, const std::vector<std::string>& replacement)
    replace_rotate_tokens: (s, angle, replacement) =>

    -- /**
    --  * Replaces, in a given rule_image, rotation tokens with their values.
    --  * The actual substitution is done in all variants of the given image.
    --  *
    --  * @param image        the rule_image in which to do the replacement.
    --  * @param angle        the angle for substituting the correct replacement.
    --  * @param replacement  the replacement strings.
    --  */
    -- void replace_rotate_tokens(rule_image& image, int angle, const std::vector<std::string>& replacement);
    replace_rotate_tokens: (image, angle, replacement) =>

    -- /**
    --  * Replaces, in a given rule_variant_image, rotation tokens with their values.
    --  * The actual substitution is done in the "image_string" parameter
    --  * of this rule_variant_image.
    --  *
    --  * @param variant      the rule_variant_image in which to do the replacement.
    --  * @param angle        the angle for substituting the correct replacement.
    --  * @param replacement  the replacement strings.
    --  */
    -- void replace_rotate_tokens(rule_image_variant& variant, int angle, const std::vector<std::string>& replacement)
    replace_rotate_tokens: (variant, angle, replacement) =>
		@replace_rotate_tokens(variant.image_string, angle, replacement)

    ----
    -- Replaces, in a given rule_imagelist, rotation tokens with their values.
    -- The actual substitution is done in all rule_images contained
    -- in the rule_imagelist.
    --
    -- @param list         the rule_imagelist in which to do the replacement.
    -- @param angle        the angle for substituting the correct replacement.
    -- @param replacement  the replacement strings.
    -- void replace_rotate_tokens(rule_imagelist& list, int angle, const std::vector<std::string>& replacement);
    replace_rotate_tokens: (list, angle, replacement) =>

    ----
    -- Replaces, in a given building_rule, rotation tokens with their values.
    -- The actual substitution is done in the rule_imagelists contained
    -- in all constraints of the building_rule, and in the flags
    -- (has_flag, set_flag and no_flag) contained in all constraints
    --  of the building_rule.
    --
    --  * @param rule         the building_rule in which to do the replacement.
    --  * @param angle        the angle for substituting the correct replacement.
    --  * @param replacement  the replacement strings.
    --  */
    -- void replace_rotate_tokens(building_rule& rule, int angle, const std::vector<std::string>& replacement);

    ----
    -- Rotates a template rule to a given angle.
    --
    -- Template rules are defined like normal rules, except that:
    -- * Flags and image filenames may contain template strings of the form
    -- @verbatim
    -- <code>@Rn</code>, n being a number from 0 to 5.
    -- @endverbatim
    -- * The rule contains the rotations=r0,r1,r2,r3,r4,r5, with r0 to r5
    --       being strings describing the 6 different positions, typically,
    --       n, ne, se, s, sw, and nw (but maybe anything else.)
    --
    -- A template rule will generate 6 rules, which are similar
    -- to the template, except that:
    --
    -- * The map of constraints ( [tile]s ) of this rule will be
    --   rotated by an angle, of 0 to 5 pi / 6
    --
    -- * On the rule which is rotated to 0rad, the template strings
    -- @verbatim
    -- @R0, @R1, @R2, @R3, @R4, @R5,
    -- @endverbatim
    -- will be replaced by the corresponding r0, r1, r2, r3, r4, r5
    -- variables given in the rotations= element.
    --
    -- * On the rule which is rotated to pi/3 rad, the template strings
    -- @verbatim
    -- @R0, @R1, @R2 etc.
    -- @endverbatim
    -- will be replaced by the corresponding
    -- <strong>r1, r2, r3, r4, r5, r0</strong> (note the shift in indices).
    --
    --  * On the rule rotated 2pi/3, those will be replaced by
    --    r2, r3, r4, r5, r0, r1 and so on.
    -- void rotate_rule(building_rule& rule, int angle, const std::vector<std::string>& angle_name);
    rotate_rule: (rule, angle, angle_name) =>

    -- /**
    --  * Parses a "config" object, which should contains [image] children,
    --  * and adds the corresponding parsed rule_images to a rule_imagelist.
    --  *
    --  * @param images   The rule_imagelist into which to add the parsed images.
    --  * @param cfg      The WML configuration object to parse
    --  * @param global   Whether those [image]s elements belong to a
    --  *                 [terrain_graphics] element, or to a [tile] child.
    --  *                 Set to true if those belong to a [terrain_graphics]
    --  *                 element.
    --  * @param dx       The X coordinate of the constraint those images
    --  *                 apply to, relative to the start of the rule. Only
    --  *                 meaningful if global is set to false.
    --  * @param dy       The Y coordinate of the constraint those images
    --  *                 apply to.
    --  */
    -- void add_images_from_config(rule_imagelist& images, const config& cfg, bool global, int dx = 0, int dy = 0);

    -- /**
    --  * Creates a rule constraint object which matches a given list of
    --  * terrains, and adds it to the list of constraints of a rule.
    --  *
    --  * @param constraints  The constraint set to which to add the constraint.
    --  * @param loc           The location of the constraint
    --  * @param type          The list of terrains this constraint will match
    --  * @param global_images A configuration object containing [image] tags
    --  *                      describing rule-global images.
    --  */
    -- terrain_constraint& add_constraints(constraint_set& constraints,
    --         const map_location& loc,
    --         const t_translation::ter_match& type,
    --         const config& global_images);

    -- /**
    --  * Creates a rule constraint object from a config object and
    --  * adds it to the list of constraints of a rule.
    --  *
    --  * @param constraints   The constraint set to which to add the constraint.
    --  * @param loc           The location of the constraint
    --  * @param cfg           The config object describing this constraint.
    --  *                      Usually, a [tile] child of a [terrain_graphics] rule.
    --  * @param global_images A configuration object containing [image] tags
    --  *                      describing rule-global images.
    --  */
    -- void add_constraints(
    --         constraint_set& constraints, const map_location& loc, const config& cfg, const config& global_images);

    -- typedef std::multimap<int, map_location> anchormap;

    -- /**
    --  * Parses a map string (the map= element of a [terrain_graphics] rule,
    --  * and adds constraints from this map to a building_rule.
    --  *
    --  * @param mapstring     The map vector to parse
    --  * @param br            The building rule into which to add the extracted
    --  *                      constraints
    --  * @param anchors       A map where to put "anchors" extracted from the map.
    --  * @param global_images A config object representing the images defined
    --  *                      as direct children of the [terrain_graphics] rule.
    --  */
    -- void parse_mapstring(
    --         const std::string& mapstring, struct building_rule& br, anchormap& anchors, const config& global_images);

    -- /**
    --  * Adds a rule to a ruleset. Checks for validity before adding the rule.
    --  *
    --  * @param rules      The ruleset into which to add the rules.
    --  * @param rule       The rule to add.
    --  */
    -- void add_rule(building_ruleset& rules, building_rule& rule);

    -- /**
    --  * Adds a set of rules to a ruleset, from a template rule which spans
    --  * 6 rotations (or less if some of the rotated rules are invalid).
    --  *
    --  * @param rules      The ruleset into which to add the rules.
    --  * @param tpl        The template rule
    --  * @param rotations  A comma-separated string containing the
    --  *                   6 values for replacing rotation template
    --  *                   template strings @verbatim (@Rn) @endverbatim
    --  */
    -- void add_rotated_rules(building_ruleset& rules, building_rule& tpl, const std::string& rotations);

    -- /**
    --  * Parses a configuration object containing [terrain_graphics] rules,
    --  * and fills the building_rules_ member of the current class according
    --  * to those.
    --  *
    --  * @param cfg       The configuration object to parse.
    --  * @param local     Mark the rules as local only.
    --  */
    -- void parse_config(const config& cfg, bool local = true);

    -- void parse_global_config(const config& cfg)
    -- {
    --     parse_config(cfg, false);
    -- }

    -- /**
    --  * Adds a builder rule for the _off^_usr tile, this tile only has 1 image.
    --  *
    --  * @param image        The filename of the image
    --  */
    -- void add_off_map_rule(const std::string& image);

    -- void flush_local_rules();

    -- /**
    --  * Checks whether a terrain code matches a given list of terrain codes.
    --  *
    --  * @param tcode     The terrain to check
    --  * @param terrains    The terrain list against which to check the terrain.
    --  *    May contain the metacharacters
    --  *    - '*' STAR, meaning "all terrains"
    --  *    - '!' NOT,  meaning "all terrains except those present in the list."
    --  *
    --  * @return            returns true if "tcode" matches the list or the list is empty,
    --  *                    else false.
    --  */
    -- bool terrain_matches(const t_translation::terrain_code& tcode, const t_translation::ter_list& terrains) const
    -- {
    --     return terrains.empty() ? true : t_translation::terrain_matches(tcode, terrains);
    -- }

    -- /**
    --  * Checks whether a terrain code matches a given list of terrain tcodes.
    --  *
    --  * @param tcode     The terrain code to check
    --  * @param terrain    The terrain match structure which to check the terrain.
    --  *    See previous definition for more details.
    --  *
    --  * @return            returns true if "tcode" matches the list or the list is empty,
    --  *                    else false.
    --  */
    -- bool terrain_matches(const t_translation::terrain_code& tcode, const t_translation::ter_match& terrain) const
    -- {
    --     return terrain.is_empty ? true : t_translation::terrain_matches(tcode, terrain);
    -- }

    -- /**
    --  * Checks whether a rule matches a given location in the map.
    --  *
    --  * @param rule      The rule to check.
    --  * @param loc       The location in the map where we want to check
    --  *                  whether the rule matches.
    --  * @param type_checked The constraint which we already know that its
    --  *                  terrain types matches.
    --  */
    -- bool rule_matches(const building_rule& rule, const map_location& loc, const terrain_constraint* type_checked) const;

    -- /**
    --  * Applies a rule at a given location: applies the result of a
    --  * matching rule at a given location: attachs the images corresponding
    --  * to the rule, and sets the flags corresponding to the rule.
    --  *
    --  * @param rule      The rule to apply
    --  * @param loc       The location to which to apply the rule.
    --  */
    -- void terrain_builder::apply_rule(const terrain_builder::building_rule& rule, const map_location& loc)
    apply_rule: (rule, loc) =>
        rand_seed = get_noise(loc, rule.get_hash())

        for constraint in *rule.constraints
            tloc = legacy_sum(loc, constraint.loc)
            unless @tile_map.on_map(tloc)
                return

            btile = @tile_map[tloc]

            unless constraint.no_draw
                for img in constraint.images
                    table.insert(btile.images, tile.rule_image_rand(img, rand_seed))
            -- Sets flags
            for flag in constraint.set_flag
                btile.flags.insert(flag)

    -- /**
    --  * Calculates the list of terrains, and fills the tile_map_ member,
    --  * from the gamemap and the building_rules_.
    --  */
    -- void build_terrains();

    -- /**
    --  * A pointer to the gamemap class used in the current level.
    --  */
    -- const gamemap* map_;

    -- /**
    --  * The tile_map_ for the current level, which is filled by the
    --  * build_terrains_ method to contain "tiles" representing images
    --  * attached to each tile.
    --  */
    -- tilemap tile_map_;

    -- /**
    --  * Shorthand typedef for a map associating a list of locations to a terrain type.
    --  */
    -- typedef std::map<t_translation::terrain_code, std::vector<map_location>> terrain_by_type_map;

    -- /**
    --  * A map representing all locations whose terrain is of a given type.
    --  */
    -- terrain_by_type_map terrain_by_type_;

    -- /** Whether the map border should be drawn. */
    -- bool draw_border_;

    -- /** Parsed terrain rules. Cached between instances */
    -- static building_ruleset building_rules_;

    -- /** Config used to parse global terrain rules */
    -- static const config* rules_cfg_;

-- #include "terrain/builder.hpp"

-- #include "gui/dialogs/loading_screen.hpp"
-- #include "image.hpp"
-- #include "log.hpp"
-- #include "map/map.hpp"
-- #include "preferences/game.hpp"
-- #include "serialization/string_utils.hpp"

-- static lg::log_domain log_engine("engine");
-- #define ERR_NG LOG_STREAM(err, log_engine)
-- #define WRN_NG LOG_STREAM(warn, log_engine)

-- terrain_builder::building_ruleset terrain_builder::building_rules_;
-- const config* terrain_builder::rules_cfg_ = nullptr;

-- static unsigned int get_noise(const map_location& loc, unsigned int index)
-- {
--     unsigned int a = (loc.x + 92872973) ^ 918273;
--     unsigned int b = (loc.y + 1672517) ^ 128123;
--     unsigned int c = (index + 127390) ^ 13923787;
--     unsigned int abc = a * b * c + a * b + b * c + a * c + a + b + c;
--     return abc * abc;
-- }

-- terrain_builder::terrain_builder(const config& level, const gamemap* m, const std::string& offmap_image, bool draw_border)
--     : tilewidth_(game_config::tile_size)
--     , map_(m)
--     , tile_map_(m ? map().w() : 0, m ? map().h() : 0)
--     , terrain_by_type_()
--     , draw_border_(draw_border)

-- {
--     image::precache_file_existence("terrain/");

--     if(building_rules_.empty() && rules_cfg_) {
--         // off_map first to prevent some default rule seems to block it
--         add_off_map_rule(offmap_image);
--         // parse global terrain rules
--         parse_global_config(*rules_cfg_);
--     } else {
--         // use cached global rules but clear local rules
--         flush_local_rules();
--     }

--     // parse local rules
--     parse_config(level);

--     if(m)
--         build_terrains();
-- }

-- void terrain_builder::rebuild_cache_all()
-- {
--     for(int x = -2; x <= map().w(); ++x) {
--         for(int y = -2; y <= map().h(); ++y) {
--             tile_map_[map_location(x, y)].rebuild_cache("");
--         }
--     }
-- }

-- void terrain_builder::flush_local_rules()
-- {
--     building_ruleset::iterator i = building_rules_.begin();
--     for(; i != building_rules_.end();) {
--         if(i->local)
--             building_rules_.erase(i++);
--         else
--             ++i;
--     }
-- }

-- void terrain_builder::set_terrain_rules_cfg(const config& cfg)
-- {
--     rules_cfg_ = &cfg;
--     // use the swap trick to clear the rules cache and get a fresh one.
--     // because simple clear() seems to cause some progressive memory degradation.
--     building_ruleset empty;
--     std::swap(building_rules_, empty);
-- }

-- void terrain_builder::reload_map()
-- {
--     tile_map_.reload(map().w(), map().h());
--     terrain_by_type_.clear();
--     build_terrains();
-- }

-- void terrain_builder::change_map(const gamemap* m)
-- {
--     map_ = m;
--     reload_map();
-- }

-- const terrain_builder::imagelist* terrain_builder::get_terrain_at(
--         const map_location& loc, const std::string& tod, const TERRAIN_TYPE terrain_type)
-- {
--     if(!tile_map_.on_map(loc))
--         return nullptr;

--     tile& tile_at = tile_map_[loc];

--     if(tod != tile_at.last_tod) {
--         tile_at.rebuild_cache(tod);
--         tile_at.last_tod = tod;
--     }

--     const imagelist& img_list = (terrain_type == BACKGROUND) ? tile_at.images_background : tile_at.images_foreground;

--     if(!img_list.empty()) {
--         return &img_list;
--     }

--     return nullptr;
-- }

-- bool terrain_builder::update_animation(const map_location& loc)
-- {
--     if(!tile_map_.on_map(loc))
--         return false;

--     bool changed = false;

--     tile& btile = tile_map_[loc];

--     for(animated<image::locator>& a : btile.images_background) {
--         if(a.need_update())
--             changed = true;
--         a.update_last_draw_time();
--     }
--     for(animated<image::locator>& a : btile.images_foreground) {
--         if(a.need_update())
--             changed = true;
--         a.update_last_draw_time();
--     }

--     return changed;
-- }

-- /** @todo TODO: rename this function */
-- void terrain_builder::rebuild_terrain(const map_location& loc)
-- {
--     if(tile_map_.on_map(loc)) {
--         tile& btile = tile_map_[loc];
--         // btile.images.clear();
--         btile.images_foreground.clear();
--         btile.images_background.clear();
--         const std::string filename = map().get_terrain_info(loc).minimap_image();

--         if(!filename.empty()) {
--             animated<image::locator> img_loc;
--             img_loc.add_frame(100, image::locator("terrain/" + filename + ".png"));
--             img_loc.start_animation(0, true);
--             btile.images_background.push_back(img_loc);
--         }

--         // Combine base and overlay image if necessary
--         if(map().get_terrain_info(loc).is_combined()) {
--             const std::string filename_ovl = map().get_terrain_info(loc).minimap_image_overlay();

--             if(!filename_ovl.empty()) {
--                 animated<image::locator> img_loc_ovl;
--                 img_loc_ovl.add_frame(100, image::locator("terrain/" + filename_ovl + ".png"));
--                 img_loc_ovl.start_animation(0, true);
--                 btile.images_background.push_back(img_loc_ovl);
--             }
--         }
--     }
-- }

-- void terrain_builder::rebuild_all()
-- {
--     tile_map_.reset();
--     terrain_by_type_.clear();
--     build_terrains();


-- static bool image_exists(const std::string& name)
-- {
--     bool precached = name.find("..") == std::string::npos;

--     if(precached && image::precached_file_exists(name)) {
--         return true;
--     } else if(image::exists(name)) {
--         return true;
--     }

--     return false;
-- }

-- static std::vector<std::string> get_variations(const std::string& base, const std::string& variations)
-- {
--     /** @todo optimize this function */
--     std::vector<std::string> res;
--     if(variations.empty()) {
--         res.push_back(base);
--         return res;
--     }
--     std::string::size_type pos = base.find("@V", 0);
--     if(pos == std::string::npos) {
--         res.push_back(base);
--         return res;
--     }
--     std::vector<std::string> vars = utils::split(variations, ';', 0);

--     for(const std::string& v : vars) {
--         res.push_back(base);
--         pos = 0;
--         while((pos = res.back().find("@V", pos)) != std::string::npos) {
--             res.back().replace(pos, 2, v);
--             pos += v.size();
--         }
--     }
--     return res;
-- }


-- void terrain_builder::parse_mapstring(
--         const std::string& mapstring, struct building_rule& br, anchormap& anchors, const config& global_images)
-- {
--     const t_translation::ter_map map = t_translation::read_builder_map(mapstring);

--     // If there is an empty map leave directly.
--     // Determine after conversion, since a
--     // non-empty string can return an empty map.
--     if(map.data.empty()) {
--         return;
--     }

--     int lineno = (map.get(0, 0) == t_translation::NONE_TERRAIN) ? 1 : 0;
--     int x = lineno;
--     int y = 0;
--     for(int y_off = 0; y_off < map.w; ++y_off) {
--         for(int x_off = x; x_off < map.h; ++x_off) {
--             const t_translation::terrain_code terrain = map.get(y_off, x_off);

--             if(terrain.base == t_translation::TB_DOT) {
--                 // Dots are simple placeholders,
--                 // which do not represent actual terrains.
--             } else if(terrain.overlay != 0) {
--                 anchors.emplace(terrain.overlay, map_location(x, y));
--             } else if(terrain.base == t_translation::TB_STAR) {
--                 add_constraints(br.constraints, map_location(x, y), t_translation::STAR, global_images);
--             } else {
--                 ERR_NG << "Invalid terrain (" << t_translation::write_terrain_code(terrain) << ") in builder map"
--                        << std::endl;
--                 assert(false);
--                 return;
--             }
--             x += 2;
--         }

--         if(lineno % 2 == 1) {
--             ++y;
--             x = 0;
--         } else {
--             x = 1;
--         }
--         ++lineno;
--     }


-- void terrain_builder::add_rule(building_ruleset& rules, building_rule& rule)
-- {
--     if(load_images(rule)) {
--         rules.insert(rule);
--     }
-- }

-- void terrain_builder::add_rotated_rules(building_ruleset& rules, building_rule& tpl, const std::string& rotations)
-- {
--     if(rotations.empty()) {
--         // Adds the parsed built terrain to the list

--         add_rule(rules, tpl);
--     } else {
--         const std::vector<std::string>& rot = utils::split(rotations, ',');

--         for(size_t angle = 0; angle < rot.size(); ++angle) {
--             /* Only 5% of the rules have valid images, so most of
--                them will be discarded. If the ratio was higher,
--                it would be more efficient to insert a copy of the
--                template rule into the ruleset, modify it in place,
--                and remove it if invalid. But since the ratio is so
--                low, the speedup is not worth the extra multiset
--                manipulations. */

--             if(rot.at(angle) == "skip") {
--                 continue;
--             }

--             building_rule rule = tpl;
--             rotate_rule(rule, angle, rot);
--             add_rule(rules, rule);
--         }
--     }
-- }

-- void terrain_builder::parse_config(const config& cfg, bool local)
-- {
--     log_scope("terrain_builder::parse_config");
--     int n = 0;

--     // Parses the list of building rules (BRs)
--     for(const config& br : cfg.child_range("terrain_graphics")) {
--         building_rule pbr; // Parsed Building rule
--         pbr.local = local;

--         // add_images_from_config(pbr.images, **br);

--         pbr.location_constraints = map_location(br["x"].to_int() - 1, br["y"].to_int() - 1);

--         pbr.modulo_constraints = map_location(br["mod_x"].to_int(), br["mod_y"].to_int());

--         pbr.probability = br["probability"].to_int(100);

--         // Mapping anchor indices to anchor locations.
--         anchormap anchors;

--         // Parse the map= , if there is one (and fill the anchors list)
--         parse_mapstring(br["map"], pbr, anchors, br);

--         // Parses the terrain constraints (TCs)
--         for(const config& tc : br.child_range("tile")) {
--             // Adds the terrain constraint to the current built terrain's list
--             // of terrain constraints, if it does not exist.
--             map_location loc;
--             if(const config::attribute_value* v = tc.get("x")) {
--                 loc.x = *v;
--             }
--             if(const config::attribute_value* v = tc.get("y")) {
--                 loc.y = *v;
--             }
--             if(loc.valid()) {
--                 add_constraints(pbr.constraints, loc, tc, br);
--             }
--             if(const config::attribute_value* v = tc.get("pos")) {
--                 int pos = *v;
--                 if(anchors.find(pos) == anchors.end()) {
--                     WRN_NG << "Invalid anchor!" << std::endl;
--                     continue;
--                 }

--                 std::pair<anchormap::const_iterator, anchormap::const_iterator> range = anchors.equal_range(pos);

--                 for(; range.first != range.second; ++range.first) {
--                     loc = range.first->second;
--                     add_constraints(pbr.constraints, loc, tc, br);
--                 }
--             }
--         }

--         const std::vector<std::string> global_set_flag = utils::split(br["set_flag"]);
--         const std::vector<std::string> global_no_flag = utils::split(br["no_flag"]);
--         const std::vector<std::string> global_has_flag = utils::split(br["has_flag"]);
--         const std::vector<std::string> global_set_no_flag = utils::split(br["set_no_flag"]);

--         for(terrain_constraint& constraint : pbr.constraints) {
--             constraint.set_flag.insert(constraint.set_flag.end(), global_set_flag.begin(), global_set_flag.end());
--             constraint.no_flag.insert(constraint.no_flag.end(), global_no_flag.begin(), global_no_flag.end());
--             constraint.has_flag.insert(constraint.has_flag.end(), global_has_flag.begin(), global_has_flag.end());
--             constraint.set_flag.insert(constraint.set_flag.end(), global_set_no_flag.begin(), global_set_no_flag.end());
--             constraint.no_flag.insert(constraint.no_flag.end(), global_set_no_flag.begin(), global_set_no_flag.end());
--         }

--         // Handles rotations
--         const std::string& rotations = br["rotations"];

--         pbr.precedence = br["precedence"];

--         add_rotated_rules(building_rules_, pbr, rotations);

--         n++;
--         if(n % 10 == 0) {
--             gui2::dialogs::loading_screen::progress();
--         }
--     }

-- // Debug output for the terrain rules
-- #if 0
--     std::cerr << "Built terrain rules: \n";

--     building_ruleset::const_iterator rule;
--     for(rule = building_rules_.begin(); rule != building_rules_.end(); ++rule) {
--         std::cerr << ">> New rule: image_background = "
--             << "\n>> Location " << rule->second.location_constraints
--             << "\n>> Probability " << rule->second.probability

--         for(constraint_set::const_iterator constraint = rule->second.constraints.begin();
--             constraint != rule->second.constraints.end(); ++constraint) {

--             std::cerr << ">>>> New constraint: location = (" << constraint->second.loc
--                       << "), terrain types = '" << t_translation::write_list(constraint->second.terrain_types_match.terrain) << "'\n";

--             std::vector<std::string>::const_iterator flag;

--             for(flag  = constraint->second.set_flag.begin(); flag != constraint->second.set_flag.end(); ++flag) {
--                 std::cerr << ">>>>>> Set_flag: " << *flag << "\n";
--             }

--             for(flag = constraint->second.no_flag.begin(); flag != constraint->second.no_flag.end(); ++flag) {
--                 std::cerr << ">>>>>> No_flag: " << *flag << "\n";
--             }
--         }

--     }
-- #endif
-- }

-- void terrain_builder::add_off_map_rule(const std::string& image)
-- {
--     // Build a config object
--     config cfg;

--     config& item = cfg.add_child("terrain_graphics");

--     config& tile = item.add_child("tile");
--     tile["x"] = 0;
--     tile["y"] = 0;
--     tile["type"] = t_translation::write_terrain_code(t_translation::OFF_MAP_USER);

--     config& tile_image = tile.add_child("image");
--     tile_image["layer"] = -1000;
--     tile_image["name"] = image;

--     item["probability"] = 100;
--     item["no_flag"] = "base";
--     item["set_flag"] = "base";

--     // Parse the object
--     parse_global_config(cfg);
-- }

-- bool terrain_builder::rule_matches(const terrain_builder::building_rule& rule,
--         const map_location& loc,
--         const terrain_constraint* type_checked) const
-- {
--     // Don't match if the location isn't a multiple of mod_x and mod_y
--     if(rule.modulo_constraints.x > 0 && (loc.x % rule.modulo_constraints.x != 0)) {
--         return false;
--     }
--     if(rule.modulo_constraints.y > 0 && (loc.y % rule.modulo_constraints.y != 0)) {
--         return false;
--     }

--     if(rule.location_constraints.valid() && rule.location_constraints != loc) {
--         return false;
--     }

--     if(rule.probability != 100) {
--         unsigned int random = get_noise(loc, rule.get_hash()) % 100;
--         if(random > static_cast<unsigned int>(rule.probability)) {
--             return false;
--         }
--     }

--     for(const terrain_constraint& cons : rule.constraints) {
--         // Translated location
--         const map_location tloc = legacy_sum(loc, cons.loc);

--         if(!tile_map_.on_map(tloc)) {
--             return false;
--         }

--         // std::cout << "testing..." << builder_letter(map().get_terrain(tloc))

--         // check if terrain matches except if we already know that it does
--         if(&cons != type_checked && !terrain_matches(map().get_terrain(tloc), cons.terrain_types_match)) {
--             return false;
--         }

--         const std::set<std::string>& flags = tile_map_[tloc].flags;

--         for(const std::string& s : cons.no_flag) {
--             // If a flag listed in "no_flag" is present, the rule does not match
--             if(flags.find(s) != flags.end()) {
--                 return false;
--             }
--         }
--         for(const std::string& s : cons.has_flag) {
--             // If a flag listed in "has_flag" is not present, this rule does not match
--             if(flags.find(s) == flags.end()) {
--                 return false;
--             }
--         }
--     }

--     return true;
-- }


-- // copied from text_surface::hash()
-- // but keep it separated because the needs are different
-- // and changing it will modify the map random variations
-- static unsigned int hash_str(const std::string& str)
-- {
--     unsigned int h = 0;
--     for(std::string::const_iterator it = str.begin(), it_end = str.end(); it != it_end; ++it)
--         h = ((h << 9) | (h >> (sizeof(int) * 8 - 9))) ^ (*it);
--     return h;
-- }


-- void terrain_builder::build_terrains()
-- {
--     log_scope("terrain_builder::build_terrains");

--     // Builds the terrain_by_type_ cache
--     for(int x = -2; x <= map().w(); ++x) {
--         for(int y = -2; y <= map().h(); ++y) {
--             const map_location loc(x, y);
--             const t_translation::terrain_code t = map().get_terrain(loc);

--             terrain_by_type_[t].push_back(loc);

--             // Flag all hexes according to whether they're on the border or not,
--             // to make it easier for WML to draw the borders
--             if(draw_border_&& !map().on_board(loc)) {
--                 tile_map_[loc].flags.insert("_border");
--             } else {
--                 tile_map_[loc].flags.insert("_board");
--             }
--         }
--     }

--     for(const building_rule& rule : building_rules_) {
--         // Find the constraint that contains the less terrain of all terrain rules.
--         // We will keep a track of the matching terrains of this constraint
--         // and later try to apply the rule only on them
--         size_t min_size = INT_MAX;
--         t_translation::ter_list min_types = t_translation::ter_list(); // <-- This must be explicitly initialized, just
--                                                                        // as min_constraint is, at start of loop, or we
--                                                                        // get a null pointer dereference when we go
--                                                                        // through on later times.
--         const terrain_constraint* min_constraint = nullptr;

--         for(const terrain_constraint& constraint : rule.constraints) {
--             const t_translation::ter_match& match = constraint.terrain_types_match;
--             t_translation::ter_list matching_types;
--             size_t constraint_size = 0;

--             for(terrain_by_type_map::iterator type_it = terrain_by_type_.begin(); type_it != terrain_by_type_.end();
--                     ++type_it) {
--                 const t_translation::terrain_code t = type_it->first;
--                 if(terrain_matches(t, match)) {
--                     const size_t match_size = type_it->second.size();
--                     constraint_size += match_size;
--                     if(constraint_size >= min_size) {
--                         break; // not a minimum, bail out
--                     }
--                     matching_types.push_back(t);
--                 }
--             }

--             if(constraint_size < min_size) {
--                 min_size = constraint_size;
--                 min_types = matching_types;
--                 min_constraint = &constraint;
--                 if(min_size == 0) {
--                     // a constraint is never matched on this map
--                     // we break with a empty type list
--                     break;
--                 }
--             }
--         }

--         assert(min_constraint != nullptr);

--         // NOTE: if min_types is not empty, we have found a valid min_constraint;
--         for(t_translation::ter_list::const_iterator t = min_types.begin(); t != min_types.end(); ++t) {
--             const std::vector<map_location>* locations = &terrain_by_type_[*t];

--             for(std::vector<map_location>::const_iterator itor = locations->begin(); itor != locations->end(); ++itor) {
--                 const map_location loc = legacy_difference(*itor, min_constraint->loc);

--                 if(rule_matches(rule, loc, min_constraint)) {
--                     apply_rule(rule, loc);
--                 }
--             }
--         }
--     }
-- }


